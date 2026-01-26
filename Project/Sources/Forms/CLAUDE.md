# Claude Code Instructions for 4D Forms

## Overview

This directory contains **modern forms** using class-based controllers and ORDA entities. All new forms should be created here following the patterns below.

Legacy array-based forms are in `TableForms/`. Do not create new forms there.

## Form Architecture

### Class-Based Controllers

Every form should have a class-based controller. The controller manages the form's data and behavior using the MVC pattern.

```4d
// Form method (minimal - delegates to controller)
Case of
  : (Form event code = On Load)
    Form.controller := cs.MyFormController.new()
    Form.controller.onLoad()

  : (Form event code = On Clicked)
    Form.controller.onClick(OBJECT Get name)

  : (Form event code = On Data Change)
    Form.isModified := True

  : (Form event code = On Unload)
    Form.controller.onUnload()

  : (Form event code = On Validate)
    $valid := Form.controller.validate()
End case
```

### Controller Base Classes

Extend these base classes when available:
- `_FormBase` - foundation for all form controllers
- `_ListDetail` - master-detail pattern (list + detail editing)

```4d
// MyFormController class
Class extends _FormBase

Class constructor()
  Super()
  This.entity := Null
  This.isNewRecord := False

Function onLoad()
  This.loadEntity()

Function onClick($objectName : Text)
  Case of
    : ($objectName = "btn_save")
      This.save()
    : ($objectName = "btn_cancel")
      This.cancel()
  End case
```

## Form JSON Structure

Forms use `.4DForm` extension (JSON format):

```json
{
  "$4d": {"version": "1", "kind": "form"},
  "windowTitle": "My Form",
  "destination": "detailScreen",
  "width": 1505,
  "height": 900,
  "memorizeGeometry": true,
  "windowSizingX": "variable",
  "windowSizingY": "variable",
  "windowMinWidth": 0,
  "windowMinHeight": 0,
  "windowMaxWidth": 32767,
  "windowMaxHeight": 32767,
  "markerHeader": 0,
  "markerBody": 807,
  "markerBreak": 807,
  "markerFooter": 807,
  "events": ["onLoad", "onClick", "onDataChange"],
  "method": "method.4dm",
  "formClass": "form_controller",
  "pages": [
    { "objects": {} },
    { "objects": {
      "widget_1": { }
    }}
  ],
  "entryOrder": []
}
```

### Key Form Properties

| Property | Description | Values |
|----------|-------------|--------|
| `destination` | Form type | `"detailScreen"`, `"listScreen"`, `"detailPrinter"`, `"listPrinter"` |
| `windowSizingX/Y` | Resizable? | `"fixed"`, `"variable"` |
| `memorizeGeometry` | Save window position | `true`, `false` |
| `events` | Form-level events | Collection of event names |
| `formClass` | Controller class name | Any existing class name |
| `method` | Form method | Any existing method name |

### Pages and Objects

- `pages[0]` is the **background page** (page 0) - visible on all pages, never shown alone
- `pages[1]` through `pages[n]` are display pages
- Object names must be **unique across all pages** in the form
- Objects on page 0 can be hidden to make them invisible on all pages

## Form Data Binding

### Entity-Based Forms

Forms work with ORDA entities, not current records:

```4d
// Form.entity - Main entity being edited
Form.entity := ds.workOrder.get($id)

// Form.controller - Class-based controller
Form.controller := cs.WorkOrderController.new(Form.entity)

// Form data sources (related entities)
Form.lineItems := Form.entity.lineItems
Form.customers := ds.customer.all().orderBy("name")

// Form state
Form.isModified := False
Form.isNewRecord := (Form.entity = Null)
```

### Input Field Binding

In the form editor, bind input fields directly to Form properties:
- Input field data source: `Form.entity.customerName`
- Listbox data source: `Form.lineItems`
- Dropdown data source: `Form.customers`

Data binding is automatic -- no manual sync needed.

## Event Handling

### Standard Event Flow

```4d
Case of
  : (Form event code = On Load)
    Form.controller.onLoad()

  : (Form event code = On Unload)
    Form.controller.onUnload()

  : (Form event code = On Data Change)
    Form.isModified := True

  : (Form event code = On Validate)
    $valid := Form.controller.validate()

  : (Form event code = On Clicked)
    Form.controller.onClick(OBJECT Get name)
End case
```

### Controller Event Methods

```4d
Function onClick($objectName : Text)
  Case of
    : ($objectName = "btn_save")
      This.save()
    : ($objectName = "btn_cancel")
      This.cancel()
    : ($objectName = "btn_new")
      This.newRecord()
    : ($objectName = "btn_delete")
      This.deleteRecord()
  End case
```

## Common Form Patterns

### Save Pattern

```4d
Function save() -> $success : Boolean
  If (Not(This.validate()))
    return False
  End if

  var $status : Object := Form.entity.save()

  If ($status.success)
    Form.isModified := False
    Form.isNewRecord := False
    return True
  Else
    ALERT("Save failed: " + $status.errors[0].message)
    return False
  End if
```

### Cancel/Revert Pattern

