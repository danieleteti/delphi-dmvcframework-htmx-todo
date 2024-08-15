unit Controllers.MainU;

interface

uses
  MVCFramework, MVCFramework.Serializer.Commons, System.Generics.Collections,
  Entities.TodoU, MVCFramework.HTMX, MVCFramework.Commons;

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

    [MVCPath('/todos/($id)')]
    [MVCHTTPMethod([httpGET])]
    function GetTodo(const id: Integer): String;
  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, FireDAC.Comp.Client,
  System.StrUtils, MVCFramework.ActiveRecord,
  FDConnectionConfigU, JsonDataObjects;

function TMyController.CreateTodo(const ToDo: TTodo): String;
begin
  ToDo.Insert;
  ViewData['todo'] := Todo;
  Result := Page(['todo/_item']);
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
    Result := PageFragment(['todo/_form']);
  finally
    lTodo.Free;
  end;
end;

function TMyController.GetAll: String;
begin
  var lTodos := TMVCActiveRecord.All<TTodo>;
  try
    ViewData['todos'] := lTodos;
    ViewData['version'] := 'DMVCFramework ' + DMVCFRAMEWORK_VERSION;
    Result := Page(['home']);
  finally
    lTodos.Free;
  end;
end;

function TMyController.GetTodo(const id: Integer): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id);
  try
    ViewData['todo'] := lToDo;
    Result := Page(['todo/_item']);
  finally
    lTodo.Free;
  end;
end;

procedure TMyController.OnBeforeAction(AContext: TWebContext;
  const AActionName: string; var AHandled: Boolean);
begin
  inherited;
  ViewData['ispage'] := not Context.Request.IsHTMX;
end;

function TMyController.UpdateTodo(const id: Integer; const ToDo: TTodo): String;
begin
  ToDo.ID := id;
  ToDo.Update;
  ViewData['todo'] := ToDo;
  Result := Page(['todo/_item']);
end;

end.
