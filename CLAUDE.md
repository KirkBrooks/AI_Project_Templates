# Claude Code Instructions for 4D Projects

This is a 4D database project. 4D is a full-stack application platform with its own language, database engine (ORDA), form system, and server architecture. This document provides the language reference and conventions needed to write correct, modern 4D code.

## How to Use These Templates

Copy this directory structure into the root of any new 4D project. The `CLAUDE.md` files in subdirectories provide context-specific guidance for Classes, Methods, Forms, and other source directories.

```
YourProject/
  CLAUDE.md                              <-- this file (project root)
  Project/
    Sources/
      Classes/CLAUDE.md                  <-- class-specific guidance
      Methods/CLAUDE.md                  <-- method-specific guidance
      Forms/CLAUDE.md                    <-- modern form guidance
      TableForms/CLAUDE.md               <-- legacy form guidance
      DatabaseMethods/CLAUDE.md          <-- database method guidance
      Triggers/CLAUDE.md                 <-- trigger guidance
```

---

## 4D Language Reference

### Source Files

4D source files use the `.4dm` extension. They are plain text files with no required encoding header, though UTF-8 is standard.

**Classes** live in `Project/Sources/Classes/ClassName.4dm`
**Methods** live in `Project/Sources/Methods/MethodName.4dm`
**Forms** live in `Project/Sources/Forms/FormName/form.4DForm` (JSON)

### Comments

```4d
// Single line comment

/* Multi-line
   comment block */

// Method header (standard format)
//%attributes = {}
/* Purpose: brief description
 ------------------
MethodName ()
 Created by: Author, Created: MM/DD/YY
*/
```

### Section Markers

Use `//mark:` to create navigable sections in the 4D IDE:

```4d
//mark:  --- section name
//mark:  ============ major section ============
```

### Variable Declarations

All local variables use `var` and require type declarations. Local variables are prefixed with `$`.

```4d
// Scalar types
var $name : Text
var $count : Integer
var $price : Real
var $isValid : Boolean
var $today : Date
var $now : Time
var $data : Object
var $items : Collection
var $pic : Picture
var $ptr : Pointer
var $blob : Blob

// Typed entity/entity selection
var $entity : cs.customerEntity
var $selection : cs.customerSelection

// 4D system types
var $file : 4D.File
var $folder : 4D.Folder
var $signal : 4D.Signal

// Inline initialization
var $count : Integer := 0
var $name : Text := "default"
var $items : Collection := []
var $obj : Object := {}

// Multiple variables of same type
var $left; $top; $width; $height : Integer
```

### Data Types

| Type | Description | Default |
|------|-------------|---------|
| `Text` | Unicode string | `""` |
| `Integer` | 32-bit signed integer | `0` |
| `Real` | 64-bit floating point | `0` |
| `Boolean` | True/False | `False` |
| `Date` | Calendar date | `!00-00-00!` |
| `Time` | Time duration | `?00:00:00?` |
| `Object` | Key-value object | `Null` |
| `Collection` | Ordered array of values | `Null` |
| `Picture` | Image data | (empty) |
| `Pointer` | Reference to variable/field | `Nil` |
| `Blob` | Binary data | (empty) |
| `Variant` | Any type | `Undefined` |

### Operators

```4d
// Comparison
=    // equal
#    // not equal (NOT != or <>)
<    >    <=    >=

// Logical
&    // AND (NOT && except in specific contexts)
|    // OR (NOT ||)
Not($bool)  // NOT operator (function form)

// Arithmetic
+  -  *  /
%  // modulo

// String
$a + $b           // concatenation
$a * $n           // repeat string n times
$str[[$i]]        // character at position (1-based, double brackets)
Position($find; $str)  // find substring (returns 0 if not found)
Length($str)
Substring($str; $start; $length)

// Assignment
$x := 5          // standard assignment with space before colon
$x += 1          // compound assignment (4D v20+)
$x -= 1
```

**Important:** 4D uses `:=` for assignment, not `=`. The `=` is comparison only. Always include a space before the `:=` (e.g., `$x:=5` or `$x := 5`).

### Control Structures

```4d
// If/Else
If ($condition)
  // code
Else
  // code
End if

// Case of
Case of
  : ($value = "a")
    // code
  : ($value = "b")
    // code
  Else
    // default
End case

// For loop (1-based by convention)
For ($i; 1; $count)
  // code
End for

// For loop with step
For ($i; $start; $end; $step)
  // code
End for

// For each (collections and objects)
For each ($item; $collection)
  // $item is the current element
End for each

For each ($key; $object)
  // $key is the property name
End for each

// While
While ($condition)
  // code
End while

// Repeat Until
Repeat
  // code (always executes at least once)
Until ($condition)
```

