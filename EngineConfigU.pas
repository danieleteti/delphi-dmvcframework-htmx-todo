// ***************************************************************************
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2026 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// ***************************************************************************

unit EngineConfigU;

interface

uses
  MVCFramework;

procedure ConfigureEngine(AEngine: TMVCEngine);

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Controllers.MainU,
  FDConnectionConfigU,
  TemplatePro,
  MVCFramework.View.Renderers.TemplatePro,
  MVCFramework.Serializer.URLEncoded,
  MVCFramework.Filters,
  MVCFramework.Filters.ActiveRecord,
  MVCFramework.DotEnv,
  MVCFramework.Commons;

procedure ConfigureEngine(AEngine: TMVCEngine);
var
  lWwwPath: string;
  lErrorOptions: TMVCExceptionHandlerOptions;
begin
  // Static files path (www folder at same level as the executable)
  lWwwPath := TPath.Combine(AppPath, 'www');

  // Controllers
  AEngine.AddController(TMyController);

  // Server Side View
  AEngine.SetViewEngine(TMVCTemplateProViewEngine);
  // The todo form posts classic form data (no JS body encoder)
  AEngine.AddSerializer(TMVCMediaType.APPLICATION_FORM_URLENCODED, TMVCURLEncodedSerializer.Create);

  // HTTPFilter chain (engine-wide). Order matters: first = outermost. The filters wrap the
  // whole request: the classic middleware, the routing and the action.
  // '/' (NOT ''): every URL falls through to the container routes when no file matches,
  // so the controllers keep precedence - bin/www only holds favicon.ico. An empty
  // prefix would fail the filter's sanity check on the first request.
  AEngine.Use(FileServerBundle('/', lWwwPath));

  // Security headers: the standard filter (X-XSS-Protection, X-Content-Type-Options)
  // plus CSP, X-Frame-Options and Referrer-Policy. The CDN origins are allow-listed
  // on purpose: htmx (unpkg) and UIkit (jsdelivr) load from there; 'unsafe-inline'
  // covers the small inline script in _baselayout.html.
  AEngine.Use(SecurityHeadersHTTPFilter());
  AEngine.Use(
    procedure(const AContext: TWebContext; const ANext: TMVCHTTPFilterNext)
    begin
      AContext.Response.SetCustomHeader('Content-Security-Policy',
        'default-src ''self''; ' +
        'script-src ''self'' https://unpkg.com https://cdn.jsdelivr.net ''unsafe-inline''; ' +
        'style-src ''self'' https://cdn.jsdelivr.net ''unsafe-inline''; ' +
        'img-src ''self'' data:; font-src ''self'' https://cdn.jsdelivr.net; ' +
        'object-src ''none''; base-uri ''self''; form-action ''self''; frame-ancestors ''none''');
      AContext.Response.SetCustomHeader('X-Frame-Options', 'DENY');
      AContext.Response.SetCustomHeader('Referrer-Policy', 'no-referrer');
      ANext();
    end);

  AEngine.Use(ETagHTTPFilter());
  AEngine.Use(CompressionHTTPFilter(1024));

  // Provides a FireDAC connection to MVCActiveRecord on each request.
  // The empty connection-def file name skips loading FDConnectionDefs.ini:
  // the definition is created programmatically in FDConnectionConfigU.
  AEngine.Use(ActiveRecordHTTPFilter(CON_DEF_NAME, ''));

  // Browser requests get the HTML error view; API clients get RFC 7807 problem+json.
  // ehShowDetails leaks the exception message: it is driven by the .env key
  // dmvc.error.show_details (true in development, set to false in production).
  lErrorOptions := [];
  if dotEnv.Env('dmvc.error.show_details', False) then
    Include(lErrorOptions, ehShowDetails);
  AEngine.UseExceptionHandler('error', 'delphitodohtmx', lErrorOptions);
end;

end.
