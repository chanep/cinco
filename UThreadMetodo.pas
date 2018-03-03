unit UThreadMetodo;
{este es un tread generico que ejecuta un metodo cualquiera de un objeto
 que recive como parametro al crearse. Esto lo usa un objeto cuando quiere
 ejecutar alguno de sus metodos en un thread distinto al thread principal
 de la aplicacion. De esta forma si el procedimiento es largo la aplicacion
 no permanece congelada hasta el fin del metodo}

interface

uses
  Classes;

type

  TMetodo= procedure of object;

  TThreadMetodo = class(TThread)
  private
    aMetodo: TMetodo;
    { Private declarations }
  protected
    procedure Execute; override;
  public
  {el parametro es un metodo de algun objeto que se quiere que el thread
   corra en su ejecucion}
  constructor Crear(Metodo: TMetodo);
  procedure sincronizar(Metodo: TMetodo);
  end;

implementation

{ Important: Methods and properties of objects in VCL or CLX can only be used
  in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TThreadMetodo.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TThreadMetodo }

constructor TThreadMetodo.Crear(Metodo: TMetodo);
begin
  aMetodo:= Metodo;
  inherited Create(false);
  Priority:= tpLowest;
end;

procedure TThreadMetodo.Execute;
begin
  //FreeonTerminate:= true;
  aMetodo;
  self.Terminate;
end;



procedure TThreadMetodo.sincronizar(Metodo: TMetodo);
begin
    Synchronize(metodo);
end;

end.
