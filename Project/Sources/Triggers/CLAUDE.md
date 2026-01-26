# Claude Code Instructions for 4D Triggers

## Overview

Triggers are special methods that 4D calls automatically before certain database events on a table. They are used for data validation, logging, computed fields, and enforcing business rules at the data layer.

Each table can have one trigger. The trigger file is named after the table (e.g., `[customer]` trigger is in the Triggers directory).

## Trigger Structure

```4d
// Trigger for [tableName]

var $event : Integer := Database event

Case of
  : ($event = On Saving New Record Event)
    // Before saving a new record
    This._beforeCreate()

  : ($event = On Saving Existing Record Event)
    // Before saving an existing record
    This._beforeUpdate()

  : ($event = On Deleting Record Event)
    // Before deleting a record
    This._beforeDelete()

  : ($event = On Saving Record Event)
    // Before any save (new or existing)
    This._beforeSave()
End case
```

## Database Event Constants

| Constant | Value | Fires When |
|----------|-------|-----------|
| `On Saving New Record Event` | 1 | Before saving a new record |
| `On Saving Existing Record Event` | 2 | Before saving an existing record |
| `On Deleting Record Event` | 3 | Before deleting a record |
| `On Saving Record Event` | (1 or 2) | Before any save (covers both new and existing) |

## Common Trigger Patterns

### Validation

```4d
: ($event = On Saving Record Event)
  // Validate required fields
  If ([customer]name = "")
    CANCEL  // Abort the save
    // Optionally set an error message
  End if
```

### Timestamps

```4d
: ($event = On Saving New Record Event)
  [customer]createdDate := Current date
  [customer]createdTime := Current time
  [customer]modifiedDate := Current date

: ($event = On Saving Existing Record Event)
  [customer]modifiedDate := Current date
  [customer]modifiedTime := Current time
```

### Computed Fields

```4d
: ($event = On Saving Record Event)
  // Update computed totals
  [order]totalAmount := This._calculateTotal()
  [order]taxAmount := [order]totalAmount * [order]taxRate
```

### Audit Logging

```4d
: ($event = On Deleting Record Event)
  // Log the deletion before it happens
  This._logDeletion([customer]ID; Current user)
```

## Guidelines

- Keep triggers fast -- they run synchronously on every save/delete
- Triggers use classic 4D syntax (current record model) since they fire at the record level
- Use `CANCEL` inside a trigger to abort the operation
- Do not display UI (ALERT, DIALOG) inside triggers -- they may run in server context
- Triggers fire for both UI operations and ORDA `.save()`/`.drop()` calls
- Test triggers thoroughly -- a bug here affects every save operation on the table
- Consider whether business logic belongs in a trigger (data layer) or a class method (application layer)
- Triggers are one of the few places where classic 4D field syntax (`[table]field`) is still appropriate, since they operate on current records by design
