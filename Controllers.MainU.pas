unit Controllers.MainU;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons, System.Generics.Collections,
  Entities.TodoU;

type

  [MVCPath]
  TMyController = class(TMVCController)
  protected
    procedure OnBeforeAction(AContext: TWebContext; const AActionName: string; var AHandled: Boolean); override;
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    function GetAll: String;

    [MVCPath('/add')]
    [MVCHTTPMethod([httpPOST])]
    function CreateTodo(const [MVCFromBody] ToDo: TTodo): String;

    [MVCPath('/delete/($id)')]
    [MVCHTTPMethod([httpDELETE])]
    function DeleteTodo(const id: Integer): String;

    [MVCPath('/edit/($id)')]
    [MVCHTTPMethod([httpGET])]
    function EditTodo(const id: Integer): String;

    [MVCPath('/edit/($id)')]
    [MVCHTTPMethod([httpPUT])]
    function UpdateTodo(const id: Integer; const [MVCFromBody] ToDo: TTodo): String;
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, FireDAC.Comp.Client,
  System.StrUtils, MVCFramework.ActiveRecord,
  FDConnectionConfigU, JsonDataObjects;

function TMyController.CreateTodo(const ToDo: TTodo): String;
begin
  ToDo.Insert;
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

procedure TMyController.OnBeforeAction(AContext: TWebContext; const AActionName: string; var AHandled: Boolean);
begin
  inherited;
  SetPagesCommonHeaders(['header']);
  SetPagesCommonFooters(['footer']);
end;

function TMyController.UpdateTodo(const id: Integer; const ToDo: TTodo): String;
begin
  ToDo.ID := id;
  ToDo.Update(True);
  var lJSON := ObjectToJSONObject(ToDo);
  try
    Result := PageFragment(['todo/item'], lJSON);
  finally
    lJSON.Free;
  end;
end;

end.