```4d
Function cancel()
  If (Form.isModified)
    $confirm := Request("Changes will be lost. Continue?"; "Yes"; "No")
    If ($confirm # "Yes")
      return
    End if
  End if

  If (Form.isNewRecord)
    Form.entity.drop()
  Else
    Form.entity.reload()
  End if

  CANCEL
```

### Delete Pattern

```4d
Function deleteRecord()
  $confirm := Request("Delete this record?"; "Yes"; "No")
  If ($confirm = "Yes")
    var $status : Object := Form.entity.drop()
    If ($status.success)
      CANCEL
    Else
      ALERT("Delete failed: " + $status.errors[0].message)
    End if
  End if
```

### New Record Pattern

```4d
Function newRecord()
  Form.entity := ds.workOrder.new()
  Form.entity.date := Current date
  Form.entity.status := "New"

  Form.isNewRecord := True
  Form.isModified := False

  GOTO OBJECT("input_customerName")
```

### Validation Pattern

```4d
Function validate() -> $isValid : Boolean
  var $errors : Collection := []

  If (Form.entity.customerName = "")
    $errors.push("Customer name is required")
  End if

  If (Form.entity.dueDate < Current date)
    $errors.push("Due date cannot be in the past")
  End if

  If ($errors.length > 0)
    ALERT($errors.join("\n"))
    return False
  End if

  return True
```

## List Box Patterns

### Entity Selection Listbox

```4d
// In controller onLoad
Form.listbox_orders := cs.listbox.new("listbox_orders")
Form.orders := ds.workOrder.query("status = :1"; "Active").orderBy("date desc")
```

**Listbox form object properties:**
- Data Source: `Form.listbox_orders.data`
- Current Item: `Form.listbox_orders.currentItem`
- Selected Items: `Form.listbox_orders.selectedItems`
- Position: `Form.listbox_orders.position`

**Columns:** Bind each to entity property via `This.fieldName` (e.g., `This.woid`, `This.customerName`)

### Listbox Events

```4d
Case of
  : (Form event code = On Selection Change)
    If (Form.listbox_orders.isSelected)
      Form.currentEntity := Form.listbox_orders.currentItem
    End if

  : (Form event code = On Double Clicked)
    If (Form.listbox_orders.isSelected)
      This.openDetail(Form.listbox_orders.currentItem)
    End if
End case
```

## Master-Detail Forms

```4d
Class extends _ListDetail

Class constructor()
  Super()
  This.loadList()

Function loadList()
  Form.orders := ds.workOrder.all().orderBy("date desc")
  Form.currentEntity := Null

Function onSelectionChange()
  If (Form.currentEntity # Null)
    This.loadDetail(Form.currentEntity)
  End if

Function loadDetail($entity : cs.workOrderEntity)
  Form.entity := $entity
  Form.lineItems := $entity.lineItems
  This.refreshDetailView()
```

## Dynamic Form Creation

Forms can be built programmatically and displayed using objects instead of stored .4DForm files:

```4d
var $builder : cs.FormBuilder := cs.FormBuilder.new()
$builder.windowTitle := "Dynamic Form"

$builder.addButton("btn_ok"; "OK"; 1; 500; 10; 80; 24)
$builder.addInput("input_name"; 1; 130; 50; 200; 24)
$builder.addText("label_name"; "Name:"; 1; 20; 50; 100; 24)

var $formDef : Object := $builder.toObject()
var $window := Open form window($formDef; Plain form window)
DIALOG($formDef; $formData)
CLOSE WINDOW
```

## Displaying Forms

### Two Ways to Display

```4d
// Method 1: Form handles its own controller
DIALOG("MyForm")

// Method 2: Pre-configured controller passed to form
$controller := cs.MyController.new()
$controller.entity := ds.customer.get($id)
DIALOG("MyForm"; $controller)
// $controller retains changes after dialog closes
```

Method 2 is preferred when:
- The controller needs setup before display
- Controller data is used after the form closes
- The same controller feeds multiple forms in sequence

## Naming Conventions

### Form Names

```
[Subject]_[FormType]
```
PascalCase, no spaces:
- `WorkOrder_Entry`
- `Customer_List`
- `LineItem_Detail`
- `ProductCode_Picker`

### Form Object Names

```
[prefix]_[name]
```
| Prefix | Object Type | Examples |
|--------|------------|----------|
| `btn_` | Button | `btn_save`, `btn_cancel`, `btn_new` |
| `input_` | Input field | `input_customerName`, `input_quantity` |
| `list_` | List box | `list_orders`, `list_lineItems` |
| `label_` | Label/text | `label_customerName`, `label_total` |

### Common Form Object Names

```
Form.e  || Form.entity     - entity on a detail form
Form.orders_LB             - listbox for Orders
Form.title                 - form title displayed on the form
```

## Checklist for New Forms

- [ ] Class-based controller (extends _FormBase or _ListDetail)
- [ ] ORDA entities (not current records)
- [ ] Entity selection for lists (not arrays)
- [ ] Data binding to Form object properties
- [ ] Validation in controller methods
- [ ] PascalCase form name (no spaces)
- [ ] Consistent object naming (btn_, input_, list_, label_)
- [ ] Proper save/cancel/delete patterns
- [ ] Default events: onLoad, onClick, onDataChange
