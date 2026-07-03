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
  Result := RenderView('todo/_item');
end;

function TMyController.DeleteTodo(const id: Integer): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id, False);
  try
    if Assigned(lTodo) then
      lTodo.Delete(False);
  finally
    lTodo.Free;
  end;
  Result := ''; // htmx swaps outerHTML of the <li> with empty content -> removes the item
end;

function TMyController.EditTodo(const id: Integer): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id, False);
  if lTodo = nil then
    raise EMVCException.Create(HTTP_STATUS.NotFound, 'Todo not found');
  try
    ViewData['todo'] := lTodo;
    Result := RenderView('todo/_form');
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
    Result := RenderView('home');
  finally
    lTodos.Free;
  end;
end;

function TMyController.GetTodo(const id: Integer): String;
begin
  var lTodo := TMVCActiveRecord.GetByPK<TTodo>(id, False);
  if lTodo = nil then
    raise EMVCException.Create(HTTP_STATUS.NotFound, 'Todo not found');
  try
    ViewData['todo'] := lToDo;
    Result := RenderView('todo/_item');
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
  var lExisting := TMVCActiveRecord.GetByPK<TTodo>(id, False);
  if lExisting = nil then
    raise EMVCException.Create(HTTP_STATUS.NotFound, 'Todo not found');
  try
    lExisting.Content := ToDo.Content;
    lExisting.Update; // storage validation runs here -> 422 if content is empty
    ViewData['todo'] := lExisting;
    Result := RenderView('todo/_item');
  finally
    lExisting.Free;
  end;
end;

end.
