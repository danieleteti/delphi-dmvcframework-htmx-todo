unit WebModuleU;

interface

uses 
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  MVCFramework;

type
  TMyWebModule = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    FMVC: TMVCEngine;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TMyWebModule;

implementation

{$R *.dfm}

uses 
  System.IOUtils, 
  MVCFramework.Commons, 
  MVCFramework.Middleware.ActiveRecord, 
  MVCFramework.Middleware.StaticFiles,
  MVCFramework.View.Renderers.TemplatePro,
  MVCFramework.Middleware.Analytics,
  MVCFramework.Middleware.Trace, 
  MVCFramework.Middleware.CORS, 
  MVCFramework.Middleware.ETag,
  MVCFramework.Middleware.Compression,
  MVCFramework.Serializer.URLEncoded,
  Controllers.MainU, FDConnectionConfigU;

procedure TMyWebModule.WebModuleCreate(Sender: TObject);
begin
  FMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      //default content-type
      Config[TMVCConfigKey.DefaultContentType] := dotEnv.Env('dmvc.default.content_type', TMVCMediaType.TEXT_HTML);
      //default content charset
      Config[TMVCConfigKey.DefaultContentCharset] := dotEnv.Env('dmvc.default.content_charset', TMVCConstants.DEFAULT_CONTENT_CHARSET);
      //unhandled actions are permitted?
      Config[TMVCConfigKey.AllowUnhandledAction] := dotEnv.Env('dmvc.allow_unhandled_actions', 'false');
      //enables or not system controllers loading (available only from localhost requests)
      Config[TMVCConfigKey.LoadSystemControllers] := dotEnv.Env('dmvc.load_system_controllers', 'true');
      //default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := dotEnv.Env('dmvc.default.view_file_extension', 'html');
      //view path
      Config[TMVCConfigKey.ViewPath] := dotEnv.Env('dmvc.view_path', 'templates');
      //use cache for server side views (use "false" in debug and "true" in production for faster performances
      Config[TMVCConfigKey.ViewCache] := dotEnv.Env('dmvc.view_cache', 'false');
      //Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := dotEnv.Env('dmvc.max_entities_record_count', IntToStr(TMVCConstants.MAX_RECORD_COUNT));
      //Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := dotEnv.Env('dmvc.expose_server_signature', 'false');
      //Enable X-Powered-By Header in response
      Config[TMVCConfigKey.ExposeXPoweredBy] := dotEnv.Env('dmvc.expose_x_powered_by', 'true');
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := dotEnv.Env('dmvc.max_request_size', IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE));
    end);
  FMVC.AddController(TMyController);

  
  
  // Analytics middleware generates a csv log, useful to do traffic analysis
  //FMVC.AddMiddleware(TMVCAnalyticsMiddleware.Create(GetAnalyticsDefaultLogger));
  
  // The folder mapped as documentroot for TMVCStaticFilesMiddleware must exists!
  FMVC.AddMiddleware(TMVCStaticFilesMiddleware.Create('', TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'www')));

  FMVC.SetViewEngine(TMVCTemplateProViewEngine);
  FMVC.AddSerializer(TMVCMediaType.APPLICATION_FORM_URLENCODED, TMVCURLEncodedSerializer.Create);
  
  // Trace middlewares produces a much detailed log for debug purposes
  //FMVC.AddMiddleware(TMVCTraceMiddleware.Create);
  
  // CORS middleware handles... well, CORS
  //FMVC.AddMiddleware(TMVCCORSMiddleware.Create);
  
  // Simplifies TMVCActiveRecord connection definition
  FMVC.AddMiddleware(TMVCActiveRecordMiddleware.Create(
    CON_DEF_NAME, ''
  ));

  
  // Compression middleware must be the last in the chain, just before the ETag, if present.
  //FMVC.AddMiddleware(TMVCCompressionMiddleware.Create);
  
  // ETag middleware must be the latest in the chain
  //FMVC.AddMiddleware(TMVCETagMiddleware.Create);
 
   
  
  {
  FMVC.OnWebContextCreate( 
    procedure(const Context: TWebContext) 
    begin 
      // Initialize services to make them accessibile from Context 
      // Context.CustomIntfObject := TMyService.Create; 
    end); 
  
  FMVC.OnWebContextDestroy(
    procedure(const Context: TWebContext)
    begin
      //Cleanup services, if needed
    end);
  }
end;

procedure TMyWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.
