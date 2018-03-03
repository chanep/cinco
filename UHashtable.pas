unit UHashtable;

interface

uses
 uTipos2, SysUtils, math;

 const
    cVacio: Integer = -1000000;

type

TPosicion=record
   hash: Int64;
   puntaje: Integer;
   prof: shortint;
   tipo: integer;
end;



TLinea = record
  hash: Int64;
  puntaje: array[0..1] of Integer;
  danger: integer;
end;

TPLinea = ^TLinea;

THashTable=class
private
   aSize: Integer;
   aSizel: Integer;
   aSizem1: Integer;
   aSizelm1: Integer;
   aRandoms: array[0..460] of Int64;  //la 450 corresponde a la NullMove
   aPosiciones: array of TPosicion;
   aLineas: array of  Tlinea;

   oGetHash: Integer;
   oPosGuardadas: Integer;
   oPosEncontradas: Integer;
   oPosNoEncontradas: Integer;
   oLineasEncontradas: Integer;
   oLineasNoEncontradas: Integer;
   oPosActualizadas: Integer;
   oPosSobreWin: Integer;
   oPosSobreWW: Integer;
   oColisiones: Integer;
   oColisionesLinea: Integer;

public
   constructor Create(size, sizel: Integer);
   //function getHash(const aBB: array of TBitBoard): Int64; overload;
   procedure getHash(var hashant: Int64; const ficha, i, j: Tsi); inline;
   function getHashLIni(const l: Tsi): Int64; inline;
   procedure getHashL(var hashant: Int64; const ficha, j: Tsi); inline; register;
   function getHashL2(const hashant: Int64; const ficha, j: Tsi): Int64; inline; register;
   function guardarPosicion(const hash: Int64; const puntaje: Integer;
                             const prof: shortint; const tipo: integer): Boolean;
   function getPosicion(const hashant: Int64; const ficha, i, j: Tsi;
                            var puntaje: integer; var prof: shortint; var tipo: integer): Boolean;
   function getLinea(const hash: Int64; const turno: Tsi; var puntaje: Integer;
                       var danger: integer): Boolean;  inline; register;
   function guardarLinea(const hash: Int64; const turno: Tsi; const puntaje: Integer;
                         const danger: integer): Boolean; inline;
   function getOutput: string;                         
   procedure resetContadores;
   procedure vaciar;
   procedure limpiar;
end;

implementation

{ THashTable }

constructor THashTable.Create(size, sizel: Integer);
var
   i, j, r: Integer;
   r64: Int64;
begin
   aSize:= Round(Power(2,Int(Log2(size))));
   aSizel:= Round(Power(2,Int(Log2(sizel))));
   aSizem1:= aSize - 1;
   aSizelm1:= aSizel - 1;
   SetLength(aPosiciones,aSize);
   SetLength(aLineas,aSizel);
   for i:= 0 to (aSize - 1) do
      aPosiciones[i].hash := 0;
   for i:= 0 to (aSizel - 1) do
      aLineas[i].hash := 0;
   Randomize;
   i:= 0;
   while (i < length(aRandoms)) do
   begin
      r64:= Random(High(r));
      r64:= (r64 shl 32) + Random(High(r));
      aRandoms[i]:= r64;
      for j:=0 to (i - 1) do
      begin
         if (aRandoms[j] = r64) then
         begin
            break;
            dec(i);
         end;
      end;
      inc(i);
   end;
end;



{function THashTable.getHash(const aBB: array of TBitBoard): Int64;
var
  k, m, n, indice: Integer;
  hash: Int64;
begin
  inc(oGetHash); //---
  hash:= 0;
  for k:= 0 to 1 do
     for m:= 0 to 14 do
        for n:= 0 to 14 do
           if ((aBB[k,m] and (1 shl n))<>0) then
           begin
              indice:= n + m*15 + k*15*15;
              hash:= hash xor aRandoms[indice];
           end;
  Result:= hash;
end; }


procedure THashTable.getHash(var hashant: Int64; const ficha, i, j: Tsi);
begin
   inc(oGetHash); //---
   hashant:= hashant xor aRandoms[i + j*15 + ficha*15*15];
end;


procedure THashTable.getHashL(var hashant: Int64; const ficha, j: Tsi);
begin
   hashant:= hashant xor aRandoms[j + ficha*15];
end;

function THashTable.getHashL2(const hashant: Int64; const ficha, j: Tsi): Int64;
begin
   Result:= hashant xor aRandoms[j + ficha*15];
end;


function THashTable.getHashLIni(const l: Tsi): Int64;
begin
   Result:= aRandoms[450 + l];
end;

function THashTable.getLinea(const hash: Int64; const turno: Tsi;
  var puntaje: Integer; var danger: integer): Boolean;
var
  indice: Integer;
  plinea: TPLinea;
begin
   plinea:= @aLineas[hash and aSizelm1];
   if ((plinea^.hash = hash) and (plinea^.puntaje[turno] <> cVacio)) then
   begin
      inc(oLineasEncontradas); //---
      Result:= true;
      puntaje:= plinea^.puntaje[turno];
      danger:= plinea^.danger;
   end else
   begin
      inc(oLineasNoEncontradas); //---
      Result:= false;
   end;
