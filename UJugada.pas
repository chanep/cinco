unit UJugada;

interface
uses
StrUtils, SysUtils;


type
TJugada=class
private
public
  i: Integer; //coordenada vertical
  j: Integer; //coordenada horizontal
  p: Real;    //puntaje relativo de la jugada (para ordenar de mejor a peor)
  pabs: Real; //punt absoluto (para restarse a la jugada anterior)
  prox: Tjugada;
  constructor Create(ii,jj: Integer; pp,ppabs: real);
  destructor Destroy; override;
  function ruta: string;
  function copiar: Tjugada; virtual;
end;

TJugada2 = class(TJugada)
public
  Ahubo3o4: Boolean;
  Ahubo3o4adv: Boolean;
  constructor Create(ii,jj: Integer; pp,ppabs: real; hubo3o4, hubo3o4adv: Boolean);
  function copiar: Tjugada2;
end;


implementation

{ TJugada }
constructor TJugada.Create(ii, jj: Integer; pp,ppabs: real);
begin
  i:= ii;
  j:= jj;
  p:= pp;
  pabs:= ppabs;
  prox:= nil;
end;

destructor TJugada.destroy;
begin
  if prox <> nil then prox.Free;
  inherited;
end;

function TJugada.ruta: string;
begin
  Result:= '('+inttostr(i)+','+inttostr(j)+')';
  if prox <> nil then
     Result:= Result + prox.ruta;
end;


function TJugada.copiar: Tjugada;
var
  copia: Tjugada;
begin
  copia:= Tjugada.Create(i,j,p,pabs);
  if prox <> nil then
     copia.prox:= prox.copiar;
  Result:= copia;
end;


{ TJugada2 }

function TJugada2.copiar: Tjugada2;
var
  copia: Tjugada2;
begin
  copia:= Tjugada2.Create(i,j,p,pabs,Ahubo3o4, Ahubo3o4adv);
  if prox <> nil then
     copia.prox:= TJugada2(prox).copiar;
  Result:= copia;
end;

constructor TJugada2.Create(ii, jj: Integer; pp, ppabs: real;
  hubo3o4, hubo3o4adv: Boolean);
begin
  inherited Create(ii,jj,pp,ppabs);
  Ahubo3o4:= hubo3o4;
  Ahubo3o4adv:= hubo3o4adv;
end;

end.
 