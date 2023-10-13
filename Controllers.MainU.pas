unit Controllers.MainU;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons, System.Generics.Collections,
  Entitiles.TodoU;

type

  [MVCPath]
  TMyController = class(TMVCController)
  protected
    procedure MVCControllerAfterCreate; override;
    procedure MVCControllerBeforeDestroy; override;
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    function GetAll: String;

    [MVCPath('/add')]
    [MVCHTTPMethod([httpPOST])]
    function AddTodo(const [MVCFromBody] ToDo: TTodo): String;

    [MVCPath('/delete/($id)')]
    [MVCHTTPMethod([httpDELETE])]
    function DeleteTodo(const id: Integer): String;

    [MVCPath('/edit/($id)')]
    [MVCHTTPMethod([httpGET])]
    function EditTodo(const id: Integer): String;

    [MVCPath('/edit/($id)')]
    [MVCHTTPMethod([httpPUT])]
    function SaveTodo(const id: Integer; const [MVCFromBody] ToDo: TTodo): String;
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, FireDAC.Comp.Client,
  System.StrUtils, MVCFramework.ActiveRecord,
  FDConnectionConfigU, JsonDataObjects;

function TMyController.AddTodo(const ToDo: TTodo): String;
begin
  ToDo.Store;
  var lJSON := ObjectToJSONObject(ToDo);
  try
    Result := PageFragment(['todo/item'], lJSON);
  finally
    lJSON.Free;
  end;
end;

function TMyController.DeleteTodo(const id: Integer): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id, False);
  try
    if Assigned(lTodo) then
    begin
      lTodo.Delete(False);
    end;
  finally
    lTodo.Free;
  end;
end;

function TMyController.EditTodo(const id: Integer): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id);
  try
    ViewData['todo'] := lTodo;
    Result := PageFragment(['todo/form']);
  finally
    lTodo.Free;
  end;
end;

function TMyController.GetAll: String;
begin
  var lTodos := TMVCActiveRecord.All<TTodo>;
  try
    ViewData['todos'] := lTodos;
    Result := Page(['home']);
  finally
    lTodos.Free;
  end;
end;

procedure TMyController.MVCControllerAfterCreate;
begin
  inherited;
  var lConn := TFDConnection.Create(nil);
  lConn.ConnectionDefName := CON_DEF_NAME;
  ActiveRecordConnectionsRegistry.AddDefaultConnection(lConn, True);
  SetPagesCommonHeaders(['header']);
  SetPagesCommonFooters(['footer']);
end;

procedure TMyController.MVCControllerBeforeDestroy;
begin
  ActiveRecordConnectionsRegistry.RemoveDefaultConnection(True);
  inherited;
end;

function TMyController.SaveTodo(const id: Integer; const ToDo: TTodo): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id);
  try
    ToDo.ID := id;
    ToDo.Store;
    var lJSON := ObjectToJSONObject(ToDo);
    try
      Result := PageFragment(['todo/item'], lJSON);
    finally
      lJSON.Free;
    end;
  finally
    lTodo.Free;
  end;

end;

end.
