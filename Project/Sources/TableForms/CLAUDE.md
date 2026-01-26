# Claude Code Instructions for 4D Table Forms (Legacy)

## Overview

This directory contains **legacy array-based forms** built with Classic 4D patterns. These forms work with current records and arrays rather than ORDA entities.

**DO NOT create new forms here.** New forms should be created in `Forms/` using class-based controllers and ORDA entities.

**When working here:** Preserve existing behavior. Stability > elegance. These forms work and users know them.

## When to Migrate vs Leave Alone

### Migrate to Forms/ When:
- Major redesign is needed
- Adding significant new functionality
- Performance issues with array approach
- Need thread-safety (ORDA required)

### Leave Alone When:
- Form is stable and working
- Only minor cosmetic changes needed
- Risk > benefit
- Limited time/resources

## Common Gotchas

### 1. Current Record Confusion

Multiple forms/processes can change the current record out from under you:

```4d
// Process A
QUERY([workOrder]; [workOrder]woid = 100)
[workOrder]status := "Active"

// Process B (simultaneously)
QUERY([workOrder]; [workOrder]woid = 200)

// Process A
SAVE RECORD([workOrder])  // DANGER: saves record 200, not 100!
```

### 2. Array Synchronization

Related arrays must stay in sync -- same size, same index meaning:

```4d
// BAD - arrays out of sync
INSERT IN ARRAY(aProductCodes; $size)
// FORGOT: INSERT IN ARRAY(aQuantities; $size)
// Now aProductCodes.length != aQuantities.length -> crash

// GOOD - always modify all related arrays together
INSERT IN ARRAY(aProductCodes; $size)
INSERT IN ARRAY(aQuantities; $size)
INSERT IN ARRAY(aPrices; $size)
```

### 3. Unsaved Changes on Close

```4d
// Check Modified record() before allowing close
If (Modified record([workOrder]))
  $save := Request("Save changes?"; "Yes"; "No")
  If ($save = "Yes")
    SAVE RECORD([workOrder])
  End if
End if
CANCEL
```

## Maintenance Guidelines

### Do This
- Preserve existing behavior exactly
- Keep related arrays synchronized
- Validate before saving
- Check `Modified record()` before closing
- Document any changes with date and initials
- Test with real data

### Do Not Do This
- Mix Classic and ORDA in the same form
- Modify without understanding current behavior first
- Break array synchronization
- Change the form without testing all paths
- Remove validation without replacement

## Documentation Pattern for Complex Forms

Add a header comment to legacy form methods:

```4d
// Method: "workOrder Form Controller"
/*
PURPOSE:
  Main work order entry form (Legacy Classic 4D)

ARRAYS USED:
  aProductCodes - Line item product codes
  aQuantities - Line item quantities
  aPrices - Calculated prices (synchronized with above)

VALIDATION:
  - Calls "Val Product Code" for product validation
  - "workOrder Exit Check" for field-level validation

RELATED METHODS:
  - OE Total the Lineitems (called on save)
  - Val Product Code
  - workOrder Exit Check

MIGRATION STATUS:
  - Legacy form - working but should be migrated to Forms/
  - New version: Forms/WorkOrder_Entry (status: not started)

LAST MODIFIED:
  Author MM/DD/YY - Description of change
*/
```

## Migration Checklist

When migrating a legacy form to `Forms/`:

1. Create new form in `Forms/` directory (do not modify original)
2. Create class-based controller
3. Replace arrays with entity selections:
   ```4d
   // OLD (array-based):
   ARRAY TEXT(aCustomers; 0)
   SELECTION TO ARRAY([customer]name; aCustomers)

   // NEW (entity selection):
   Form.customers := ds.customer.all().orderBy("name")
   ```
4. Replace field references with entity properties:
   ```4d
   // OLD:
   [workOrder]status := "Active"

   // NEW:
   Form.entity.status := "Active"
   ```
5. Test side-by-side before switching users
6. Keep legacy form as fallback for 1-2 releases
