# 4D Catalog (.4DCatalog) Reference Guide

## Overview
The `.4DCatalog` file is an XML-based database schema definition. It controls table structure, field definitions, indexes, and relations. Changes are extremely sensitive—4D enforces strict validation and type checking against its DTD.

Starting with **4D 20R5**, the visual editor metadata (coordinates, colors, collapsed state) can be stored in a separate `catalog_editor.json` file. This reduces merge conflicts in version control since structure changes and editor layout changes no longer compete in the same file. Each developer can maintain their own `catalog_editor.json` for personal layout preferences.

---

## Critical Safety Rules

1. **Never modify** base attributes: `name`, `uuid`, `collation_locale` on the root `<base>` element
2. **Always preserve** the XML declaration and DOCTYPE declaration exactly as found
3. **Test incrementally**—make one logical change, test, then proceed
4. **Use version control**—always work in a separate branch before merging
5. **Flag breaking changes** before execution:
   - Deleting fields or tables
   - Changing field types (can corrupt existing data)
   - Removing primary keys
   - Modifying relation integrity constraints

---

## File Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE base SYSTEM "http://www.4d.com/dtd/2007/base.dtd">
<base name="DatabaseName" uuid="..." collation_locale="en">
  <schema name="DEFAULT_SCHEMA"/>
  <table>...</table>
  <relation>...</relation>
  <index>...</index>
  <base_extra>...</base_extra>
</base>
```

### Root Element: `<base>`

DTD: `<!ELEMENT base ((schema | table | relation | index)*, base_extra?)>`

| Attribute | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `name` | CDATA | IMPLIED | — | Database name—**DO NOT CHANGE** |
| `uuid` | CDATA | IMPLIED | — | Unique ID—**DO NOT CHANGE** |
| `collation_locale` | CDATA | IMPLIED | — | RFC3066Bis locale (e.g., `en`, `en-gb`, `fr-ca`) |
| `collator_ignores_middle_wildchar` | true\|false | No | false | Ignore `@` wildcard in text comparisons |
| `consider_only_dead_chars_for_keywords` | true\|false | No | false | Affects keyword indexing |

### `<schema>` Element

```xml
<schema name="DEFAULT_SCHEMA"/>
```

Empty element. `name` is required (CDATA).

---

## Table Definition: `<table>`

DTD: `<!ELEMENT table (field*, primary_key*, table_extra?)>`

Child ordering matters: fields first, then primary_key(s), then table_extra last.

### Attributes

| Attribute | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `name` | CDATA | **Yes** | — | Table name (must be unique in catalog) |
| `uuid` | CDATA | No | auto | Unique identifier for the table |
| `id` | NMTOKEN | No | — | 4D table index (informational only, not used on create) |
| `leave_tag_on_delete` | true\|false | No | false | Mark deleted records instead of removing |
| `sql_schema_id` | NMTOKEN | No | — | SQL schema ID mapping |
| `sql_schema_name` | CDATA | No | — | SQL schema name mapping |
| `keep_record_stamps` | true\|false | No | true | Maintain record timestamp metadata |
| `keep_record_sync_info` | true\|false | No | false | Store sync state (replication) |
| `hide_in_REST` | true\|false | No | false | Exclude from REST API exposure |
| `prevent_journaling` | true\|false | No | false | Don't log to journal file |
| `encryptable` | true\|false | No | false | Allow field-level encryption |

### Child Elements

#### `<field>` (0..*)
Defines a column. See Field Definition section.

#### `<primary_key>` (0..*)
Declares a primary key constraint. Empty element.

```xml
<primary_key field_name="ID" field_uuid="..."/>
```

| Attribute | Type | Required |
|-----------|------|----------|
| `field_name` | CDATA | **Yes** |
| `field_uuid` | CDATA | No |

#### `<table_extra>` (0..1)
Metadata for the structure editor and triggers. **Must be last child of `<table>`.**

DTD: `<!ELEMENT table_extra (comment*, editor_table_info?)>`

| Attribute | Type | Default | Notes |
|-----------|------|---------|-------|
| `visible` | true\|false | true | Show in structure editor |
| `trigger_load` | true\|false | false | Fire trigger on record load |
| `trigger_insert` | true\|false | false | Fire trigger on record insert |
| `trigger_delete` | true\|false | false | Fire trigger on record delete |
| `trigger_update` | true\|false | false | Fire trigger on record update |
| `trashed` | true\|false | false | Table is in trash |
| `input_form` | CDATA | — | Default input form name |
| `output_form` | CDATA | — | Default output form name |
| `encryptable` | true\|false | false | Encryption flag (also on table_extra) |

```xml
<table_extra visible="true" trigger_load="false" trigger_insert="false"
             trigger_delete="false" trigger_update="false">
  <comment>Table description here</comment>
  <editor_table_info>
    <color red="200" green="220" blue="240"/>
    <coordinates left="100" top="50"/>
  </editor_table_info>
