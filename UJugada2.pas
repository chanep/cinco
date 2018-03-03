unit UJugada2;

interface
uses
StrUtils, SysUtils, Contnrs;


type

TjugadaR= record
  i: shortint; //coordenada vertical
  j: shortint; //coordenada horizontal
  p: Integer;    //puntaje
  hay4: Boolean;
end;

TJugada=class
private
public
  i: shortint; //coordenada vertical
  j: shortint; //coordenada horizontal
  p: Integer;    //puntaje
  prox: Tjugada;
  constructor Create(i,j: shortint; p: integer);
  destructor Destroy; override;
  function ruta: string;
  function prof: shortint;
  function copiar: Tjugada;
end;

TJugadas=class(TObjectList)
  public
    function get(indice: integer): TJugada; // inline;
    function toString(): string;
    procedure ordenar;
    property ts: string read toString;
  end;

TJugadasR=class
  private
    ajugadas: array[0..224] of TJugadaR;
    aOrden: array[0..224] of integer;
    aCount: Integer;
    procedure q_sort(left, right: Integer);
    function toString(): string;
  public
    constructor Create;
    procedure add(const i,j: shortint; const punt: Integer; const hay4: Boolean); inline;
    function get(const indice: integer): TJugadaR; inline;
    function geti(const indice: integer): Integer; inline;
    function getj(const indice: integer): Integer; inline;
    function getp(const indice: integer): Integer; inline;
    procedure setp(const indice, punt: integer); inline;
    procedure seti(const indice, i: integer); inline;
    procedure setj(const indice, j: integer); inline;
    function geth4(const indice: integer): Boolean; inline;
    procedure ordenar;
    property Count: Integer read aCount write aCount;
    property ts: string read tostring;
  end;

var
  jdif: integer = 0;
  jcreadas: integer = 0;
  ljcreadas: integer = 0;

implementation

function Comparar(Item1, Item2: Tjugada): Integer;
begin
  if Item1.p > Item2.p then Result:= -1
  else if Item1.p < Item2.p then Result:= 1
  else  Result:= 0;
end;

{ TJugada }
constructor TJugada.Create(i, j: shortint; p: integer);
begin
  self.i:= i;
  self.j:= j;
  self.p:= p;
  prox:= nil;
  inc(jdif);
  inc(jcreadas);
end;

destructor TJugada.destroy;
begin
  dec(jdif);
  if prox <> nil then prox.Free;
  inherited;
end;

function TJugada.ruta: string;
begin
  Result:= '('+inttostr(i)+','+inttostr(j)+')';
  if prox <> nil then
     if (prox.i <> -1) then
        Result:= Result + prox.ruta;
end;


function TJugada.copiar: Tjugada;
var
  copia: Tjugada;
begin
  copia:= Tjugada.Create(i,j,p);
  if prox <> nil then
     copia.prox:= prox.copiar;
  Result:= copia;
end;


function TJugada.prof: shortint;
begin
   if self.prox = nil then
      Result:= 0
   else
      Result:= 1 + prox.prof;
end;


{ TJugadas }

function TJugadas.get(indice: integer): TJugada;
begin
   REsult:= TJugada(self[indice]);
end;

function TJugadas.toString: string;
var
  i: integer;
begin
  for i:=0 to (self.Count -1) do
  begin
    Result:= Result + Inttostr(i) + ' ->('+Inttostr(get(i).i)+','+
             Inttostr(get(i).j)+','+ Inttostr(get(i).p)+')  ';
  end;
end;

procedure TJugadas.ordenar;
begin
   self.Sort(@comparar);
end;


{ TJugadasR }

constructor TJugadasR.Create;
begin
  aCount:= 0;
  inc(ljcreadas);
end;

procedure TJugadasR.add(const i, j: shortint; const punt: Integer; const hay4: Boolean);
begin
   aJugadas[aCount].i:= i;
   aJugadas[aCount].j:= j;
   aJugadas[aCount].p:= punt;
   aJugadas[aCount].hay4:= hay4;
   aOrden[aCount]:= aCount;
   inc(aCount);
end;


function TJugadasR.get(const indice: integer): TJugadaR;
begin
   Result.i:= aJugadas[aOrden[indice]].i;
   Result.j:= aJugadas[aOrden[indice]].j;
   Result.p:= aJugadas[aOrden[indice]].p;
   Result.hay4:= aJugadas[aOrden[indice]].hay4;
end;


function TJugadasR.geth4(const indice: integer): Boolean;
begin
   Result:= aJugadas[aOrden[indice]].hay4;
end;

function TJugadasR.geti(const indice: integer): Integer;
begin
   Result:= aJugadas[aOrden[indice]].i;
end;

function TJugadasR.getj(const indice: integer): Integer;
begin
   Result:= aJugadas[aOrden[indice]].j;
end;

function TJugadasR.getp(const indice: integer): Integer;
begin
   Result:= aJugadas[aOrden[indice]].p;
end;

procedure TJugadasR.setp(const indice, punt: integer);
begin
   aJugadas[aOrden[indice]].p:=  punt;
end;

procedure TJugadasR.seti(const indice, i: integer);
begin
   aJugadas[aOrden[indice]].i:=  i;
end;

procedure TJugadasR.setj(const indice, j: integer);
begin
   aJugadas[aOrden[indice]].j:=  j;
end;

procedure TJugadasR.ordenar;
begin
   q_sort(0, aCount - 1);
end;

procedure TJugadasR.q_sort(left, right: Integer);
var
  pivot, l_hold, r_hold: Integer;
begin

  l_hold:= left;
  r_hold:= right;
  pivot:= aOrden[left];
  while (left < right) do
  begin
    while ((aJugadas[aOrden[right]].p <= aJugadas[pivot].p) and (left < right)) do
      dec(right);
    if (left <> right) then
    begin
      aOrden[left] := aOrden[right];
      inc(left);
    end;
    while ((aJugadas[aOrden[left]].p >= aJugadas[pivot].p) and (left < right)) do
      inc(left);
    if (left <> right) then
    begin
      aOrden[right] := aOrden[left];
      dec(right);
    end;
  end;
  aOrden[left] := pivot;
  pivot := left;
  left := l_hold;
  right := r_hold;
  if (left < pivot) then
    q_sort( left, pivot-1);
  if (right > pivot) then
    q_sort( pivot+1, right);

end;

function TJugadasR.toString: string;
var
  i: Integer;
  h4: string;
begin
  Result:='';
  for i:=0 to (aCount - 1) do
  begin
    if get(i).hay4 then h4:= '1' else h4:= '0';
    Result:= Result + Inttostr(i) + ' ->('+Inttostr(get(i).i)+','+
             Inttostr(get(i).j)+','+ Inttostr(get(i).p)+','+ h4 +')  ';
  end;
end;



end.
