# AGENTS.md

## delphihtmxtodo — DMVCFramework + TemplatePro + HTMX Todo

DelphiMVCFramework 3.5.0-silicon-rc9 web application with TemplatePro views and HTMX.
Migrated to the wizard-style 3.5 layout (`EngineConfigU.pas` + `BootConfigU.pas`,
see `C:\DEV\dmvcframework\samples\webapp_htmx_forms` and `C:\DEV\ActivityMonitor`
as wizard-generated references).

- **Host**: Indy Direct (native Indy, **no WebBroker/WebModule**). The `.dpr`
  creates the `TMVCEngine` and starts it with `TMVCServerFactory.CreateIndyDirect`;
  console app, Ctrl+C to shut down, no browser auto-open.
- `delphitodohtmx.dproj` builds the executable into `bin\`, next to `bin\.env`
  (configuration and secrets: never commit real values) and `bin\templates\`
  (TemplatePro views). Logging: colored console + rotating file in `bin\logs\`.
- Build from the command line: `rsvars.bat`
  (`C:\Program Files (x86)\Embarcadero\Studio\37.0\bin` — Delphi 13 Florence),
  then `msbuild delphitodohtmx.dproj /p:Config=Debug /p:Platform=Win64`.
- MVCFramework units compile from the local checkout
  (`C:\DEV\dmvcframework\sources`, via the BDS 37.0 Win64 library path);
  TemplatePro compiles from `..\templatepro\TemplatePro.pas` (`C:\DEV\templatepro`);
  LoggerPro compiles from `..\dmvcframework\lib\loggerpro` (dproj search path).
- Run from `bin\` (loads `.env`, recreates `todo.db` from `schema.sql` if
  missing); default port 8080.

## Key files

- `delphitodohtmx.dpr` — `Boot` call, SQLite bootstrap
  (`CreateSqlitePrivateConnDef` + `EnsureSqliteDatabase`), config callback
  (**`DefaultContentType`/`DefaultContentCharset` forced to text/html: the
  framework default is `application/json` for REST — a view app not forcing
  text/html makes the browser JSON viewer choke —** plus the keys the `.env` sets),
  `RunServer` with
  `TMVCServerFactory.CreateIndyDirect(lEngine)` + `RunAndWait`
- `BootConfigU.pas` — `Boot`: dotEnv (`FileThenEnv`, `test`/`prod` profiles),
  LoggerPro console+file appender, profiler
- `EngineConfigU.pas` — `ConfigureEngine`: controller registration, TemplatePro
  view engine, URL-encoded serializer,
  `FileServerBundle('/', bin/www)` (**must be `'/'`, not `''`: the empty prefix
  fails the filter's sanity check on the first request — controllers keep
  precedence via file-miss fall-through**), `SecurityHeadersHTTPFilter` +
  inline CSP filter, `ETagHTTPFilter`, `CompressionHTTPFilter`,
  `ActiveRecordHTTPFilter(CON_DEF_NAME, '')` (empty def-file on purpose: the
  SQLite connection is created in code, in `FDConnectionConfigU.pas`),
  `UseExceptionHandler('error', 'delphitodohtmx', ...)` driven by
  `dmvc.error.show_details` in `.env`
- `Controllers.MainU.pas` — all actions; each serves the full page or the HTMX
  fragment from the same template via `ViewData['ispage'] := not Context.Request.IsHTMX`
- `Entities.TodoU.pas` — `TTodo` ActiveRecord entity (`todos` table, SQLite);
  `[MVCDoNotDeserialize]` on `ID` (mass-assignment guard), `[MVCMaxLength(200)]`
  on `Content`
- `bin/templates/` — `_baselayout.html` (the `ispage` layout), `home.html`,
  `todo/_item.html` (`hx-confirm` on delete), `todo/_form.html`, `error.html`

## Skills

Before writing Delphi or DelphiMVCFramework code, read the skill for the task. They target DelphiMVCFramework 3.5.x; `update_ai_skills.bat` downloads or refreshes them.

- `.claude/skills/delphi/SKILL.md` - the language and the RTL: version gating, lifetime, strings, generics, threading
- `.claude/skills/delphi-code-smells/SKILL.md` - code review: compiler warnings, static analysis, memory leaks
- `.claude/skills/dmvcframework/SKILL.md` - controllers, ActiveRecord, validation, DI, middleware, servers, dotEnv
- `.claude/skills/dmvcframework-security/SKILL.md` - REQUIRED for any endpoint taking client input
- `.claude/skills/dmvcframework-testing/SKILL.md` - DUnitX integration tests
- `.claude/skills/dmvcframework-minimal-api/SKILL.md` - lambda routes, route groups, filters
- `.claude/skills/dmvcframework-webapp/SKILL.md` - TemplatePro views, fragments, ViewData
- `.claude/skills/dmvcframework-ui/SKILL.md` - Bootstrap 5.3 layout, style.css, dark mode
- `.claude/skills/htmx-skill/SKILL.md` - index of the official htmx.org docs

Do not write Delphi or DelphiMVCFramework code from memory: the API names in these files are authoritative.

<!-- delphi-local-sources -->
DelphiMVCFramework checkout: C:\DEV\dmvcframework   (sources/ + samples/ + lib/loggerpro)
Delphi RTL/VCL source: C:\Program Files (x86)\Embarcadero\Studio\37.0\source   (13 Florence, CompilerVersion 37.0)
<!-- /delphi-local-sources -->