</table_extra>
```

---

## Field Definition: `<field>`

DTD: `<!ELEMENT field (index_ref*, field_extra?)>`

Child ordering: `index_ref` elements first (if any), then `field_extra` last.

### Attributes

| Attribute | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `name` | CDATA | **Yes** | — | Field name (unique within table) |
| `uuid` | CDATA | No | auto | Unique field identifier |
| `type` | NMTOKEN | **Yes** | — | **Catalog field type code** (see Type Codes) |
| `limiting_length` | NMTOKEN | No | — | Max length; **only for type 10 (alpha)**. `255` = alpha, absent = text |
| `unique` | true\|false | No | false | Enforce uniqueness constraint |
| `autosequence` | true\|false | No | false | Auto-increment (legacy) |
| `autogenerate` | true\|false | No | false | Auto-generate UUID or sequence |
| `not_null` | true\|false | No | false | Integrity check: reject NULL |
| `never_null` | true\|false | No | false | Engine returns `""` or `0` instead of NULL |
| `text_switch_size` | NMTOKEN | No | — | Threshold for text→blob conversion |
| `blob_switch_size` | NMTOKEN | No | — | Max blob size in memory (default: 2147483647) |
| `id` | NMTOKEN | No | — | 4D field index (informational, not used on create) |
| `store_as_utf8` | true\|false | No | false | Force UTF-8 encoding |
| `store_as_UUID` | true\|false | No | false | Store as UUID format |
| `styled_text` | true\|false | No | false | Allow rich text formatting |
| `outside_blob` | true\|false | No | false | Store externally from record |
| `hide_in_REST` | true\|false | No | false | Exclude from REST API |

### Catalog Field Type Codes

These are **catalog-specific type codes** used in the `type` attribute of `<field>` elements. They are **NOT** the same as 4D language type constants.

| Catalog Code | Field Type | Notes |
|:---:|---|---|
| **1** | Boolean | True/False |
| **3** | Integer (16-bit) | Short integer |
| **4** | Long Integer (32-bit) | Standard integer |
| **5** | Integer 64 bits | 64-bit integer |
| **6** | Real | Floating-point number |
| **8** | Date | Calendar date |
| **9** | Time | Time value |
| **10** | Alpha / Text | With `limiting_length="255"` → Alpha; without → Text |
| **12** | Picture | Image/binary graphics |
| **13** | Blob | Binary large object |
| **21** | Object | JSON object storage |

> **Alpha vs Text distinction**: Both use type `10`. The presence of `limiting_length` (typically `"255"`) makes it an Alpha field. Without `limiting_length`, it is a Text field (variable length).

> **Critical**: These codes come from the `DB4DFieldType` enum in the DTD. Do not confuse with 4D language type constants (see cross-reference below).

> **Data type distinction**: In the catalog XML, these codes are **string values** (e.g., `type="10"`). In 4D code, the corresponding constants are **integers**. The values themselves are unrelated between the two systems.

### Catalog Type vs 4D Language Type Cross-Reference

The catalog `type` attribute values differ from the constants used in 4D code (`Is real`, `Is text`, etc.). The numbering systems are completely independent — no pattern connects them:

| Field Type | Catalog Code | 4D Language Constant | 4D Constant Value |
|---|:---:|---|:---:|
| Boolean | 1 | `Is Boolean` | 6 |
| Integer | 3 | — | — |
| Long Integer | 4 | `Is longint` | 9 |
| Integer 64 bits | 5 | `Is integer 64 bits` | 25 |
| Real | 6 | `Is real` | 1 |
| Date | 8 | `Is date` | 4 |
| Time | 9 | `Is time` | 11 |
| Alpha | 10 | `Is alpha field` | 0 |
| Text | 10 | `Is text` | 2 |
| Picture | 12 | `Is picture` | 3 |
| Blob | 13 | `Is BLOB` | 30 |
| Object | 21 | `Is object` | 38 |

> These two numbering systems share no consistent pattern. Always verify which context you are working in.

### Child Elements

#### `<index_ref>` (0..*)
Cross-reference to indexes that use this field. **For XSL parsing only; ignored on import.**

#### `<field_extra>` (0..1)
UI and validation metadata. **Must be last child of `<field>`.**

DTD: `<!ELEMENT field_extra (qt_spatial_settings?, tip?, comment*, editor_field_info?)>`

| Attribute | Type | Default | Notes |
|-----------|------|---------|-------|
| `visible` | true\|false | true | Show in structure editor |
| `enterable` | true\|false | true | Allow data entry |
| `modifiable` | true\|false | true | Allow modification |
| `mandatory` | true\|false | false | Require a value |
| `multi_line` | true\|false\|default | default | Multi-line text display |
| `compressed` | true\|false | false | Enable compression |
| `enumeration_id` | NMTOKEN | -1 | Enumeration resource ID (-1 = none) |
| `position` | NMTOKEN | — | Display position |
| `class_id` | CDATA | — | Associated class identifier |

```xml
<field_extra 
  visible="true"
  enterable="true"
  modifiable="true"
  mandatory="false"
  multi_line="default"
  compressed="false"
  enumeration_id="-1"
  position="1"
  class_id="">
  <qt_spatial_settings>...</qt_spatial_settings>
  <tip>Tooltip text</tip>
  <comment format="text">Field description</comment>
  <editor_field_info>
    <color red="0" green="0" blue="0"/>
  </editor_field_info>
