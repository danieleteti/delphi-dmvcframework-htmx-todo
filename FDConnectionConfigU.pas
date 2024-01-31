unit FDConnectionConfigU;

interface

const
  CON_DEF_NAME = 'MyConnX';

procedure CreateSqlitePrivateConnDef(AIsPooled: boolean);

implementation

uses
  System.Classes,
  System.IOUtils,
  FireDAC.Comp.Client,
  FireDAC.Moni.Base,
  FireDAC.Moni.FlatFile,
  FireDAC.Stan.Intf
  ;


var
  gFlatFileMonitor: TFDMoniFlatFileClientLink = nil;

procedure CreateSqlitePrivateConnDef(AIsPooled: boolean);
var
  LParams: TStringList;
  lFName: string;
begin
  LParams := TStringList.Create;
  try
    lFName := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'todo.db');
    LParams.Add('Database=' + lFName);
    LParams.Add('StringFormat=Unicode');
    if AIsPooled then
    begin
      LParams.Add('Pooled=True');
      LParams.Add('POOL_MaximumItems=200');
    end
    else
    begin
      LParams.Add('Pooled=False');
    end;
    FDManager.AddConnectionDef(CON_DEF_NAME, 'SQLite', LParams);
  finally
    LParams.Free;
  end;
end;

initialization

gFlatFileMonitor := TFDMoniFlatFileClientLink.Create(nil);
gFlatFileMonitor.FileColumns := [tiRefNo, tiTime, tiThreadID, tiClassName, tiObjID, tiMsgText];
gFlatFileMonitor.EventKinds := [
    ekVendor, ekConnConnect, ekLiveCycle, ekError, ekConnTransact,
    ekCmdPrepare, ekCmdExecute, ekCmdDataIn, ekCmdDataOut];
gFlatFileMonitor.ShowTraces := False;
gFlatFileMonitor.FileAppend := False;
gFlatFileMonitor.FileName := TPath.ChangeExtension(ParamStr(0), '.trace.log');
gFlatFileMonitor.Tracing := True;

finalization

gFlatFileMonitor.Free;

end.

