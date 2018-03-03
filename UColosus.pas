unit UColosus;

interface

uses Classes, Ujugada;


type

TVector = array[0..15] of char;


// de colosus 1 despues borrar
Tvectores = array[0..71] of TVector;

TVPuntaje = array[0..31] of Real;

TVpatrones = array[0..31, 0..6] of Char;
//-----------------------------------

//tablero
TMatriz = array[0..14] of TVector;

Tcoordenada = record
   i: integer;
   j: integer;
  end;

TVLinea5 = array[0..4] of Tcoordenada; //coordenadas de la linea ganadora

TParametro = record
  name, value: string;
end;

TParametros = array of TParametro;

TColosus = class;

TUpdateOutput = procedure(c: TColosus) of object;

TColosus = class
private
  aTurno: char;

  //direccion: 0 -> Horizontal, 1 -> Vertical, 2 -> diag 1, 3 -> diag 2
  function nextCoord(direccion:integer; var i, j:integer): Boolean;
  function prevCoord(direccion:integer; var i, j:integer): Boolean;

  procedure cambiarturno;

protected
  aTablero : TMatriz;
  aUpdateMethod: TUpdateOutput;
  aTTotalPensar: Real;
  aTpromPensar: Real;
  procedure UpdateOutput;
public
  constructor Create;
  procedure cargar_tablero(sl: TStrings); virtual;
  function pone_ficha(i,j: integer): Boolean; virtual;
  function getParametros(): TParametros; virtual; abstract;
  procedure setParametros(params: TParametros); virtual; abstract;
  procedure setPatron(Patron: string; valor: Real); virtual; abstract;
  function getBest(): Tcoordenada; virtual; abstract;
  function gano(ficha:char; ci,cj: integer; var linea: TVLinea5): Boolean;
  function getOutput: string; virtual; abstract;

  function takeback: Boolean; virtual; abstract;
  function takeforward: Boolean; virtual; abstract;
  procedure setTurno(turno: char); virtual; abstract;
  procedure test(const funcion: string); virtual; abstract;
  procedure reset; virtual;

  property Turno: char read aTurno;
  property Tablero: TMatriz read aTablero;
  property UpdateMethod: TUpdateOutput read aUpdateMethod write aUpdateMethod;
  property Tprompensar: real read aTpromPensar;
  property TTotalpensar: real read aTTotalPensar;
end;


implementation


constructor TColosus.Create;
var
 i,j: integer;
begin
   aTurno:= 'o';
   for i:=0 to 14 do
      for j:=0 to 14 do
         atablero[i,j]:= '-';

end;


procedure TColosus.cambiarturno;
begin
   if aTurno = 'o' then aTurno:='x' else aTurno:='o';
end;

procedure TColosus.cargar_tablero(sl: TStrings);
var
  i, j: Integer;
  s: string;
begin
  for i:= 0 to 14 do
    for j:= 0 to 14 do
    begin
      s:= sl[i];
      aTablero[i,j]:= s[j+1];
      if (aTablero[i,j] <> '-') then
          cambiarturno;
    end;
end;



function TColosus.gano(ficha: char; ci, cj: integer;
   var linea: TVLinea5): Boolean;
var
  cant: integer;
  auxi, auxj, d: integer;
  sigue: Boolean;
begin
  Result:= false;
  for d:=0 to 3 do
  begin
    cant:= 0;
    auxi:= ci;
    auxj:= cj;
    sigue:= true;
    while ((aTablero[auxi,auxj]=ficha) and sigue and (cant<5)) do
    begin
       linea[cant].i:= auxi;
       linea[cant].j:= auxj;
       inc(cant);
       sigue:= nextCoord(d,auxi,auxj);
    end;
    auxi:= ci;
    auxj:= cj;
    sigue:= prevCoord(d,auxi,auxj);
    while ((aTablero[auxi,auxj]=ficha) and sigue and (cant<5)) do
    begin
       linea[cant].i:= auxi;
       linea[cant].j:= auxj;
       inc(cant);
       sigue:= prevCoord(d,auxi,auxj);
    end;
    if (cant=5) then
    begin
       Result:= true;
       break;
    end;
  end;     
end;

function TColosus.nextCoord(direccion: integer; var i, j: integer): Boolean;
var
  si, sj: integer;
begin
  Result:= true;
  case direccion of
  0: begin
       si:= i;
       sj:= j + 1;
     end;
  1: begin
       si:= i + 1;
       sj:= j;
     end;
  2: begin
       si:= i + 1;
       sj:= j + 1;
     end;
  3: begin
       si:= i - 1;
       sj:= j + 1;
     end;
  end;
  if ((si > 14)or(si < 0)) then
    Result:= false
  else
    i:= si;
  if ((sj > 14)or(sj < 0)) then
    Result:= false
  else
    j:= sj;
end;

function TColosus.pone_ficha(i, j: integer): Boolean;
begin
  Result:= false;
  if (aTablero[i,j] = '-') then
  begin
     aTablero[i,j] := aTurno;
     Result:= true;
     cambiarturno;
  end;

end;

function TColosus.prevCoord(direccion: integer; var i, j: integer): Boolean;
var
  si, sj: integer;
begin
  Result:= true;
  case direccion of
  0: begin
       si:= i;
       sj:= j - 1;
     end;
  1: begin
       si:= i - 1;
       sj:= j;
     end;
  2: begin
       si:= i - 1;
       sj:= j - 1;
     end;
  3: begin
       si:= i + 1;
       sj:= j - 1;
     end;
  end;
  if ((si > 14)or(si < 0)) then
    Result:= false
  else
    i:= si;
  if ((sj > 14)or(sj < 0)) then
    Result:= false
  else
    j:= sj;

end;

procedure TColosus.reset;
var
 i,j: integer;
begin
   aTurno:= 'o';
   for i:=0 to 14 do
      for j:=0 to 14 do
         atablero[i,j]:= '-';
end;

procedure TColosus.UpdateOutput;
begin
  aUpdateMethod(self);
end;

end.
