unit FDConnectionConfigU;

interface

const
  CON_DEF_NAME = 'MyConnX';

procedure CreateSqlitePrivateConnDef(AIsPooled: boolean);

// Creates bin/todo.db (if missing) and applies bin/schema.sql so a fresh
// checkout runs without shipping a binary database. Safe no-op if both exist.
procedure EnsureSqliteDatabase;

implementation

uses
  System.Classes,
  System.IOUtils,
  FireDAC.Comp.Client,
  FireDAC.Comp.Script,
  FireDAC.Stan.Intf;

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

procedure EnsureSqliteDatabase;
const
  FALLBACK_SQL = 'CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT(200));';
var
  lDbPath, lSchemaPath, lSQL: string;
  lConn: TFDConnection;
  lScript: TFDScript;
begin
  lDbPath := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'todo.db');
  lSchemaPath := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'schema.sql');
  lConn := TFDConnection.Create(nil);
  try
    lConn.DriverName := 'SQLite';
    lConn.LoginPrompt := False;
    lConn.Params.Add('Database=' + lDbPath);
    lConn.Open;
    if TFile.Exists(lSchemaPath) then
      lSQL := TFile.ReadAllText(lSchemaPath)
    else
      lSQL := FALLBACK_SQL;
    lScript := TFDScript.Create(nil);
    try
      lScript.Connection := lConn;
      lScript.SQLScripts.Add.SQL.Text := lSQL;
      lScript.ExecuteAll;
    finally
      lScript.Free;
    end;
    lConn.Close;
  finally
    lConn.Free;
  end;
end;

end.