end;

function THashTable.guardarLinea(const hash: Int64; const turno: Tsi;
  const puntaje: Integer; const danger: integer): Boolean;
var
  indice: Integer;
begin
   Result:= true;
   indice:= hash and aSizelm1;
   if (aLineas[indice].hash = 0) then
   begin
      aLineas[indice].hash:= hash;
      aLineas[indice].puntaje[turno] := puntaje;
      aLineas[indice].puntaje[turno xor 1] := cVacio;
      aLineas[indice].danger:=  danger;
   end else
      if (aLineas[indice].hash <> hash) then
      begin
         Result:= false;
         inc(oColisionesLinea); //---
         aLineas[indice].hash:= hash;
         aLineas[indice].puntaje[turno] := puntaje;
         aLineas[indice].puntaje[turno xor 1] := cVacio;
         aLineas[indice].danger:=  danger;
      end
      else begin
         aLineas[indice].puntaje[turno] := puntaje;
      end;

end;


function THashTable.getOutput: string;
begin
   Result:= 'HashTable'#13#10 +
            '----------------'#13#10 +
            'GetHash: ' + InttoStr(oGetHash) + ''#13#10 +
            'Pos Encontradas: ' + InttoStr(oPosEncontradas) + ''#13#10 +
            'Pos No Encontradas: ' + InttoStr(oPosNoEncontradas) + ''#13#10 +
            'Lineas Encontradas: ' + InttoStr(oLineasEncontradas) + ''#13#10 +
            'Lineas No Encontradas: ' + InttoStr(oLineasNoEncontradas) + ''#13#10 +
            'Pos Guardadas: ' + InttoStr(oPosGuardadas) + ''#13#10 +
            'Pos Actualiz: ' + InttoStr(oPosActualizadas) + ''#13#10 +
            'Colisiones: ' + InttoStr(oColisiones) + ''#13#10 +
            'Colisiones L: ' + InttoStr(oColisionesLinea) + ''#13#10 +
            'Try Sobreesc. Win: ' + InttoStr(oPosSobreWin) + ''#13#10 +
            'Try Sobreesc. W/W: ' + InttoStr(oPosSobreWW) + ''#13#10
            ;
end;


function THashTable.getPosicion(const hashant: Int64; const ficha, i, j: Tsi;
  var puntaje: integer; var prof: shortint; var tipo: integer): Boolean;
var
  indice: Integer;
  hash: Int64;
begin
   hash:= hashant xor aRandoms[i + j*15 + ficha*15*15];
   indice:= hash and aSizem1;
   if (aPosiciones[indice].hash = hash) then
   begin
      inc(oPosEncontradas); //---
      Result:= true;
      puntaje:= aPosiciones[indice].puntaje;
      prof:= aPosiciones[indice].prof;
      tipo:= aPosiciones[indice].tipo;
   end else
   begin
      inc(oPosNoEncontradas); //---
      Result:= false;
   end;
end;



function THashTable.guardarPosicion(const hash: Int64; const puntaje: Integer;
                             const prof: shortint; const tipo: integer): Boolean;
var
  indice: Integer;
begin

   Result:= true;

   indice:= hash and aSizem1;
   if (aPosiciones[indice].hash = 0) then
   begin
      inc(oPosGuardadas); //---
      aPosiciones[indice].hash:= hash;
      aPosiciones[indice].puntaje:= puntaje;
      aPosiciones[indice].prof:= prof;
      aPosiciones[indice].tipo:= tipo;
   end else
      if (aPosiciones[indice].hash <> hash) then
      begin
         Result:= false;
         inc(oColisiones); //---
            aPosiciones[indice].hash:= hash;
            aPosiciones[indice].puntaje:= puntaje;
            aPosiciones[indice].prof:= prof;
            aPosiciones[indice].tipo:= tipo;
      end
      else
         if (aPosiciones[indice].prof < prof) then
         begin
            inc(oPosActualizadas); //---
            aPosiciones[indice].puntaje:= puntaje;
            aPosiciones[indice].prof:= prof;
            aPosiciones[indice].tipo:= tipo;
         end; 
end;

procedure THashTable.limpiar;
var
  i: Integer;
begin
   for i:= 0 to (aSize - 1) do
      if (Abs(aPosiciones[i].puntaje) > 60000) then
         aPosiciones[i].hash := 0;
end;

procedure THashTable.resetContadores;
begin
   oGetHash:= 0;
   oPosGuardadas:= 0;
   oPosActualizadas:= 0;
   oColisiones:= 0;
   oPosEncontradas:= 0;
   oPosNoEncontradas:= 0;
   oLineasEncontradas:= 0;
   oLineasNoEncontradas:= 0;
   oColisionesLinea:= 0;
   oPosSobreWin:= 0;
   oPosSobreWW:= 0;
end;

procedure THashTable.vaciar;
var
  i:integer;
begin
   for i:= 0 to (aSize - 1) do
      aPosiciones[i].hash := 0;
  // for i:= 0 to (aSizel - 1) do
  //    aLineas[i].hash := 0;
end;



end.
