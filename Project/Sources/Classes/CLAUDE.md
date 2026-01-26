# Claude Code Instructions for 4D Classes

## ORDA-First Approach

All code in this directory must use modern ORDA patterns:
- Use ORDA entity/entity selection model for data access
- Be class-based and object-oriented
- Use local entity references (thread-safe)
- Use camelCase/PascalCase naming (no spaces in identifiers)

## Class File Structure

Organize class files in this order:

```4d
/*  ClassName
 Created by: Author, Created: MM/DD/YY
 ------------------
 Purpose: what this class does and why.

 Design decisions:
 - Key assumption or constraint
 - Edge case behavior
 - Threading notes if relevant
*/

// 1. Property declarations
property name : Text
property count : Integer
property isActive : Boolean
property _internal : Object          // _ prefix = private by convention

// 2. Constructor
Class constructor($name : Text; $count : Integer)
  This.name := $name
  This.count := $count
  This.isActive := True
  This._internal := {}

// 3. Computed getters/setters (grouped by property)
//mark:  --- getters/setters
Function get displayName : Text
  return This.name + " (" + String(This.count) + ")"

Function set displayName($value : Text)
  This.name := Substring($value; 1; Position(" "; $value) - 1)

// 4. Public methods (alphabetical)
//mark:  --- public methods
Function doSomething($param : Text) -> $result : Boolean
  // implementation

Function validate() -> $issues : Collection
  // validation logic

// 5. Private methods (_ prefix, alphabetical)
//mark:  --- private methods
Function _initialize()
  // internal setup

Function _processData($data : Object)
  // internal logic
```

## Class Header Comments

Every class file should begin with a block comment containing:
- Class name
- Author and creation date
- Purpose (1-3 sentences)
- Design decisions and assumptions (bullet list)
- Optional: link to relevant 4D documentation

```4d
/*  Coords class
 Created by: Author, Created: MM/DD/YY
 ------------------
A base class for objects that have spatial coordinates.

Coordinates are stored in data collection:
[x; y; width; height; z]

Design decisions and assumptions:
- Coordinate system: origin (0,0) is top-left, x increases rightward, y increases downward
- width and height are always stored as positive values (Abs is applied in setters)
- All integer math may result in rounding for center calculations

https://developer.4d.com/docs/relevant-section
*/
```

## Property Declarations

Declare all properties at the top of the class, before the constructor:

```4d
// Typed properties
property name : Text
property count : Integer
property price : Real
property isValid : Boolean
property items : Collection
property config : Object

// Entity/entity selection types
property entity : cs.customerEntity
property customers : cs.customerSelection

// Private properties (convention: _ prefix)
property _cache : Object
property _initialized : Boolean
```

## Computed Properties (Getters/Setters)

Use getters and setters for:
- Validation on assignment (setters)
- Calculated/derived values (getters)
- Encapsulating internal storage format

```4d
// Simple getter
Function get fullName : Text
  return This.firstName + " " + This.lastName

// Getter accessing internal storage
Function get x : Integer
  return This.data[0]

// Setter with validation
Function set width($value : Integer)
  This.data[2] := Abs($value)  // always positive

// Setter with constrained values
Function set destination($value : Text)
  Case of
    : ($value = "detailScreen")
      This._form.destination := "detailScreen"
    : ($value = "listScreen")
      This._form.destination := "listScreen"
    Else
      This._form.destination := "detailScreen"  // default for invalid input
  End case

// Setter that silently rejects invalid values
Function set windowSizingX($value : Text)
  If ($value = "fixed") | ($value = "variable")
    This._form.windowSizingX := $value
  End if
```

## Inheritance

```4d
// Parent class: Animal.4dm
property name : Text

Class constructor($name : Text)
  This.name := $name

Function speak() -> $result : Text
  return This.name

// Child class: Dog.4dm
Class extends Animal

Class constructor($name : Text)
  Super($name)

// Override with Super call
Function speak() -> $result : Text
  return Super.speak() + " says Woof"

// Override serialization
Function toObject() : Object
  var $obj : Object := Super.toObject()
  $obj.breed := This.breed
  return $obj

// Override validation (accumulate parent issues)
Function validate() : Collection
  var $issues : Collection := Super.validate()
  // add child-specific checks
  If (This.breed = "")
    $issues.push({level: "warning"; message: "No breed specified"})
  End if
  return $issues
```

