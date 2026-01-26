# Claude Code Instructions for 4D Database Methods

## Overview

Database methods are special methods that 4D calls automatically in response to application lifecycle events. They live in `Project/Sources/DatabaseMethods/` and have fixed names.

## Database Method Reference

### On Startup

Called when the database opens (client or single-user). Use for initialization.

```4d
// On Startup database method

// Initialize application state
var $settings : Object := This._loadSettings()

// Set up ORDA datastore if connecting to remote
// ds := Open datastore(...)

// Verify data integrity
// This._checkDataIntegrity()

// Open main form
DIALOG("Main_Menu")
```

### On Exit

Called when the database closes. Use for cleanup.

```4d
// On Exit database method

// Save user preferences
// This._savePreferences()

// Close connections
// CLOSE DATASTORE(ds)

// Clean up temp files
// This._cleanTempFiles()
```

### On Server Startup

Called when 4D Server starts (server only, not client). Use for server-side initialization.

```4d
// On Server Startup database method

// Initialize server-specific resources
// Start workers, schedule tasks, configure logging

// Register REST API if needed
// This._configureREST()
```

### On Server Shutdown

Called when 4D Server stops. Use for server-side cleanup.

```4d
// On Server Shutdown database method

// Graceful shutdown of workers
// KILL WORKER("myWorker")

// Close server-side connections
```

### On Web Connection

Called for each incoming web request (legacy web server). Modern projects should use ORDA REST or custom HTTP handlers instead.

```4d
// On Web Connection database method
// $1 - URL
// $2 - HTTP header
// $3 - Client IP
// $4 - Server IP
// $5 - User/password

// Route request
Case of
  : ($1 = "/api/status")
    WEB SEND TEXT(JSON Stringify({status: "ok"}); "application/json")
  Else
    WEB SEND TEXT("Not Found"; "text/plain"; 404)
End case
```

### On Web Authentication

Called to authenticate web requests. Return True to allow, False to deny.

```4d
// On Web Authentication database method
// $1 - URL
// $2 - HTTP header
// $3 - Client IP
// $4 - Server IP
// $5 - User name
// $6 - Password
// $0 - Boolean (True = allowed)

$0 := This._authenticateWebUser($5; $6)
```

## Guidelines

- Keep database methods short and focused -- delegate to classes or project methods
- Avoid heavy processing in On Startup (delays application launch)
- On Exit has limited time -- do not run long operations
- Server methods run in the server process context (no UI access)
- Use `Try`/`Catch` in database methods to prevent startup/shutdown failures from crashing the application
