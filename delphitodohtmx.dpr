// ***************************************************************************
//
// delphihtmxtodo - DMVCFramework + TemplatePro + HTMX todo list
// Generated following the DMVCFramework 3.5 wizard layout (BootConfigU +
// EngineConfigU + Indy Direct server), no WebBroker/WebModule.
//
// ***************************************************************************

program delphitodohtmx;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.IOUtils,
  MVCFramework,
  MVCFramework.Logger,
  MVCFramework.DotEnv,
  MVCFramework.Commons,
  MVCFramework.Serializer.Commons,
  MVCFramework.Signal,
  MVCFramework.Server.Intf,
  MVCFramework.Server.Factory,
  Controllers.MainU in 'Controllers.MainU.pas',
  Entities.TodoU in 'Entities.TodoU.pas',
  FDConnectionConfigU in 'FDConnectionConfigU.pas',
  TemplatePro in '..\templatepro\TemplatePro.pas',
  BootConfigU in 'BootConfigU.pas',
  EngineConfigU in 'EngineConfigU.pas';

{$R *.res}

procedure RunServer(APort: Integer);
var
  lEngine: TMVCEngine;
  lServer: IMVCServer;
begin
  // Built-in defaults, overridden below only where the .env has a say.
  // EXCEPTION: the framework default for DefaultContentType is application/json
  // (REST-first, TMVCConstants.DEFAULT_CONTENT_TYPE), so a server-side-view app
  // must force text/html - otherwise the browser opens the JSON viewer and
  // chokes with "Unexpected token '<'" on the HTML body.
  // IMPORTANT: ViewCache is OFF by default - enable it for production.
  lEngine := TMVCEngine.Create(
    procedure(AConfig: TMVCConfig)
    begin
      AConfig[TMVCConfigKey.DefaultContentType] := dotEnv.Env('dmvc.default.content_type', TMVCMediaType.TEXT_HTML);
      AConfig[TMVCConfigKey.DefaultContentCharset] := dotEnv.Env('dmvc.default.content_charset', TMVCConstants.DEFAULT_CONTENT_CHARSET);
      AConfig[TMVCConfigKey.ExposeServerSignature] := dotEnv.Env('dmvc.expose_server_signature', 'false');
      AConfig[TMVCConfigKey.ExposeXPoweredBy] := dotEnv.Env('dmvc.expose_x_powered_by', 'false');
      AConfig[TMVCConfigKey.MaxRequestSize] := dotEnv.Env('dmvc.max_request_size', IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE));
      // Project .env options (same keys the pre-wizard callback used to read)
      AConfig[TMVCConfigKey.LoadSystemControllers] := dotEnv.Env('dmvc.load_system_controllers', 'false');
      AConfig[TMVCConfigKey.ViewPath] := dotEnv.Env('dmvc.view_path', 'templates');
      AConfig[TMVCConfigKey.ViewCache] := dotEnv.Env('dmvc.view_cache', 'false');
    end);
  try
    ConfigureEngine(lEngine);
    lServer := TMVCServerFactory.CreateIndyDirect(lEngine);
    LogI('Starting on http://localhost:' + APort.ToString +
      ' (Indy Direct). Press Ctrl+C to shut down.');
    // RunAndWait: Listen + signal wait + shutdown. For non-console hosts use Listen() + Stop().
    lServer.RunAndWait(APort);
    lServer := nil;
  finally
    lEngine.Free;
  end;
end;

begin
  { Enable ReportMemoryLeaksOnShutdown during debug }
  // ReportMemoryLeaksOnShutdown := True;
  IsMultiThread := True;

  MVCSerializeNulls := True;
  Boot; // dotEnv + logger + profiler; must run before any LogI call

  LogI('** DMVCFramework Server ** build ' + DMVCFRAMEWORK_VERSION);

  try
    // SQLite for ActiveRecord: create the connection def and the database
    // (todo.db from schema.sql) before accepting the first request.
    FDConnectionConfigU.CreateSqlitePrivateConnDef(True);
    FDConnectionConfigU.EnsureSqliteDatabase;

    RunServer(dotEnv.Env('dmvc.server.port', 8080));
  except
    on E: Exception do
    begin
      LogF(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