**Important:** `For each` iterates object **property names** (Text), not values. Access values with `$object[$key]`.

### Early Return

```4d
// 4D supports early return from anywhere
Function doSomething() -> $result : Boolean
  If ($invalid)
    return False
  End if
  // continue processing
  return True
```

### Null and Undefined Checks

```4d
// Null check for objects, entities, collections
If ($obj = Null)
If ($obj # Null)

// Value type check
If (Value type($var) = Is undefined)
If (Value type($var) = Is text)
If (Value type($var) = Is longint)  // covers Integer
If (Value type($var) = Is real)
If (Value type($var) = Is boolean)
If (Value type($var) = Is object)
If (Value type($var) = Is collection)

// Count parameters (in functions/methods)
If (Count parameters >= 2)
  // second parameter was provided
End if
```

### String Handling

```4d
var $str : Text

// String functions
$len := Length($str)
$upper := Uppercase($str)
$lower := Lowercase($str)
$trimmed := Trim($str)   // 4D v20+, otherwise use custom

// Substring
$sub := Substring($str; $start; $length)

// Find
$pos := Position($find; $str)  // 0 if not found, 1-based position

// Replace
$result := Replace string($str; $find; $replace)

// Convert
$str := String($number)        // number to text
$str := String($date; Internal date short)  // date to text
$num := Num($str)              // text to number

// Character access (1-based, double brackets)
$char := $str[[$i]]

// Concatenation
$full := $first + " " + $last

// Multi-line strings (line continuation with \)
$long := "first part " + \
  "second part " + \
  "third part"
```

### Line Continuation

Use `\` at the end of a line to continue to the next line:

```4d
var $collection : Collection := [\
  {name: "first"; value: 1}; \
  {name: "second"; value: 2}; \
  {name: "third"; value: 3}]
```

### Objects

```4d
// Create objects
var $obj : Object := {}
var $obj : Object := {name: "test"; count: 5; active: True}

// Access properties
$obj.name := "new name"
$value := $obj.name
$value := $obj["property name"]  // bracket notation for dynamic/space keys