</field_extra>
```

#### Comments in `<field_extra>`

Comments can appear in two formats simultaneously (RTF for the editor, plain text as fallback):

```xml
<field_extra>
  <comment format="rtf"><![CDATA[{\rtf1\ansi... }]]></comment>
  <comment format="text">Plain text description</comment>
</field_extra>
```

---

## Index Definition: `<index>`

DTD: `<!ELEMENT index (field_ref+)>`

Indexes are declared as **top-level children of `<base>`**, not inside tables.

### Attributes

| Attribute | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `name` | CDATA | No | — | Index name |
| `uuid` | CDATA | No | — | Unique index ID |
| `kind` | regular\|keywords | No | regular | `keywords` for text search; `regular` for standard |
| `unique_keys` | true\|false | No | false | Enforce unique values |
| `type` | NMTOKEN | No | auto | Index implementation type. Auto-selected based on kind/fields if not specified |

### Index Type Values

| Type | Usage |
|:---:|---|
| **7** | B-Tree index — standard for most fields (UUID, text, numeric) |
| **1** | B-Tree index — appears on text/alpha fields with unique constraint |

> In practice, type `7` covers the vast majority of indexes. Type `1` has been observed on unique alpha fields. If not specified, 4D selects automatically.

### Child Elements

#### `<field_ref>` (1..*)
References the indexed field(s). In top-level indexes, `<field_ref>` contains a `<table_ref>` child to identify which table the field belongs to.

```xml
<index kind="regular" unique_keys="true" uuid="..." type="7">
  <field_ref uuid="..." name="ID">
    <table_ref uuid="..." name="WINE"/>
  </field_ref>
