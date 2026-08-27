public import Foundation
import Structured_Queries

extension JSONB.Processing {

    public struct Set<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Foundation.Data

        let jsonb: LHS
        let path: [String]
        let value: Foundation.Data
        let createIfMissing: Bool

        init(jsonb: LHS, path: [String], value: some Encodable, createIfMissing: Bool = true) {
            self.jsonb = jsonb
            self.path = path
            self.createIfMissing = createIfMissing
            do {
                self.value = try jsonbEncoder.encode(value)
            } catch {
                self.value = Foundation.Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: value, encoding: .utf8) ?? "{}"
            return
                "jsonb_set(\(jsonb.queryFragment), \(JSONB.TextPath(path).queryFragment), \(bind: jsonString)::jsonb, \(createIfMissing))"
        }
    }

    public struct Insert<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Foundation.Data

        let jsonb: LHS
        let path: [String]
        let value: Foundation.Data
        let after: Bool

        init(jsonb: LHS, path: [String], value: some Encodable, after: Bool = false) {
            self.jsonb = jsonb
            self.path = path
            self.after = after
            do {
                self.value = try jsonbEncoder.encode(value)
            } catch {
                self.value = Foundation.Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: value, encoding: .utf8) ?? "{}"
            return
                "jsonb_insert(\(jsonb.queryFragment), \(JSONB.TextPath(path).queryFragment), \(bind: jsonString)::jsonb, \(after))"
        }
    }

    public struct StripNulls<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Foundation.Data

        let jsonb: LHS

        public var queryFragment: QueryFragment {
            "jsonb_strip_nulls(\(jsonb.queryFragment))"
        }
    }
}

extension JSONB.Processing {

    public struct TypedSet<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
        QueryExpression
    {
        public typealias QueryValue = Value

        let jsonb: LHS
        let path: [String]
        let value: Foundation.Data
        let createIfMissing: Bool

        init(jsonb: LHS, path: [String], value: some Encodable, createIfMissing: Bool = true) {
            self.jsonb = jsonb
            self.path = path
            self.createIfMissing = createIfMissing
            do {
                self.value = try jsonbEncoder.encode(value)
            } catch {
                self.value = Foundation.Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: value, encoding: .utf8) ?? "{}"
            return
                "jsonb_set(\(jsonb.queryFragment), \(JSONB.TextPath(path).queryFragment), \(bind: jsonString)::jsonb, \(createIfMissing))"
        }
    }

    public struct TypedInsert<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
        QueryExpression
    {
        public typealias QueryValue = Value

        let jsonb: LHS
        let path: [String]
        let value: Foundation.Data
        let after: Bool

        init(jsonb: LHS, path: [String], value: some Encodable, after: Bool = false) {
            self.jsonb = jsonb
            self.path = path
            self.after = after
            do {
                self.value = try jsonbEncoder.encode(value)
            } catch {
                self.value = Foundation.Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: value, encoding: .utf8) ?? "{}"
            return
                "jsonb_insert(\(jsonb.queryFragment), \(JSONB.TextPath(path).queryFragment), \(bind: jsonString)::jsonb, \(after))"
        }
    }

    public struct TypedStripNulls<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
        QueryExpression
    {
        public typealias QueryValue = Value

        let jsonb: LHS

        public var queryFragment: QueryFragment {
            "jsonb_strip_nulls(\(jsonb.queryFragment))"
        }
    }
}

extension QueryExpression where QueryValue == Foundation.Data {

    public func setting<T: Encodable>(
        _ path: [String],
        to value: T,
        createIfMissing: Bool = true
    ) -> some QueryExpression<Foundation.Data> {
        JSONB.Processing.Set(
            jsonb: self,
            path: path,
            value: value,
            createIfMissing: createIfMissing
        )
    }

    public func inserting<T: Encodable>(
        _ value: T,
        at path: [String],
        after: Bool = false
    ) -> some QueryExpression<Foundation.Data> {
        JSONB.Processing.Insert(jsonb: self, path: path, value: value, after: after)
    }

    public func strippingNulls() -> some QueryExpression<Foundation.Data> {
        JSONB.Processing.StripNulls(jsonb: self)
    }

    public func prettyFormatted() -> some QueryExpression<String> {
        JSONB.Processing.Pretty(jsonb: self)
    }

    public func typeString() -> some QueryExpression<String> {
        JSONB.Processing.TypeOf(jsonb: self)
    }

    public func arrayLength() -> some QueryExpression<Int> {
        JSONB.Processing.ArrayLength(jsonb: self)
    }
}
