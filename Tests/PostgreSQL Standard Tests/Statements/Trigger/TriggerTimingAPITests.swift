import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Structured_Queries_Primitives
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.TriggerTests {
    /// Tests for trigger timing (BEFORE, AFTER, INSTEAD OF).
    ///
    /// These tests demonstrate the unified `createTrigger` API with explicit timing and event parameters.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Unified API with explicit timing and event
    /// User.createTrigger(timing: .before, event: .update, function: .updateTimestamp(column: \.updatedAt))
    /// User.createTrigger(timing: .after, event: .insert, function: .audit(to: AuditLog.self))
    /// UserView.createTrigger(timing: .insteadOf, event: .delete, function: .handleDelete())
    /// ```
    @Suite("Trigger Timing")
    struct TimingAPITests {

        // MARK: - Test Models

        @Table("tasks")
        struct Task {
            let id: Int
            var title: String
            var status: String
            var priority: Int
            var createdAt: Date?
            var updatedAt: Date?
            var completedAt: Date?
        }

        @Table("orders")
        struct Order {
            let id: Int
            var userId: Int
            var total: Double
            var status: String
            var createdAt: Date?
        }

        @Table("task_audit")
        struct TaskAudit: AuditTable, Identifiable {
            let id: Int
            var tableName: String
            var operation: String
            var oldData: String?
            var newData: String?
            var changedAt: Date
            var changedBy: String
        }

        @Table("order_audit")
        struct OrderAudit: AuditTable, Identifiable {
            let id: Int
            var tableName: String
            var operation: String
            var oldData: String?
            var newData: String?
            var changedAt: Date
            var changedBy: String
        }

        // MARK: - BEFORE Timing
        @Test
        func `BEFORE INSERT - Set creation timestamp`() async {
            let trigger = Task.createTrigger(
                timing: .before,
                event: .insert,
                function: .createdAt(column: \.createdAt)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_insert_set_createdAt"
                BEFORE INSERT
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "set_createdAt_tasks"()
                """
            }

            #expect(trigger.timing == .before)
            #expect(trigger.events.count == 1)
            #expect(trigger.events[0].kind == .insert)
        }

        @Test
        func `BEFORE UPDATE - Auto-update timestamp`() async {
            let trigger = Task.createTrigger(
                timing: .before,
                event: .update,
                function: .updateTimestamp(column: \.updatedAt)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_update_update_updatedAt"
                BEFORE UPDATE
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "update_updatedAt_tasks"()
                """
            }

            #expect(trigger.timing == .before)
            #expect(trigger.events[0].kind == .update)
        }

        @Test
        func `BEFORE UPDATE with WHEN condition`() async {
            let trigger = Task.createTrigger(
                timing: .before,
                event: .update(when: { new in new.status == "completed" }),
                function: .updateTimestamp(column: \.completedAt)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_update_update_completedAt"
                BEFORE UPDATE
                ON "tasks"
                FOR EACH ROW
                WHEN ((NEW."status") = ('completed'))
                EXECUTE FUNCTION "update_completedAt_tasks"()
                """
            }
        }

        @Test
        func `BEFORE UPDATE OF specific columns`() async {
            let trigger = Task.createTrigger(
                timing: .before,
                event: .update(of: { ($0.status, $0.priority) }),
                function: .updateTimestamp(column: \.updatedAt)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_update_update_updatedAt"
                BEFORE UPDATE OF "status", "priority"
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "update_updatedAt_tasks"()
                """
            }
        }

        @Test
        func `BEFORE DELETE - Soft delete`() async {
            let trigger = Task.createTrigger(
                timing: .before,
                event: .delete,
                function: .softDelete(
                    deletedAtColumn: \.completedAt,
                    identifiedBy: \.id
                )
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_delete_soft_delete"
                BEFORE DELETE
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "soft_delete_tasks"()
                """
            }

            #expect(trigger.timing == .before)
            #expect(trigger.events[0].kind == .delete)
        }

        @Test
        func `BEFORE with explicit trigger name`() async {
            let trigger = Task.createTrigger(
                name: "my_custom_trigger_name",
                timing: .before,
                event: .insert,
                function: .createdAt(column: \.createdAt)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "my_custom_trigger_name"
                BEFORE INSERT
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "set_createdAt_tasks"()
                """
            }

            #expect(trigger.name == "my_custom_trigger_name")
        }

        @Test
        func `BEFORE with ifNotExists - parameter stored but not in SQL`() async {
            // Note: PostgreSQL does NOT support IF NOT EXISTS for CREATE TRIGGER
            // The ifNotExists parameter is stored in the Trigger struct for application-level
            // handling (e.g., catching "already exists" errors), but doesn't affect SQL generation
            let trigger = Task.createTrigger(
                timing: .before,
                event: .insert,
                ifNotExists: true,
                function: .createdAt(column: \.createdAt)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_insert_set_createdAt"
                BEFORE INSERT
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "set_createdAt_tasks"()
                """
            }

            #expect(trigger.ifNotExists == true)
        }

        @Test
        func `BEFORE with statement level`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "validate_batch",
                "RETURN NULL;"
            )

            let trigger = Task.createTrigger(
                timing: .before,
                event: .insert,
                level: .statement,
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_before_insert_validate_batch"
                BEFORE INSERT
                ON "tasks"
                FOR EACH STATEMENT
                EXECUTE FUNCTION "validate_batch"()
                """
            }

            #expect(trigger.level == .statement)
        }

        // MARK: - AFTER Timing

        @Test
        func `AFTER INSERT - Audit logging`() async {
            let trigger = Task.createTrigger(
                timing: .after,
                event: .insert,
                function: .audit(to: TaskAudit.self)
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_after_insert_audit_to_task_audit"
                AFTER INSERT
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "audit_tasks_to_task_audit"()
                """
            }

            #expect(trigger.timing == .after)
            #expect(trigger.events[0].kind == .insert)
        }

        @Test
        func `AFTER UPDATE - Notification trigger`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "notify_task_update",
                """
                PERFORM pg_notify('task_updated', json_build_object('id', NEW.id, 'status', NEW.status)::text);
                RETURN NEW;
                """
            )

            let trigger = Task.createTrigger(
                timing: .after,
                event: .update(of: { $0.status }),
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_after_update_notify_task_update"
                AFTER UPDATE OF "status"
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "notify_task_update"()
                """
            }

            #expect(trigger.timing == .after)
        }

        @Test
        func `AFTER DELETE - Archive deleted records`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "archive_task",
                """
                INSERT INTO tasks_archive SELECT OLD.*;
                RETURN OLD;
                """
            )

            let trigger = Task.createTrigger(
                timing: .after,
                event: .delete,
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_after_delete_archive_task"
                AFTER DELETE
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "archive_task"()
                """
            }

            #expect(trigger.timing == .after)
            #expect(trigger.events[0].kind == .delete)
        }

        @Test
        func `AFTER TRUNCATE - Statement-level trigger`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "log_truncate",
                """
                INSERT INTO operation_log (table_name, operation, timestamp)
                VALUES (TG_TABLE_NAME, 'TRUNCATE', CURRENT_TIMESTAMP);
                RETURN NULL;
                """
            )

            let trigger = Task.createTrigger(
                timing: .after,
                event: .truncate,
                level: .statement,
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_after_truncate_log_truncate"
                AFTER TRUNCATE
                ON "tasks"
                FOR EACH STATEMENT
                EXECUTE FUNCTION "log_truncate"()
                """
            }

            #expect(trigger.timing == .after)
            #expect(trigger.events[0].kind == .truncate)
            #expect(trigger.level == .statement)
        }

        @Test
        func `AFTER with WHEN condition`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "notify_high_priority",
                """
                PERFORM pg_notify('high_priority_task', NEW.id::text);
                RETURN NEW;
                """
            )

            let trigger = Task.createTrigger(
                timing: .after,
                event: .insert(when: { new in new.priority > 7 }),
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_after_insert_notify_high_priority"
                AFTER INSERT
                ON "tasks"
                FOR EACH ROW
                WHEN ((NEW."priority") > (7))
                EXECUTE FUNCTION "notify_high_priority"()
                """
            }
        }

        // MARK: - INSTEAD OF Timing (Views)

        @Test
        func `INSTEAD OF INSERT - Handle view inserts`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "handle_view_insert",
                """
                INSERT INTO tasks (title, status, priority)
                VALUES (NEW.title, NEW.status, NEW.priority);
                RETURN NEW;
                """
            )

            let trigger = Task.createTrigger(
                timing: .insteadOf,
                event: .insert,
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_instead_of_insert_handle_view_insert"
                INSTEAD OF INSERT
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "handle_view_insert"()
                """
            }

            #expect(trigger.timing == .insteadOf)
            #expect(trigger.events[0].kind == .insert)
        }

        @Test
        func `INSTEAD OF UPDATE - Route view updates`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "handle_view_update",
                """
                UPDATE tasks
                SET status = NEW.status, priority = NEW.priority
                WHERE id = NEW.id;
                RETURN NEW;
                """
            )

            let trigger = Task.createTrigger(
                timing: .insteadOf,
                event: .update,
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_instead_of_update_handle_view_update"
                INSTEAD OF UPDATE
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "handle_view_update"()
                """
            }

            #expect(trigger.timing == .insteadOf)
            #expect(trigger.events[0].kind == .update)
        }

        @Test
        func `INSTEAD OF DELETE - Handle view deletes`() async {
            let function = Trigger<Task>.Function.plpgsql(
                "handle_view_delete",
                """
                DELETE FROM tasks WHERE id = OLD.id;
                RETURN OLD;
                """
            )

            let trigger = Task.createTrigger(
                timing: .insteadOf,
                event: .delete,
                function: function
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "tasks_instead_of_delete_handle_view_delete"
                INSTEAD OF DELETE
                ON "tasks"
                FOR EACH ROW
                EXECUTE FUNCTION "handle_view_delete"()
                """
            }

            #expect(trigger.timing == .insteadOf)
            #expect(trigger.events[0].kind == .delete)
        }

        // MARK: - Auto-Generated Names

        @Test
        func `Auto-generated names are stable and descriptive`() async {
            // Same call produces same name (no hash, no line numbers)
            let trigger1 = Task.createTrigger(
                timing: .before,
                event: .insert,
                function: .createdAt(column: \.createdAt)
            )

            let trigger2 = Task.createTrigger(
                timing: .before,
                event: .insert,
                function: .createdAt(column: \.createdAt)
            )

            // Names are identical and descriptive
            #expect(trigger1.name == trigger2.name)
            #expect(trigger1.name == "tasks_before_insert_set_createdAt")
        }

        @Test
        func `Auto-generated names encode timing and event`() async {
            let beforeTrigger = Task.createTrigger(
                timing: .before,
                event: .update,
                function: .updateTimestamp(column: \.updatedAt)
            )

            let afterTrigger = Task.createTrigger(
                timing: .after,
                event: .update,
                function: .updateTimestamp(column: \.updatedAt)
            )

            // Names encode timing difference
            #expect(beforeTrigger.name == "tasks_before_update_update_updatedAt")
            #expect(afterTrigger.name == "tasks_after_update_update_updatedAt")
        }

        // MARK: - Real-World Scenarios

        @Test
        func `Scenario: Complete order lifecycle`() async {
            // Set creation timestamp
            let createTrigger = Order.createTrigger(
                timing: .before,
                event: .insert,
                function: .createdAt(column: \.createdAt)
            )

            // Audit all changes
            let auditFunc = Trigger<Order>.Function.audit(to: OrderAudit.self)
            let auditInsert = Order.createTrigger(
                timing: .after,
                event: .insert,
                function: auditFunc
            )
            let auditUpdate = Order.createTrigger(
                timing: .after,
                event: .update,
                function: auditFunc
            )
            let auditDelete = Order.createTrigger(
                timing: .after,
                event: .delete,
                function: auditFunc
            )

            // Verify timing is explicit and correct
            #expect(createTrigger.timing == .before)
            #expect(auditInsert.timing == .after)
            #expect(auditUpdate.timing == .after)
            #expect(auditDelete.timing == .after)

            // Audit function is reused
            #expect(auditInsert.function.name == auditUpdate.function.name)
            #expect(auditUpdate.function.name == auditDelete.function.name)
        }

        @Test
        func `Scenario: Task priority escalation with conditional trigger`() async {
            let trigger = Task.createTrigger(
                name: "notify_priority_increase",
                timing: .after,
                event: .update(of: { $0.priority }, when: { new in new.priority > 5 }),
                function: .plpgsql(
                    "escalate_priority",
                    """
                    PERFORM pg_notify('priority_escalation', json_build_object(
                      'task_id', NEW.id,
                      'old_priority', OLD.priority,
                      'new_priority', NEW.priority
                    )::text);
                    RETURN NEW;
                    """
                )
            )

            await assertSQL(of: trigger) {
                """
                CREATE TRIGGER "notify_priority_increase"
                AFTER UPDATE OF "priority"
                ON "tasks"
                FOR EACH ROW
                WHEN ((NEW."priority") > (5))
                EXECUTE FUNCTION "escalate_priority"()
                """
            }
        }

        @Test
        func `Scenario: Multiple triggers fire in alphabetical order`() async {
            // PostgreSQL fires triggers in alphabetical order by name
            let trigger1 = Task.createTrigger(
                name: "a_first_trigger",
                timing: .before,
                event: .update,
                function: .updateTimestamp(column: \.updatedAt)
            )

            let trigger2 = Task.createTrigger(
                name: "b_second_trigger",
                timing: .before,
                event: .update,
                function: .incrementVersion(column: \.priority)
            )

            let trigger3 = Task.createTrigger(
                name: "c_third_trigger",
                timing: .before,
                event: .update,
                function: .validate("RETURN NEW;")
            )

            // Explicit names ensure predictable execution order
            #expect(trigger1.name < trigger2.name)
            #expect(trigger2.name < trigger3.name)
        }

        @Test
        func `Scenario: Combining before and after for complete workflow`() async {
            // BEFORE: Validate and set timestamp
            let beforeTrigger = Task.createTrigger(
                timing: .before,
                event: .update,
                function: .updateTimestamp(column: \.updatedAt)
            )

            // AFTER: Notify and audit
            let notifyFunc = Trigger<Task>.Function.plpgsql(
                "notify_change",
                """
                PERFORM pg_notify('task_changed', NEW.id::text);
                RETURN NEW;
                """
            )

            let afterTrigger = Task.createTrigger(
                timing: .after,
                event: .update,
                function: notifyFunc
            )

            // Clear separation of concerns
            #expect(beforeTrigger.timing == .before)  // Modifies row before commit
            #expect(afterTrigger.timing == .after)  // Notification after commit
        }
    }
}