</index>
```

---

## Relation Definition: `<relation>`

DTD: `<!ELEMENT relation (related_field+, relation_extra?)>`

Defines N-to-1 or 1-to-N relationships between tables. Relations are **top-level children of `<base>`**.

### Attributes

| Attribute | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `name_Nto1` | CDATA | No | — | Relation name from N-side table |
| `name_1toN` | CDATA | No | — | Relation name from 1-side table |
| `uuid` | CDATA | No | — | Unique relation ID |
| `auto_load_Nto1` | true\|false | No | false | Auto-fetch related 1-side record |
| `auto_load_1toN` | true\|false | No | false | Auto-fetch related N-side records |
| `foreign_key` | true\|false | No | false | Enforce as foreign key constraint |
| `integrity` | none\|reject\|delete | No | none | Referential integrity: reject changes or cascade delete |
| `state` | NMTOKEN | **Yes** | — | Relation state from `DB4D_RelationState` enum. Always `"1"` in practice; not user-controllable |

### Child Elements

#### `<related_field>` (1..*)

DTD: `<!ELEMENT related_field (field_ref)>`

Each `<related_field>` has a required `kind` attribute: `source` (the foreign key / N-side) or `destination` (the primary key / 1-side).

Inside relations, `<field_ref>` contains a `<table_ref>` child to fully qualify the field:

```xml
<relation uuid="..." name_Nto1="Producer" name_1toN="Wines" state="1">
  <related_field kind="source">
    <field_ref uuid="..." name="producer_id">
      <table_ref uuid="..." name="WINE"/>
    </field_ref>
  </related_field>
  <related_field kind="destination">
    <field_ref uuid="..." name="ID">
      <table_ref uuid="..." name="PRODUCER"/>
    </field_ref>
  </related_field>
</relation>
```

#### `<relation_extra>` (0..1)
Editor UI metadata. **Must be last child.**

DTD: `<!ELEMENT relation_extra (editor_relation_info?)>`

| Attribute | Type | Default | Notes |
|-----------|------|---------|-------|
| `entry_wildchar` | true\|false | false | N-to-1: wildcard entry |
| `entry_create` | true\|false | false | N-to-1: auto-create related record |
| `choice_field` | NMTOKEN | — | N-to-1: field id in the "1" table for choice list |
| `entry_autofill` | true\|false | false | 1-to-N: auto-fill |

```xml
<relation_extra 
  entry_wildchar="false"
  entry_create="false"
  choice_field="1"
  entry_autofill="false">
  <editor_relation_info via_point_x="100" via_point_y="50" prefers_left="false" smartlink="false">
    <color red="0" green="0" blue="0"/>
  </editor_relation_info>
</relation_extra>
```

---

## `<base_extra>` Element

DTD: `<!ELEMENT base_extra (temp_folder?, journal_file?, editor_base_info?)>`

Contains database-level settings. **Must be last child of `<base>`.**

### Attributes

| Attribute | Type | Default | Notes |
|-----------|------|---------|-------|
| `resman_stamp` | NMTOKEN | — | Resource manager stamp |
| `resman_marker` | NMTOKEN | — | Resource manager marker |
| `package_name` | CDATA | — | Application package name |
| `structure_file_name` | CDATA | — | Structure file name |
| `cache_folder_name` | CDATA | — | Cache folder name |
| `data_file_path` | CDATA | — | Path to data file |
| `source_code_available` | true\|false | true | Source code accessibility |
| `is_compiled_database` | true\|false | false | Compiled mode flag |

### `<journal_file>` Child Element

```xml
<journal_file journal_file_enabled="true"/>
```

| Attribute | Type | Default | Notes |
|-----------|------|---------|-------|
| `journal_file_enabled` | true\|false | false | Enable journaling for new data files |
| `datalink` | CDATA | — | Data link reference |
| `filepath` | CDATA | — | Journal file path |
| `next_filepath` | CDATA | — | Next journal file path |
| `sequence_number` | NMTOKEN | — | Journal sequence number |

### `<temp_folder>` Child Element

```xml
<temp_folder folder_selector="data"/>
```

| `folder_selector` Value | Meaning |
|---|---|
| `data` | Data file folder (default) |
| `structure` | Structure file folder |
| `system` | System temp folder |
| `custom` | Custom path specified in `path` attribute |

---

## Common Patterns

### UUID Primary Key Field (Standard ID Pattern)

Every table in the sample catalog follows this pattern:

```xml
<field name="ID" uuid="..." type="10" unique="true" autogenerate="true"
       store_as_UUID="true" not_null="true" id="1"/>