## Common Patterns

### Validation Pattern

Return a collection of `{level, message}` objects:

```4d
Function validate() -> $issues : Collection
  $issues := []

  If (This.name = "")
    $issues.push({level: "error"; message: "Name cannot be empty"})
  End if

  If (This.type = "")
    $issues.push({level: "error"; message: "Type cannot be empty"})
  End if

  If (This.width <= 0)
    $issues.push({level: "warning"; message: "Width is zero or negative"})
  End if

  return $issues
```

### Serialization Pattern (toObject/fromObject)

```4d
// Serialize to plain object (for JSON output)
Function toObject() -> $obj : Object
  $obj := {}
  $obj.type := This.type
  $obj.name := This.name
  $obj.left := This.left
  $obj.top := This.top

  If (This.events.length > 0)
    $obj.events := This.events.copy()
  End if

  return $obj

// Deserialize from plain object
Function fromObject($obj : Object)
  If ($obj.left # Null)
    This.left := $obj.left
  End if
  If ($obj.top # Null)
    This.top := $obj.top
  End if
  If ($obj.events # Null)
    This.events := $obj.events.copy()
  End if
```

### Clone Pattern

```4d
Function clone() -> $clone : cs.MyClass
  $clone := cs.MyClass.new(This.name; This.x; This.y; This.width; This.height)
  $clone.type := This.type
  $clone.events := This.events.copy()       // copy collections
  $clone._defaults := OB Copy(This._defaults) // copy objects
  return $clone
```

### Factory Method Pattern

```4d
// Static-like factory method
Function newFromProductCode($code : Text) -> $obj : cs.ProductCode
  $obj := cs.ProductCode.new($code)
  If (Not($obj.isValid()))
    $obj := Null
  End if
  return $obj

// Factory that creates type-specific subclasses
Function _createWidgetFromDef($name : Text; $def : Object) -> $widget : cs._widget_base
  Case of
    : ($def.type = "button")
      var $btn : cs._widget_button := cs._widget_button.new($name; $def.text; $def.left; $def.top; $def.width; $def.height)
      $btn.fromObject($def)
      $widget := $btn
    : ($def.type = "input")
      var $inp : cs._widget_input := cs._widget_input.new($name; $def.left; $def.top; $def.width; $def.height)
      $inp.fromObject($def)
      $widget := $inp
    Else
      // generic fallback
      $widget := cs._widget_base.new($name; $def.left; $def.top; $def.width; $def.height)
      $widget.type := $def.type
  End case
  return $widget
```

### Method Chaining Pattern

Return `This` from mutating methods to enable chaining:

```4d
Function addPage($pageIndex : Integer) -> $this : cs.FormBuilder
  // ... add page logic ...
  return This

Function removeObject($name : Text) -> $this : cs.FormBuilder
  // ... remove logic ...
  return This

// Usage:
$builder.addPage(2).addObject(1; "btn"; $def).removeObject("old")
```

### Status Return Pattern

```4d
Function save() -> $status : Object
  $status := {success: False; error: ""}

  If (Not(This.validate()))
    $status.error := "Validation failed"
    return $status
  End if

  $status := This.entity.save()
  return $status
```

## Anti-Patterns

```4d
// DO NOT use global variables
<>currentOrder := $order       // BAD
This.currentOrder := $order    // GOOD (class property)

// DO NOT use process arrays for data
ARRAY TEXT(aCustomers; 0)              // BAD
$customers := ds.customer.all()        // GOOD

// DO NOT use classic record commands in new code
QUERY([customer]; [customer]name = $name)  // BAD
$entity := ds.customer.query("name = :1"; $name).first()  // GOOD

// DO NOT use old-style declarations
C_TEXT($name)                  // BAD
var $name : Text               // GOOD

// DO NOT mutate shared state
Process variable := $data      // BAD - thread unsafe
This._data := $data            // GOOD - instance scoped
```
