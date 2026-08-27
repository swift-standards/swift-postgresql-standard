import Foundation
import Structured_Queries

public enum NEW: AliasName {}

extension NEW {

    public static var aliasName: String { "NEW" }

    public static var shouldQuote: Bool { false }
}

public enum OLD: AliasName {}

extension OLD {

    public static var aliasName: String { "OLD" }

    public static var shouldQuote: Bool { false }
}

public struct Trigger<On: Table>: Sendable, Statement {
    public typealias From = Never
    public typealias Joins = ()
    public typealias QueryValue = ()

    public let name: String

    public let timing: Timing

    package let events: [Event]

    public let level: Level

    public let function: Trigger<On>.Function

    public let ifNotExists: Bool

    public enum Timing: String, Sendable {
        case before = "BEFORE"
        case after = "AFTER"
        case insteadOf = "INSTEAD OF"
    }

    public enum Level: String, Sendable {
        case row = "FOR EACH ROW"
        case statement = "FOR EACH STATEMENT"
    }

    package struct Event: Sendable {
        package let kind: Kind
        package let columns: [String]?
        package let whenClause: QueryFragment?

        package enum Kind: String, Sendable {
            case insert = "INSERT"
            case update = "UPDATE"
            case delete = "DELETE"
            case truncate = "TRUNCATE"
        }

        var queryFragment: QueryFragment {
            var query: QueryFragment = "\(raw: kind.rawValue)"
            if let columns, !columns.isEmpty {
                let columnList = columns.map { QueryFragment(quote: $0) }.joined(separator: ", ")
                query.append(" OF \(columnList)")
            }
            return query
        }
    }

    public struct TriggerEvent: Sendable {
        public typealias Old = TableAlias<On, OLD>.TableColumns
        public typealias New = TableAlias<On, NEW>.TableColumns

        package let event: Event

        public static func insert(
            when condition: ((_ new: New) -> any QueryExpression<Bool>)? = nil
        ) -> TriggerEvent {
            TriggerEvent(
                event: Event(
                    kind: .insert,
                    columns: nil,
                    whenClause: condition?(On.as(NEW.self).columns).queryFragment
                )
            )
        }

        public static var insert: TriggerEvent { .insert() }

        public static func update(
            when condition: ((_ new: New) -> any QueryExpression<Bool>)? = nil
        ) -> TriggerEvent {
            TriggerEvent(
                event: Event(
                    kind: .update,
                    columns: nil,
                    whenClause: condition?(On.as(NEW.self).columns).queryFragment
                )
            )
        }

        public static var update: TriggerEvent { .update() }

        public static func update<each Column: _TableColumnExpression>(
            of columns: (On.TableColumns) -> (repeat each Column),
            when condition: ((_ new: New) -> any QueryExpression<Bool>)? = nil
        ) -> TriggerEvent {
            var columnNames: [String] = []
            for column in repeat each columns(On.columns) {
                columnNames.append(contentsOf: column._names)
            }

            return TriggerEvent(
                event: Event(
                    kind: .update,
                    columns: columnNames,
                    whenClause: condition?(On.as(NEW.self).columns).queryFragment
                )
            )
        }

        public static var delete: TriggerEvent { .delete() }

        public static func delete(
            when condition: ((_ old: Old) -> any QueryExpression<Bool>)? = nil
        ) -> TriggerEvent {
            TriggerEvent(
                event: Event(
                    kind: .delete,
                    columns: nil,
                    whenClause: condition?(On.as(OLD.self).columns).queryFragment
                )
            )
        }

        public static var truncate: TriggerEvent {
            TriggerEvent(
                event: Event(kind: .truncate, columns: nil, whenClause: nil)
            )
        }
    }

    init(
        name: String,
        timing: Timing,
        events: [Event],
        level: Level,
        function: Trigger<On>.Function,
        ifNotExists: Bool = false
    ) {
        self.name = name
        self.timing = timing
        self.events = events
        self.level = level
        self.function = function
        self.ifNotExists = ifNotExists
    }

    public var query: QueryFragment {

        var query: QueryFragment = "CREATE TRIGGER"
        query.append(" \(quote: name)")

        query.append("\(.newline)\(raw: timing.rawValue)")

        let eventFragments = events.map(\.queryFragment)
        query.append(" \(eventFragments.joined(separator: " OR "))")

        query.append("\(.newline)ON \(On.self)")

        query.append("\(.newline)\(raw: level.rawValue)")

        let whenClauses = events.compactMap(\.whenClause)
        if let firstWhen = whenClauses.first {

            query.append("\(.newline)WHEN (\(firstWhen))")
        }

        query.append("\(.newline)EXECUTE FUNCTION \(quote: function.name)()")

        return query
    }

    public func drop(ifExists: Bool = false, cascade: Bool = false) -> [any Statement<()>] {
        [
            dropTrigger(ifExists: ifExists, cascade: cascade),
            function.drop(ifExists: ifExists, cascade: cascade),
        ]
    }

    public func dropTrigger(ifExists: Bool = false, cascade: Bool = false) -> some Statement<()> {
        var query: QueryFragment = "DROP TRIGGER"
        if ifExists {
            query.append(" IF EXISTS")
        }
        query.append(" \(quote: name) ON \(On.self)")
        if cascade {
            query.append(" CASCADE")
        }
        return SQLQueryExpression(query)
    }

}

extension Table {

    public static func createTrigger(
        name: String? = nil,
        timing: Trigger<Self>.Timing,
        event: Trigger<Self>.TriggerEvent...,
        ifNotExists: Bool = false,
        level: Trigger<Self>.Level = .row,
        function: Trigger<Self>.Function
    ) -> Trigger<Self> {
        let events = event.map(\.event)

        let triggerName: String
        if let name {
            triggerName = name
        } else {
            let timingStr: String
            switch timing {
            case .before: timingStr = "before"
            case .after: timingStr = "after"
            case .insteadOf: timingStr = "instead_of"
            }

            triggerName = generateTriggerName(
                timing: timingStr,
                event: events.first!,
                function: function
            )
        }

        return Trigger(
            name: triggerName,
            timing: timing,
            events: events,
            level: level,
            function: function,
            ifNotExists: ifNotExists
        )
    }

    private static func generateTriggerName(
        timing: String,
        event: Trigger<Self>.Event,
        function: Trigger<Self>.Function
    ) -> String {
        let eventDesc: String
        switch event.kind {
        case .insert: eventDesc = "insert"
        case .update: eventDesc = "update"
        case .delete: eventDesc = "delete"
        case .truncate: eventDesc = "truncate"
        }

        let functionDesc = function.name
            .replacingOccurrences(of: "_\(Self.tableName)", with: "")

        return "\(Self.tableName)_\(timing)_\(eventDesc)_\(functionDesc)"
    }
}