// Check property existence
If ($obj.myProp # Null)
  // property exists and is not null
End if

// Object keys
var $keys : Collection := OB Keys($obj)

// Copy
var $copy : Object := OB Copy($obj)        // shallow copy
var $deep : Object := OB Copy($obj; ck shared)  // deep/shared copy

// Remove property
OB REMOVE($obj; "propertyName")

// Object notation in JSON context
// 4D uses semicolons (;) as separators in object/collection literals, NOT commas
$obj := {key1: "value1"; key2: "value2"}  // correct
// $obj := {key1: "value1", key2: "value2"}  // WRONG - 4D uses semicolons
```

**Critical:** 4D uses **semicolons** (`;`) to separate object properties and collection elements in literal notation, function parameters, and statement arguments. Commas are NOT used as separators.

### Collections

```4d
// Create
var $col : Collection := []
var $col : Collection := [1; 2; 3]
var $col : Collection := ["a"; "b"; "c"]

// Access (0-based)
$first := $col[0]
$last := $col[$col.length - 1]

// Methods
$col.push($item)                    // add to end
$col.insert($index; $item)          // insert at index
$col.remove($index)                 // remove at index
$col.pop()                          // remove and return last
$col.shift()                        // remove and return first
$col.unshift($item)                 // add to beginning
$col.indexOf($item)                 // -1 if not found
$col.length                         // count of items
$col.copy()                         // shallow copy
$col.join($separator)               // join as text

// Functional methods
$mapped := $col.map(Formula($1.value * 2))
$filtered := $col.filter(Formula($1.value > 10))
$sum := $col.reduce(Formula($1.accumulator + $1.value); 0)
$total := $col.sum()                // numeric sum
$avg := $col.average()              // numeric average
$min := $col.min()
$max := $col.max()

// Query (for collections of objects)
$found := $col.query("name = :1"; "test")
$found := $col.query("age > :1 AND status = :2"; 18; "active")

// Sort
$sorted := $col.orderBy("name asc")
$sorted := $col.orderBy("name asc; date desc")

// Collection of objects
$col := [{name: "Alice"; age: 30}; {name: "Bob"; age: 25}]
$names := $col.extract("name")  // ["Alice"; "Bob"]
$first := $col.first()
$last := $col.last()

// Distinct values
$unique := $col.distinct()
$uniqueNames := $col.distinct("name")
```

### Formula Objects

Formulas are 4D's closures/lambdas:

```4d
// Inline formula
$doubled := $col.map(Formula($1.value * 2))

// Named formula
var $formula : 4D.Function := Formula(Uppercase($1))
$result := $formula.call(Null; "hello")  // "HELLO"

// Formula with This context
$col.forEach(Formula(This.process($1.value)))
```

---

## ORDA (Object Relational Data Access)

ORDA is 4D's modern data access layer. It replaces classic record-based commands with an object-oriented entity model.

### Core Concepts

```4d
// Datastore - entry point
ds                                    // local datastore
ds.tableName                          // dataclass (table)

// Dataclass operations
var $entity : cs.customerEntity
var $selection : cs.customerSelection

// Query
$selection := ds.customer.query("name = :1"; "Smith")
$selection := ds.customer.query("age > :1 AND city = :2"; 25; "Portland")
$entity := ds.customer.query("email = :1"; $email).first()

// Get by primary key
$entity := ds.customer.get($pk)

// All records
$all := ds.customer.all()

// New entity
$entity := ds.customer.new()
$entity.name := "New Customer"
$entity.email := "new@example.com"

// Save
var $status : Object := $entity.save()
If ($status.success)
  // saved successfully
Else
  ALERT("Error: " + $status.errors[0].message)
End if

// Delete
$status := $entity.drop()

// Reload from database
$entity.reload()

// Entity selection operations
$sorted := $selection.orderBy("name asc")
$first := $selection.first()
$count := $selection.length

// Relations (lazy loading)
$customer := $order.customer          // many-to-one
$orders := $customer.orders           // one-to-many

// Chaining
$result := ds.order.query("status = :1"; "active").orderBy("date desc").first()
```

### ORDA vs Classic (Migration Reference)

```4d
// Classic (AVOID in new code)
QUERY([customer]; [customer]name = $name)
CREATE RECORD([customer])
[customer]name := "New"
SAVE RECORD([customer])

// ORDA (USE THIS)
$entity := ds.customer.query("name = :1"; $name).first()
$entity := ds.customer.new()
$entity.name := "New"
$entity.save()
```

---

## Class-Based Development

### Class Structure

```4d
// File: Project/Sources/Classes/MyClass.4dm

// Header comment
/*  MyClass
 Created by: Author, Created: MM/DD/YY
 ------------------
 Brief description of the class purpose.
*/

// Property declarations (at top of file)
property name : Text
property count : Integer
property isActive : Boolean
property _internalState : Object    // _ prefix = private by convention

// Constructor
Class constructor($name : Text; $count : Integer)
  This.name := $name
  This.count := $count
  This.isActive := True
  This._internalState := {}

// Computed getters
Function get fullName : Text
  return This.name + " (" + String(This.count) + ")"

// Computed setters
Function set fullName($value : Text)
  This.name := Substring($value; 1; Position(" "; $value) - 1)

// Public methods (alphabetical preferred)
Function doSomething($param : Text) -> $result : Object
  // implementation
  return {success: True}

Function validate() -> $isValid : Boolean
  return This.name # ""

// Private methods (_ prefix)
Function _initialize()
  // internal setup

Function _processData($data : Object)
  // internal processing
```

### Inheritance

```4d
// Parent: Animal.4dm
property name : Text
property sound : Text

Class constructor($name : Text)
  This.name := $name
  This.sound := ""

Function speak() -> $result : Text
  return This.name + " says " + This.sound

// Child: Dog.4dm
Class extends Animal

Class constructor($name : Text)
  Super($name)
  This.sound := "Woof"

// Override parent method
Function speak() -> $result : Text
  return Super.speak() + "!"
```

### Singleton Pattern

```4d
// Use shared singleton for global state
shared singleton Class constructor()
  // initialized once, shared across all contexts

// Access with
$instance := cs.MySingleton.me
```

### Class Naming Conventions

| Pattern | Usage |
|---------|-------|
| `PascalCase` | Public classes (FormBuilder, Coords) |
| `_lowercase` | Private/internal classes (_widget_base, _widget_button) |
| `cs.ClassName.new()` | Instantiation |
| `cs.ClassName.me` | Singleton access |

---

## File and Folder Operations

### File and Folder Commands

Always use `File()` and `Folder()` commands for cross-platform compatibility. Never construct raw paths manually.

```4d
// Filesystem paths (4D constants)
var $file : 4D.File
var $folder : 4D.Folder

$file := File("/DATA/myfile.txt")
$folder := Folder("/RESOURCES/")
$folder := Folder("/PROJECT/")

// Common filesystem constants
// /DATA       - database data folder
// /RESOURCES  - project Resources folder
// /PROJECT    - project root
// /LOGS       - logs folder
// /PACKAGE    - application package folder
```

### Component vs Host Paths

When code runs in a **component**, File/Folder default to the component's own paths. Add `*` to reference the **host** database:

```4d
// Component context:
$file := File("/RESOURCES/data.json")       // component's Resources
$file := File("/RESOURCES/data.json"; *)    // HOST's Resources

// Host context (both equivalent):
$file := File("/RESOURCES/data.json")
$file := File("/RESOURCES/data.json"; *)
```

### Platform Path Conversion

Filesystem path references (`/PROJECT/`, `/RESOURCES/`, etc.) are **top-level** in 4D's virtual filesystem. They have no parent -- `.parent` returns **Null**. To access the real filesystem hierarchy (e.g., to get the database root folder), convert to a platform path first:

```4d
// WRONG - .parent is Null on filesystem path references
$dbRoot := Folder("/PROJECT/").parent  // Null!

// CORRECT - convert to platform path, then navigate
$dbRoot := Folder(Folder("/PROJECT/").platformPath; fk platform path).parent

// General pattern for platform path conversion
$platformPath := Folder("/RESOURCES/").platformPath
$folder := Folder($platformPath; fk platform path)

// Once converted, .parent and full navigation work normally
$subFolder := $folder.folder("Images")
$file := $folder.file("config.json")
$parent := $folder.parent  // works because $folder is a platform path folder
```

**Rule:** Always convert filesystem path references to platform paths before using `.parent` or navigating outside the reference's scope.

### File Operations

```4d
// Read text file
var $text : Text := $file.getText("UTF-8")

// Write text file
$file.setText($content; "UTF-8")

// Check existence
If ($file.exists)
  // file exists
End if

// File properties
$name := $file.name          // "config.json"
$ext := $file.extension      // ".json"
$path := $file.path          // POSIX path
$platform := $file.platformPath  // system path

// Copy, move, rename, delete
$file.copyTo($targetFolder)
$file.moveTo($targetFolder)
$file.rename("newname.json")
$file.delete()
```

---

## JSON Handling

```4d
// Parse JSON text to object
var $obj : Object := JSON Parse($jsonText)

// Stringify object to JSON
var $json : Text := JSON Stringify($obj)
var $pretty : Text := JSON Stringify($obj; *)  // pretty-printed

// Validate JSON
var $valid : Boolean := JSON Validate($jsonText; $schema)
```

---

## Error Handling

### Try/Catch (4D v20+)

```4d
Try
  $result := riskyOperation()
Catch
  $error := Last errors
  // handle error
End try
```

### Status Object Pattern

```4d
// Return status objects from operations
Function save() -> $status : Object
  $status := {success: False; error: ""}

  If (Not(This.validate()))
    $status.error := "Validation failed"
    return $status
  End if

  $status := This.entity.save()
  return $status
```

### Validation Pattern

Return collections of issue objects for structured validation:

```4d
Function validate() -> $issues : Collection
  $issues := []

  If (This.name = "")
    $issues.push({level: "error"; message: "Name cannot be empty"})
  End if

  If (This.count < 0)
    $issues.push({level: "warning"; message: "Count is negative"})
  End if

  return $issues
```

---

## Testing Conventions

### Test Method Format

Test methods are prefixed with `Test_` and use `ASSERT()` for validation:

```4d
//%attributes = {}
/* Purpose: test method for MyClass
 ------------------
Test_MyClass ()
 Created by: Author, Created: MM/DD/YY
*/

var $obj : cs.MyClass

//mark:  --- test constructor
$obj := cs.MyClass.new("test"; 42)
ASSERT($obj.name = "test"; "name should be 'test' but is " + $obj.name)
ASSERT($obj.count = 42; "count should be 42 but is " + String($obj.count))

//mark:  --- test validation
$obj := cs.MyClass.new(""; 0)
var $issues : Collection := $obj.validate()
ASSERT($issues.length >= 1; "validation should have issues for empty name")

//mark:  --- test edge cases
// negative values
$obj.count := -5
ASSERT($obj.count = 5; "count should be absolute value")

// null input
$obj := cs.MyClass.new(Null; 0)
ASSERT($obj.name = ""; "null name should default to empty string")

//mark:  --- done
ALERT(Current method name + " - all tests done.")
```

### Testing Principles

- One test method per class or logical group
- Use `//mark:` sections to organize tests by feature
- ASSERT messages should state the expectation AND the actual value
- Test default values, setters, edge cases, validation, and serialization
- End every test method with an ALERT confirming completion
- Test round-tripping: `toObject()` -> `fromObject()` -> verify values match

---

## Code Style Conventions

### General

- Use `var` for all variable declarations (never `C_TEXT`, `C_LONGINT`, etc.)
- Use `cs.ClassName.new()` for class instantiation
- Prefer 4D collection methods (`.map()`, `.filter()`, `.query()`, `.orderBy()`) over manual loops
- Prefer ORDA over classic commands for all data access
- Use `This` to reference class properties (never global state)
- Use early `return` to reduce nesting

### Naming

| Element | Convention | Examples |
|---------|-----------|----------|
| Local variables | `$camelCase` | `$firstName`, `$lineItems` |
| Class properties | `camelCase` | `This.firstName`, `This.lineItems` |
| Private properties | `_camelCase` | `This._internalState` |
| Classes (public) | `PascalCase` | `FormBuilder`, `ProductCode` |
| Classes (private) | `_snake_case` | `_widget_base`, `_widget_button` |
| Methods (general) | `PascalCase_verb` | `Customer_save`, `Order_validate` |
| Methods (module) | `MODULE_verb` | `MATH_divide`, `ORD_newOrder` |
| Test methods | `Test_ClassName` | `Test_Coords`, `Test_FormBuilder` |
| Form names | `Subject_FormType` | `WorkOrder_Entry`, `Customer_List` |
| Form objects | `prefix_name` | `btn_save`, `input_email`, `list_orders` |

### Anti-Patterns to Avoid

```4d
// DO NOT use global/interprocess variables
<>currentOrder := $order    // BAD - global state
aItems{$i} := $code        // BAD - process arrays

// DO NOT mix Classic and ORDA in the same scope
QUERY([customer]; [customer]name = $name)  // BAD in new code
[customer]status := "Active"               // BAD in new code

// DO NOT use old-style declarations
C_TEXT($name)        // BAD - use var $name : Text
C_LONGINT($count)    // BAD - use var $count : Integer

// DO NOT hardcode file paths
$path := "/Users/me/data.txt"  // BAD
$file := File("/DATA/data.txt")  // GOOD
```

---

## Project Structure

```
Project/
  Sources/
    Classes/         - 4D classes (.4dm)
    Methods/         - Project methods (.4dm)
    Forms/           - Modern project forms (.4DForm + methods)
    TableForms/      - Legacy table-bound forms
    DatabaseMethods/ - Startup, shutdown, web connection handlers
    Triggers/        - Table triggers
    catalog.4DCatalog - Table/field definitions
    folders.json     - Method folder organization
    menus.json       - Menu bar definitions
    roles.json       - Access control
  DerivedData/       - Compiled code (do not edit)
Resources/           - Static resources (images, templates, etc.)
Data/                - Database data files
Logs/                - Log files
```

---

## Common 4D Commands Quick Reference

### Dialog/UI
```4d
DIALOG($formName)                           // display form as dialog
DIALOG($formName; $formData)                // with data object
$window := Open form window($form; $type)   // open window
CLOSE WINDOW                                // close window
ALERT($message)                             // alert dialog
$result := Request($prompt; $default)       // input dialog
```

### Dates and Times
```4d
$today := Current date
$now := Current time
$year := Year of($date)
$month := Month of($date)
$day := Day of($date)
$dateStr := String($date; Internal date short)
$date := Add to date($date; $years; $months; $days)
```

### Math
```4d
$abs := Abs($value)
$round := Round($value; $places)
$trunc := Trunc($value; $places)
$random := Random % $max
$min := Min($a; $b)
$max := Max($a; $b)
$mod := Mod($a; $b)
```

### Debugging
```4d
TRACE                                       // enter debugger
ASSERT($condition; $message)                // assertion
LOG EVENT(Into system standard outputs; $msg)  // log message
```
