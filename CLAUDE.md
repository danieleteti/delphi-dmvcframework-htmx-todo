# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Delphi web application demonstrating HTMX integration with DMVCFramework. It's a Todo application that uses:
- **DMVCFramework** - Delphi MVC web framework
- **HTMX** - For partial page updates without JavaScript
- **TemplatePro** - Server-side template rendering
- **MVCActiveRecord** - ORM for database operations
- **SQLite** - Database via FireDAC

## Build and Run

- This is a Delphi project - requires Delphi IDE or command-line compiler
- The executable output goes to `bin/delphitodohtmx.exe`
- Run the application from the `bin/` directory (it loads .env and templates from there)
- Server defaults to port 8080 (configurable in `bin/.env`)
- SQLite database is at `bin/todo.db`

## Architecture

**Entry Point**: `delphitodohtmx.dpr` - Console app that starts the HTTP server using Indy (TIdHTTPWebBrokerBridge)

**Web Module**: `WebModuleU.pas` - Configures TMVCEngine with:
- TemplatePro view engine
- Static files middleware (serves `bin/www/`)
- ActiveRecord middleware (handles SQLite connection)
- Various optional middlewares (CORS, compression, etc.)

**Controller**: `Controllers.MainU.pas` - TMyController with REST endpoints:
- `GET /` - Returns all todos (full page or HTMX partial)
- `POST /add` - Create todo
- `DELETE /delete/:id` - Delete todo
- `GET /edit/:id` - Get edit form
- `PUT /edit/:id` - Update todo

**Entity**: `Entities.TodoU.pas` - TTodo class using MVCActiveRecord with:
- `id` - Primary key (NullableInt32)
- `content` - Todo text

**Database**: `FDConnectionConfigU.pas` - Creates SQLite connection definition named `MyConnX`

## HTMX Pattern

The application checks `Context.Request.IsHTMX` to determine if request is HTMX-driven:
- Full page render for regular browser requests
- Partial HTML swaps for HTMX requests (e.g., `RenderView('todo/_item')` returns just the item fragment)

Templates in `bin/templates/`:
- `home.html` - Main page layout
- `todo/_item.html` - Individual todo item (used for partial updates)
- `todo/_form.html` - Edit form fragment
- `_baselayout.html` - Base layout with UIKit CSS

## Key Files

- `delphitodohtmx.dpr` - Main program
- `delphitodohtmx.dproj` - Project file
- `WebModuleU.pas` - Server configuration
- `Controllers.MainU.pas` - HTTP endpoints
- `Entities.TodoU.pas` - Data model
- `FDConnectionConfigU.pas` - Database config
- `bin/.env` - Configuration (port, view path, etc.)
- `bin/templates/*.html` - View templates