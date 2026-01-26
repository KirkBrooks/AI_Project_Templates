# Claude Code Instructions for 4D Methods

## Method Types

4D has several kinds of methods:
- **Project methods** - standalone procedures/functions callable from anywhere
- **Test methods** - project methods prefixed with `Test_` that validate code
- **Form methods** - bound to a specific form (event handler)
- **Object methods** - bound to a specific form object (button, input, etc.)

This directory contains **project methods** and **test methods**.

## Method File Format

```4d
//%attributes = {}
/* Purpose: brief description of what this method does
 ------------------
MethodName ($param1 : Type; $param2 : Type) -> $result : Type
 Created by: Author, Created: MM/DD/YY
*/

// method body
var $param1 : Type
var $param2 : Type

// implementation...
```

The `//%attributes = {}` line is managed by 4D. The block comment header is a convention for documentation.

## Method Naming Conventions

### Module Pattern

Methods belonging to a logical module use a short uppercase prefix followed by an underscore:

```
[MODULE]_[camelCase subject]_[action or verb]
```

Examples:
- `MATH_divide` - Math module: division utility
- `ORD_newOrder` - Order module: create new order
- `SHIP_newShipment` - Shipping module: create shipment
- `TRXN_status_update` - Transaction module: update status

### General Pattern

```
[PascalCase subject]_[action or verb]
```

Examples:
- `InventoryExceptions_report` - generate exceptions report
- `InventoryExceptionsReport_print` - print the report
- `InventoryExceptions_delete` - delete exceptions
- `InventoryExceptionsForm_show` - display the form

### Test Method Pattern

```
Test_[ClassName or Subject]
```

Examples:
- `Test_Coords` - tests for Coords class
- `Test_FormBuilder` - tests for FormBuilder class
- `Test_widget_base` - tests for _widget_base class
- `Test_widgets` - tests for multiple widget subclasses

## Test Method Format

Test methods are the standard way to verify code correctness in 4D. They use `ASSERT()` and follow a consistent structure:

```4d
//%attributes = {}
/* Purpose: test method for ClassName
 ------------------
Test_ClassName ()
 Created by: Author, Created: MM/DD/YY
*/

var $obj : cs.ClassName

//mark:  --- test constructor
$obj := cs.ClassName.new("test"; 42)
ASSERT($obj.name = "test"; "name should be 'test' but is " + $obj.name)
ASSERT($obj.count = 42; "count should be 42 but is " + String($obj.count))

//mark:  --- test computed getters
$obj := cs.ClassName.new(10; 20; 100; 50)
ASSERT($obj.left = 10; "left should be 10 but is " + String($obj.left))
ASSERT($obj.right = 110; "right should be 110 but is " + String($obj.right))

//mark:  --- test setters
$obj := cs.ClassName.new(0; 0; 100; 100)
$obj.width := -50
ASSERT($obj.width = 50; "width should be absolute value 50 but is " + String($obj.width))

//mark:  --- test validation
$obj := cs.ClassName.new(""; 0; 0; 0; 0)
var $issues : Collection := $obj.validate()
ASSERT($issues.length >= 1; "validation should have issues for empty name")
var $hasNameError : Boolean := False
var $issue : Object
For each ($issue; $issues)
  If ($issue.message = "Name cannot be empty")
    $hasNameError := True
  End if
End for each
ASSERT($hasNameError; "validation should report empty name error")

//mark:  --- test serialization round-trip
$obj := cs.ClassName.new("test"; 10; 20; 100; 50)
$obj.type := "button"
$obj.addEvent("onClick")
var $serialized : Object := $obj.toObject()
ASSERT($serialized.type = "button"; "toObject type should be 'button'")
ASSERT($serialized.left = 10; "toObject left should be 10")

// test fromObject
var $obj2 : cs.ClassName := cs.ClassName.new("test2"; 0; 0; 0; 0)
$obj2.fromObject($serialized)
ASSERT($obj2.left = 10; "fromObject left should be 10")

//mark:  --- test clone
$obj := cs.ClassName.new("original"; 10; 20; 100; 50)
var $clone : cs.ClassName := $obj.clone()
ASSERT($clone.name = "original"; "clone name should match")
$clone.x := 999
ASSERT($obj.x = 10; "original should be unchanged after modifying clone")

//mark:  --- test edge cases
// empty collections
$obj.alignLeft([])  // should return without error

// boundary values
$obj := cs.ClassName.new(0; 0; 0; 0)
ASSERT($obj.width = 0; "zero width should be allowed")

//mark:  --- done
ALERT(Current method name + " - all tests done.")
```

### Test Method Principles

1. **Structure**: Use `//mark:` sections to organize tests by feature area
2. **Fresh state**: Create a new instance for each test section to avoid state leakage
3. **ASSERT messages**: Always include both the expected AND actual value:
   ```4d
   // GOOD - shows what went wrong
   ASSERT($obj.x = 10; "$obj.x should be 10 but is " + String($obj.x))

   // BAD - no diagnostic info
   ASSERT($obj.x = 10; "x is wrong")
   ```
4. **Coverage**: Test in this order:
   - Constructor and defaults
   - Getters and computed properties
   - Setters (including validation/rejection of invalid values)
   - Public methods
   - Validation
   - Serialization (toObject/toJson)
   - Deserialization (fromObject/newFromJson)
   - Clone/copy (verify deep independence)
   - Edge cases (empty collections, null inputs, boundary values)
5. **Completion**: Every test method ends with:
   ```4d
   //mark:  --- done
   ALERT(Current method name + " - all tests done.")
   ```

### Testing Multiple Related Classes

When testing subclasses or related classes, group them in a single test method with major section separators:

```4d
//mark:  ============ _widget_button tests ============
// ... button tests ...

//mark:  ============ _widget_input tests ============
// ... input tests ...

//mark:  ============ _widget_text tests ============
// ... text tests ...

//mark:  --- done
ALERT(Current method name + " - all tests done.")
```

## Parameters and Return Values

```4d
// Method with parameters and return value
// Declare in header comment, then use var

/* MethodName ($input : Text; $count : Integer) -> $result : Collection */

var $input : Text
var $count : Integer

// ... process ...

$0 := $result  // classic return (or use return in functions)
```

### In class methods, use typed parameters:

```4d
Function calculate($price : Real; $quantity : Integer) -> $total : Real
  $total := $price * $quantity
  return $total
```

### Optional parameters:

```4d
Function setup($name : Text; $options : Object)
  If (Count parameters < 2) | ($options = Null)
    $options := {}  // use defaults
  End if
```

## Migration Strategy

When touching existing classic methods, assess priority for ORDA migration:

### High Priority - Migrate Now
- Contains magic numbers (hardcoded values)
- Used by new ORDA code
- Frequently called
- Thread-unsafe (uses global state)

### Medium Priority - Refactor Over Time
- Long methods (>200 lines)
- Complex business logic
- Validated but inflexible

### Low Priority - Leave Alone
- Simple utilities that work
- Rarely called
- Stable and tested

### Migration Pattern
```4d
// BEFORE (Classic)
QUERY([customer]; [customer]status = "Active")
SELECTION TO ARRAY([customer]name; aNames)

// AFTER (ORDA)
var $names : Collection
$names := ds.customer.query("status = :1"; "Active").toCollection().extract("name")
```
