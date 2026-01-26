# AI Project Templates for 4D

Context files that help AI coding tools (Claude Code, GitHub Copilot, etc.) write correct, modern 4D code. I am able to get good quality 4D code by providing this sort of context to CoPilot or Claude Code. These files give you a good starting point.

They are strongly biased to using ORDA and modern 4D programming. If you are working in classic code they will still be useful. Install them in your project and engage with your AI about modifying them to prefer classic patterns. The really valuable work here is laying out fundamental 4D context.

## What's Included

A set of `CLAUDE.md` files that mirror the standard 4D project directory structure. Each file provides context-specific guidance for the code in that directory.

```
AI_Project_Templates/
  CLAUDE.md                                  # 4D language reference, ORDA, code style
  Project/
    Sources/
      Classes/CLAUDE.md                      # Class patterns, getters/setters, inheritance
      Methods/CLAUDE.md                      # Method naming, test format, migration
      Forms/CLAUDE.md                        # Modern forms, controllers, entity binding
      TableForms/CLAUDE.md                   # Legacy form maintenance
      DatabaseMethods/CLAUDE.md              # Startup, shutdown, web handlers
      Triggers/CLAUDE.md                     # Trigger structure and patterns
      Methods/Install_AI_Templates.4dm       # Installer method (see below)
```

## What the AI Learns

- **4D syntax** -- `:=` assignment, `#` not-equal, semicolons as separators, `var` declarations, `//mark:` sections
- **ORDA patterns** -- entity/entity selection model, `ds.table.query()`, `.save()` status handling
- **Class architecture** -- property declarations, computed getters/setters, `Super()`, factory methods, validation as `{level, message}` collections
- **Test methods** -- `Test_` prefix, `ASSERT()` with diagnostic messages, section markers, serialization round-trips
- **Form architecture** -- class-based controllers, `Form.entity` binding, event delegation, save/cancel/delete patterns
- **Path handling** -- filesystem path refs vs platform paths, the `.parent` gotcha, component `*` parameter
- **Legacy awareness** -- when to migrate classic code, when to leave it alone

## Installation

Clone, fork or copy this repo to your development environment. Put it someplace easy to get to. You can install it into any 4D Project.

### Option A: Use the 4D installer method

1. Copy `Install_AI_Templates.4dm` into your 4D project's `Project/Sources/Methods/` folder
2. Run the method within 4D
3. Select this `AI_Project_Templates` folder when prompted
4. All files are copied to the correct locations automatically

The installer walks the entire template tree, copies all files, and creates any missing directories. Form folders (under `Forms/`) are copied as complete units. Hidden files are skipped.

### Option B: Copy manually

Copy each `CLAUDE.md` to the matching directory in your 4D project:

| Source | Destination |
|--------|-------------|
| `CLAUDE.md` | Your project root |
| `Project/Sources/Classes/CLAUDE.md` | `Project/Sources/Classes/` |
| `Project/Sources/Methods/CLAUDE.md` | `Project/Sources/Methods/` |
| `Project/Sources/Forms/CLAUDE.md` | `Project/Sources/Forms/` |
| `Project/Sources/TableForms/CLAUDE.md` | `Project/Sources/TableForms/` |
| `Project/Sources/DatabaseMethods/CLAUDE.md` | `Project/Sources/DatabaseMethods/` |
| `Project/Sources/Triggers/CLAUDE.md` | `Project/Sources/Triggers/` |

## Updating

Re-run the installer method or re-copy the files. The installer uses `fk overwrite` so existing files are replaced.

## Extending

Add any files to this template folder and the installer will copy them. Examples:

- Example class files in `Project/Sources/Classes/`
- Example test methods in `Project/Sources/Methods/`
- Template forms as folders in `Project/Sources/Forms/`

The only special case is `Project/Sources/Forms/` -- subdirectories there are copied as complete units (since 4D forms are stored as folders).

This allows you to include classes, methods and forms that are part of your personal development workflow. This is totally optional and has nothing to do with the AI context.

## Customizing for a Project

After installation, edit the root `CLAUDE.md` to add project-specific context:

- Database schema and table relationships
- Business domain terminology
- Project-specific naming conventions
- Deployment and environment notes

The subdirectory files are generally reusable as-is across projects.

## Compatibility

- **4D v20+** -- uses `var` declarations, collection literals, `Try`/`Catch`
- **Claude Code** -- reads `CLAUDE.md` files automatically from project root and subdirectories
- **GitHub Copilot** -- rename files to `copilot-instructions.md` if preferred, or configure in `.github/copilot-instructions.md`

## License

Use freely. No attribution required and no warranty implied or promised.