<primary_key field_name="ID" field_uuid="..."/>
```

### Foreign Key Field (UUID Reference)

```xml
<field name="producer_id" uuid="..." type="10" autogenerate="true"
       store_as_UUID="true" id="5">
  <field_extra multi_line="false"/>
</field>
```

Note: FK fields use `autogenerate="true"` and `store_as_UUID="true"` but do **not** use `unique="true"` (many records can reference the same parent).

### Alpha Field (Fixed Length)

```xml
<field name="name" uuid="..." type="10" limiting_length="255" not_null="true" id="2">
  <field_extra multi_line="false"/>
</field>
```

### Text Field (Variable Length)

No `limiting_length` attribute—this is what distinguishes Text from Alpha:

```xml
<field name="description" uuid="..." type="10" never_null="true" id="8"/>
```

### Integer Field

```xml
<field name="qty" uuid="..." type="3" id="5">
  <field_extra multi_line="false"/>
</field>
```

### Real (Float) Field

```xml
<field name="bottleSize" uuid="..." type="6" never_null="true" id="7">
  <field_extra multi_line="false"/>
</field>
```

### Boolean Field

```xml
<field name="encrypted" uuid="..." type="1" id="4"/>
```

### Date Field

```xml
<field name="date" uuid="..." type="8" never_null="true" id="2">
  <field_extra multi_line="false"/>
</field>
```

### Object Field (JSON Storage)

```xml
<field name="data" uuid="..." type="21" blob_switch_size="2147483647" id="6">
  <field_extra multi_line="false"/>
</field>
```

### Picture Field

```xml
<field name="thumb" uuid="..." type="12" id="3"/>
```

### Indexed Field (Top-Level)

The field definition is inside the table; the index is a sibling of the table at the `<base>` level:

```xml
<!-- Inside <table name="GRAPE"> -->
<field name="name" uuid="ADE084CA..." type="10" limiting_length="255"
       unique="true" not_null="true" id="2">
  <field_extra multi_line="false"/>
</field>

<!-- At <base> level -->
<index kind="regular" unique_keys="true" uuid="81738F91..." type="1">
  <field_ref uuid="ADE084CA..." name="name">
    <table_ref uuid="82CD9D60..." name="GRAPE"/>
  </field_ref>
</index>
```

---

## Example: Adding a New Table with Relation

```xml
<!-- 1. Add the table inside <base>, before relations and indexes -->
<table name="CUSTOMER" uuid="A1B2C3D4E5F60000000000000000AAAA" id="12">
  <field name="ID" uuid="A1B2C3D4E5F60000000000000000AAA1" type="10"
         unique="true" autogenerate="true" store_as_UUID="true" not_null="true" id="1"/>
  <field name="name" uuid="A1B2C3D4E5F60000000000000000AAA2" type="10"
         limiting_length="255" not_null="true" id="2">
    <field_extra multi_line="false"/>
  </field>
  <field name="email" uuid="A1B2C3D4E5F60000000000000000AAA3" type="10"
         limiting_length="255" id="3">
    <field_extra multi_line="false"/>
  </field>
  <field name="data" uuid="A1B2C3D4E5F60000000000000000AAA4" type="21"
         blob_switch_size="2147483647" id="4"/>
  <primary_key field_name="ID" field_uuid="A1B2C3D4E5F60000000000000000AAA1"/>
  <table_extra visible="true"/>
</table>

<!-- 2. Add index at <base> level -->
<index kind="regular" unique_keys="true" uuid="A1B2C3D4E5F60000000000000000BBB1" type="7">
  <field_ref uuid="A1B2C3D4E5F60000000000000000AAA1" name="ID">
    <table_ref uuid="A1B2C3D4E5F60000000000000000AAAA" name="CUSTOMER"/>
  </field_ref>
</index>

<!-- 3. Add relation at <base> level (if linking to another table) -->
<relation uuid="A1B2C3D4E5F60000000000000000CCC1"
          name_Nto1="Customer" name_1toN="Orders" state="1">
  <related_field kind="source">
    <field_ref uuid="..." name="customer_id">
      <table_ref uuid="..." name="ORDER"/>
    </field_ref>
  </related_field>
  <related_field kind="destination">
    <field_ref uuid="A1B2C3D4E5F60000000000000000AAA1" name="ID">
      <table_ref uuid="A1B2C3D4E5F60000000000000000AAAA" name="CUSTOMER"/>
    </field_ref>
  </related_field>
</relation>
```

---

## Element Ordering Within `<base>`

The DTD defines: `<!ELEMENT base ((schema | table | relation | index)*, base_extra?)>`

While technically any ordering of schema/table/relation/index is valid, the convention observed in real catalogs is:

1. `<schema>` — always first
2. `<table>` elements — all tables together
3. `<relation>` elements — all relations together
4. `<index>` elements — all indexes together
5. `<base_extra>` — always last

---

## Validation Checklist Before Writing

- [ ] UUIDs are properly formatted (32 hex chars, uppercase, no hyphens)
- [ ] Field `type` code is valid (1, 3, 4, 5, 6, 8, 9, 10, 12, 13, 21)
- [ ] `limiting_length` only appears on type 10 fields (and only for Alpha, not Text)
- [ ] Primary key field exists in the table before declaring `<primary_key>`
- [ ] `field_extra` is the last child of `<field>`
- [ ] `table_extra` is the last child of `<table>`
- [ ] `relation_extra` is the last child of `<relation>`
- [ ] `base_extra` is the last child of `<base>`
- [ ] No duplicate table or field names
- [ ] All `field_ref` elements in indexes and relations include `<table_ref>` children
- [ ] All `field_ref` elements reference existing fields by both name and UUID
- [ ] Relation `state` attribute is provided (typically `"1"`)
- [ ] Indexes are at `<base>` level, not inside `<table>`
- [ ] XML is well-formed (closing tags, proper nesting, declaration preserved)

---

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Changing root `uuid` | Unrecoverable—4D won't recognize the catalog | Restore original UUID |
| Wrong field type code | Data corruption on existing records | Use correct catalog type code (not 4D language constants) |
| Confusing catalog types with 4D language types | Wrong type applied (e.g., catalog `6` = Real, but 4D `Is real` = `1`) | Consult the cross-reference table |
| Using type `18` for Boolean | Invalid—`18` does not exist in the catalog type system | Use type `1` for Boolean |
| Using type `21` for Blob | `21` is Object, not Blob | Use type `13` for Blob |
| Missing `<table_ref>` in index/relation `<field_ref>` | Parser may fail to resolve field references | Always include `<table_ref>` child |
| Missing `field_extra` | Parser may fail or ignore field settings | Include `<field_extra/>` (empty is fine) |
| Duplicate UUIDs | 4D rejects the catalog | Generate new UUID for each new element |
| Deleting field without migration | Data loss | Plan migration or add new field instead |
| Placing index inside table | Invalid structure | Indexes go at `<base>` level |
| Circular foreign key | Runtime errors | Ensure relations form directed acyclic graph |

---

## Tools & Workflow

### UUID Generation
Generate UUIDs for new tables/fields (32 hex chars, uppercase, no hyphens):
```bash
uuidgen | tr -d '-' | tr '[:lower:]' '[:upper:]'
```

### Validation Before Commit
1. Format: `xmllint --format catalog.4DCatalog`
2. DTD validate: `xmllint --dtdvalid base_core.dtd catalog.4DCatalog`
3. Parse: Load in 4D IDE to validate
4. Test: Run basic CRUD operations on modified tables
5. Diff: Review changes against baseline

### Branching Strategy
- Never commit directly to main catalog
- Create feature branch: `schema/add-customer-table`
- Test thoroughly before PR
- Have another developer review schema changes

---

## References

- DTD Definition: `/mnt/project/base_core.dtd`
- Copilot Instructions: `/mnt/project/copilot-instructions.md`
- Catalog Field Type Reference: `/mnt/project/Field_type_attribute_values_in_catalog.4DCatalog`
- 4D Language Type Constants: `/mnt/project/4D_Field_and_Variable_Types`
- Catalog Editor Separation (4D 20R5+): `/mnt/project/separate_catalog_editor.json file`
- 4D Official DTD: http://www.4d.com/dtd/2007/base.dtd
