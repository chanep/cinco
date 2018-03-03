unit UColosus2;

interface

uses Classes, SysUtils, Contnrs, math, StrUtils, Ujugada2, UColosus, Utipos2,
     UHashTable, DateUtils, Dialogs, UThreadMetodo;


const

  cProfNullMove: array[0..10] of integer = (0,0,0,1,2,3,4,3,3,3,3);

type

TPatron = record
  patron: Tui;
  mask: Tui;
  puntaje: Integer;
end;

TPPatron = ^TPatron;

TcoordBB = array[0..3] of TCoordenada;

TColosus2 = class(TColosus)
private
  aHashtable: THashTable;
  aTurno: Tsi; // 0 -> es el turno de o, 1 -> es el turno de x
  aYo: Tsi;
  aBBfichas: array[0..1] of TBitBoard;
  aBBfuera: TBitBoard;
  aBBmuertos: array[0..1] of TBitBoard;
  aTablero2BB: array[0..14,0..14] of TcoordBB;
  aCantFichas: array[0..1] of array[0..71] of Tsi;
  aHashLineas: array[0..71] of Int64;
  aPatrones: array[0..1] of array[0..4] of array of TPatron;
  aProfact: Tsi;
  aHash: Int64;   //hashkey de la posicion actual
  aVacio: Boolean;
  aCorte: Boolean;
  aJAnterior: TCoordenada;
  aBestAnt: TCoordenada;
  aFichasTotales: Integer;
  aOutput: string;
  aTPromActual: Real;
  aTAcumulado: Real;
  aFechaInicio: TDateTime;   //Tiempo en donde empezo a pensar
  aCortoPrimera: Boolean;
  aCantMovidas: Integer;  //cantidad de movidas que hizo colosus
  aPV: array[0..200] of Tcoordenada;  //Principal variation
  aesPV: Boolean;                    //si el path actual es parte del PV
  aPVant: array[0..200] of Tcoordenada;  //Principal variation
  aGuessCorriendo: Boolean;
  aGuessBest: TCoordenada;
  aGuess: TCoordenada;
  aCortarPorTiempo: Boolean;
  aTerminarGuess: Boolean;
  aThreadGuess: TThreadMetodo;
  aTiempoGuess: real;
  aPermanentBrain: integer;

  aTprom: Real;  //Tiempo promedio por jugada
  aProf: Tsi; //profundidad de busqueda
  aNCorteQuiesIni: Integer;
  aNCorteQuiesFin: Integer;
  aDos4: Integer;
  a4y3: Integer;
  a4y3adv: Integer;
  aDos3: Integer;
  a4Dif: Integer;
  aPegado: Integer;
  aParImpar: Integer;
  aSel: Integer;
  aSelBanda: Integer;
  aTipoSel: Integer;
  aFinPegado: Integer;
  aQuies3: Integer;
  aQ3prof: Integer;
  aRandom: Integer;

  oNodos: Integer;
  oNodosQ: Integer;
  oNodosQ3: Integer;
  oEvaluados: Integer;
  oEvaluadosNull: Integer;
  oPuntaje: Integer;
  oBestPath: string;
  oCutOffs: Integer;
  oAlphaBetas: Integer;
  oLegales: Integer;
  oLegalesp1: Integer;
  oLegalespn: Integer;
  oTablero2BB: Integer;
  oTiempo: real;
  oEvHash: integer;
  oEvnohash: Integer;
  oPone: Integer;
  oHash: array[0..10] of integer;
  oNoHash: array[0..10] of integer;
  oCorteNM: integer;
  oSelTotal: Integer;
  oSelbien: Integer;
  oSelmal: Integer;
  oPmax: Integer;

  procedure inicializarBB;
  procedure inicializarTablero2BB;
  function int2bin(n: Integer): string;
  procedure BB2Tablero(const iBB, jBB: Tsi; var i, j: Tsi);
  function  Tablero2BB(const i, j: Tsi): TCoordBB;
  procedure pone_ficha_BB(i,j: Tsi;  poner: Boolean);
  procedure pone_ficha_BB_sinhash(i,j: Tsi;  poner: Boolean);
  function  puntPosicion(const i,j:Tsi): Integer; inline;
  function  esLegal(const i, j: Tsi): Boolean; inline;
  function  esLegal4(const i, j: Tsi): Boolean; inline;
  function  esLegal3(const i, j: Tsi): Boolean; inline;
  function  estaPegado(i, j: Tsi): Boolean; inline;
  procedure actualizarMuertos(i, j: Tsi);
  procedure legales(var lj: TJugadasR; prof: shortint; var h3gral: Boolean);
  procedure legales4(var lj: TJugadasR);
  procedure legales43(var lj: TJugadasR; var tapa4, hay4, tapa3, hay3: Boolean; const prof: shortint);
  procedure legales432(var lj: TJugadasR; var tapa4, hay4, tapa3, hay3: Boolean; const prof: shortint);
  function evaluarDif(const i, j: Tsi; var habia3, hay4: Boolean): integer;
  function evaluarDif43(const i, j: Tsi; var hay4, tapa3, hay3: Boolean): integer;
  function evaluarNull: integer;
  function quies(alpha: integer; const beta: integer; const i, j: integer; const prof: shortint): TJugada;
  function quies43(alpha: integer; const beta: integer; const i, j: integer; const prof: shortint): TJugada;
  function alphabeta( const prof: shortint; alpha: integer; const  beta: integer; const i, j: integer): TJugada;
  function alphabeta2( const prof: shortint; alpha: integer; const  beta: integer; const i, j: integer): TJugada;
  procedure cargarPV(best: TJugada);
  procedure resetContadores;
  procedure armarOutput;
  function segunda: Tcoordenada;
  function tElapsed: Real; inline;
  procedure guessBest();

public
  constructor Create();
  procedure reset; override;
  destructor Destroy; override;
  procedure cargar_tablero(sl: TStrings); override;
  function pone_ficha(i,j: integer): Boolean; override;
  function getParametros(): TParametros; override;
  procedure setParametros(params: TParametros); override;
  procedure setPatron(Patron: string; valor: Real); override;
  function getBest(): TCoordenada; override;
  function takeback: Boolean; override;
  function takeforward: Boolean; override;
  procedure setTurno(turno: char); override;
  function getOutput: string; override;
  procedure test(const funcion: string); override;

end;




implementation



constructor TColosus2.Create;
var
 j: TJugadas;
 jr: TJugadasR;
begin
   inherited create;
   aHashTable := THashTable.Create(2000000 , 2000000);
   aHash:= 0;
   aFichasTotales:= 0;
   aCantMovidas:= 0;
   aTTotalPensar:= 0;

   aTAcumulado:= 0;
   aVacio:= true;
   inicializarBB;
   inicializarTablero2BB;
   if aProf=98 then j.ts;
   if aProf=98 then jr.ts;
   if aProf=98 then self.int2bin(3);
end;


procedure TColosus2.cargar_tablero(sl: TStrings);
var
  i,j: Tsi;
begin
  inherited cargar_tablero(sl);
  for j:=0 to 14 do
    for i:=0 to 14 do
    begin
      if (aTablero[i,j]= 'o') then
      begin
         aTurno := 0;
         pone_ficha_BB(i,j,true);
         actualizarMuertos(i,j);
         inc(aFichasTotales);
      end
      else if (aTablero[i,j]= 'x') then
           begin
              aTurno:= 1;
              pone_ficha_BB(i,j,true);
              actualizarMuertos(i,j);
              inc(aFichasTotales);
           end;
    end;
  self.setTurno(inherited Turno);  
end;



function TColosus2.estaPegado(i, j: Tsi): Boolean;
var
   c: TcoordBB;
   m: integer;
   aux: Tui;
begin
   Result:= false;
   c:= aTablero2BB[i,j];
   for m:=0 to 3 do
   begin
      if (c[m].i <> -1) then
      begin
         aux:= Tui($00070000 shr (17 - c[m].j));
         if (((aBBFichas[0,c[m].i] or aBBFichas[1,c[m].i]) and aux) <> 0) then
         begin
            Result:= true;
            exit;
         end;
      end;
   end;
end;



function TColosus2.esLegal(const i, j: Tsi): Boolean;
var
   c: TcoordBB;
   m: integer;
   aux: Tui;
begin
   if aVacio then Result:= true
   else begin
      Result:= false;
      if (((aBBFichas[0,i] or aBBFichas[1,i]) and (1 shl j)) = 0) then
      begin
         c:= aTablero2BB[i,j];
         for m:=0 to 3 do
         begin
            if (c[m].i <> -1) then
            begin
               if (aFichasTotales <= aFinPegado) and (aTurno = 1) and (aYo=1) and (aPegado = 1) then
                  aux:= Tui($00070000 shr (17 - c[m].j))
               else
                  aux:= Tui($001F0000 shr (18 - c[m].j));
               if (((aBBFichas[0,c[m].i] or aBBFichas[1,c[m].i]) and aux) <> 0) then
               begin
                  Result:= true;
                  exit;
               end;
            end;
         end
      end;
   end;
end;


function TColosus2.esLegal4(const i, j: Tsi): Boolean;
var
   c: TcoordBB;
   m: integer;
   aux: Tui;
begin
   if aVacio then Result:= true
   else begin
      Result:= false;
      if (((aBBFichas[0,i] or aBBFichas[1,i]) and (1 shl j)) = 0) then
      begin
         c:= aTablero2BB[i,j];
         for m:=0 to 3 do
         begin
            if (c[m].i <> -1) and ((aCantFichas[0,c[m].i] > 2) or (aCantFichas[1,c[m].i] > 2))  then
            begin
               if (aFichasTotales <= aFinPegado) and (aTurno = 1) and (aYo=1) and (aPegado = 1) then
                  aux:= Tui($00070000 shr (17 - c[m].j))
               else
                  aux:= Tui($001F0000 shr (18 - c[m].j));
               if (((aBBFichas[0,c[m].i] or aBBFichas[1,c[m].i]) and aux) <> 0) then
               begin
                  Result:= true;
                  exit;
               end;
            end;
         end
      end;
   end;
end;


function TColosus2.esLegal3(const i, j: Tsi): Boolean;
var
   c: TcoordBB;
   m: integer;
   aux: Tui;
begin
   if aVacio then Result:= true
   else begin
      Result:= false;
      if (((aBBFichas[0,i] or aBBFichas[1,i]) and (1 shl j)) = 0) then
      begin
         c:= aTablero2BB[i,j];
         for m:=0 to 3 do
         begin
            if (c[m].i <> -1) and ((aCantFichas[0,c[m].i] > 1) or (aCantFichas[1,c[m].i] > 1))  then
            begin
               if (aFichasTotales <= aFinPegado) and (aTurno = 1) and (aYo=1) and (aPegado = 1) then
                  aux:= Tui($00070000 shr (17 - c[m].j))
               else
                  aux:= Tui($001F0000 shr (18 - c[m].j));
               if (((aBBFichas[0,c[m].i] or aBBFichas[1,c[m].i]) and aux) <> 0) then
               begin
                  Result:= true;
                  exit;
               end;
            end;
         end
      end;
   end;
end;


procedure TColosus2.pone_ficha_BB(i,j: Tsi; poner: Boolean);
var
  aux: Tui;
  aux2: Tsi;
  c: TCoordBB;
  m, auxi: integer;
  turnoaux: Tsi;
  p,p2: ^Integer;
  phl: ^Int64;
begin
     inc(oPone);
     if poner then
     begin
        turnoaux := aTurno;
        aux2 := 1;
     end else
     begin
        turnoaux:= aTurno xor 1;
        aux2:= -1;
     end;
     c := aTablero2BB[i,j];
     for m:=0 to 3 do
     begin
        auxi:= c[m].i;
        p:= @aCantFichas[turnoaux,auxi];
        p2:= @aBBfichas[turnoaux,auxi];
        if (auxi <> -1) then
        begin
           aux:= 1 shl c[m].j;
           if ((aBBmuertos[turnoaux,auxi] and aux) = 0) then
              p^:= p^ + aux2;
           p2^:= p2^ xor aux;
           aHashTable.getHashL(aHashLineas[auxi],turnoaux,c[m].j);
        end;
     end;
     aHashTable.getHash(aHash,turnoaux,i,j);
     aTurno:= aTurno xor 1;
     aVacio:= false;
end;

procedure TColosus2.pone_ficha_BB_sinhash(i,j: Tsi; poner: Boolean);
var
  aux: Tui;
  aux2: Tsi;
  c: TCoordBB;
  m, auxi: integer;
  turnoaux: Tsi;
  p,p2: ^Integer;
  phl: ^Int64;
begin
     inc(oPone);
     if poner then
     begin
        turnoaux := aTurno;
        aux2 := 1;
     end else
     begin
        turnoaux:= aTurno xor 1;
        aux2:= -1;
     end;
     c := aTablero2BB[i,j];
     for m:=0 to 3 do
     begin
        auxi:= c[m].i;
        p:= @aCantFichas[turnoaux,auxi];
        p2:= @aBBfichas[turnoaux,auxi];
        if (auxi <> -1) then
        begin
           aux:= 1 shl c[m].j;
           if ((aBBmuertos[turnoaux,auxi] and aux) = 0) then
              p^:= p^ + aux2;
           p2^:= p2^ xor aux;
           //aHashTable.getHashL(aHashLineas[auxi],turnoaux,c[m].j);
        end;
     end;
     aTurno:= aTurno xor 1;
     aVacio:= false;
end;



function TColosus2.puntPosicion(const i, j: Tsi): Integer;
begin
 // Result:= - Abs(i-7) - Abs(j-7);
  Result:= - Abs(i-aJAnterior.i) - Abs(j-aJAnterior.j);
end;



procedure TColosus2.legales(var lj: TJugadasR; prof: shortint; var h3gral: Boolean);
var
  i, j, punt: integer;
  depth: shortint;
  habia3, hay4, restar: Boolean;
begin
   h3gral:= false;
   hay4:= false;
   restar:= false;
   if (prof = 1) then inc(oLegalesp1) else inc (oLegalespn);
   for i:=0 to 14 do
      for j:=0 to 14 do
         if esLegal(i,j) then
         begin
            punt:= evaluarDif(i,j,habia3, hay4);
            if habia3 then h3gral:= true;
           { if (prof = aProfAct) and (i = aBestAnt.i) and (j = aBestAnt.j) then
            begin
               punt := punt + 1000000;
               restar:= true;
            end;}
            if aesPV and (prof > 1) and (i = aPV[aProfact - prof].i) and (j = aPV[aProfact - prof].j) then
            begin
               punt := punt + 1000000;
               restar:= true;
            end;
            lj.Add(i,j,punt, hay4);
         end;
   lj.ordenar;
   if restar then lj.setp(0,lj.getp(0) - 1000000);

end;

procedure TColosus2.legales4(var lj: TJugadasR);
var
  i, j, punt: integer;
  habia3, hay4: Boolean;
begin
   for i:=0 to 14 do
      for j:=0 to 14 do
         if esLegal4(i,j) then
         begin
            punt:= evaluarDif(i,j,habia3,hay4);
            if (punt > 3000) or hay4 then
               lj.add(i,j,punt,hay4);
         end;
   lj.ordenar;

end;






function TColosus2.evaluarNull: integer;
var
   m, n, l, k, i, j, cant, puntlinea:integer;
   aux, linea: Tui;
   danger: integer;
   cant4o, cant3o, cant3x, cant4x: Integer;
   ppatron: TPPatron;
begin
    inc(oEvaluadosNull);
    Result:= 0;
    cant3o:= 0;
    Cant4o:= 0;
    Cant3x:= 0;
    cant4x:= 0;

    for i:=0 to 71 do
    begin
       if not(aHashTable.getLinea(aHashLineas[i],aTurno,puntlinea,danger)) then
       begin
          puntlinea := 0;
          danger:= 0;
          for m:=0 to 1 do
          begin
             k:= (m xor aTurno) xor 1;
             aux:= aBBFichas[k xor 1,i] or aBBfuera[i];
             cant:= aCantFichas[k,i];
             linea:= aBBfichas[k,i];
             n:= 0;
             while (cant > 0) and (n < 5) do
             begin
                if (cant > (4 - n)) then
                begin
                   for l:=0 to (length(aPatrones[0,n]) - 1) do
                   begin
                      ppatron:= @aPatrones[m,n,l];
                      for j:=0 to 10 do
                      begin
                         if ((((linea and (ppatron^.mask shl j)) xor (ppatron^.patron shl j))
                              or ((ppatron^.mask shl j) and aux)) = 0) then
                         begin
                            puntlinea:= puntlinea + ppatron^.puntaje;
                            cant:= cant - (5 - n);
                            linea:= linea xor (ppatron^.patron shl j);
                            if (n=1) and (k=0) then danger:= danger or 1;
                            if (n=2) and (l < 4) and (k=0)then danger:= danger or 4;
                            if (n=1) and (k=1) then danger:= danger or 2;
                            if (n=2) and (l < 4) and (k=1)then danger:= danger or 8;
                            break;
                         end;
                      end;
                      if (cant < (5-n)) then break;
                   end;
                end;
                inc(n);
             end; // while
          end;  //for m:=0 to 1 do
          aHashTable.guardarLinea(aHashLineas[i],aTurno,puntlinea,danger);
       end;  //if aHashTable
       Result:= Result + puntlinea;
       cant4o:= cant4o + (danger and 1);
       cant4x:= cant4x + (danger and 2);
       cant3o:= cant3o + (danger and 4);
       cant3x:= cant3x + (danger and 8);
    end;  // for i
    if (aTurno=1) then
    begin
       if (cant4o > 1) then Result:= Result + aDos4;
       if (cant4o > 0) and (cant3o>0) then Result:= Result + a4y3;
       if (cant4o > 0) and (cant3x>0) then Result:= Result + a4y3adv*(cant3x shr 3);
       if (cant3o > 4) then Result:= Result + aDos3;
    end else
    begin
       if (cant4x > 2) then Result:= Result + aDos4;
       if (cant4x > 0) and (cant3x>0) then Result:= Result + a4y3;
       if (cant4x > 0) and (cant3o>0) then Result:= Result + a4y3adv*(cant3o shr 2);
       if (cant3x > 8) then Result:= Result + aDos3;
    end;

    Result:= Result + Random(aRandom + 1);       //-------------------
end;





function TColosus2.evaluarDif(const i, j: Tsi; var habia3, hay4: Boolean): integer;
var
   m, n, t, l, k, ci, auxi, auxj, signo, cant, puntlinea, turnoaux:integer;
   aux, linea: Tui;
   c: TCoordBB;
   danger: integer;
   ppatron: TPPatron;
   hay3: Boolean;
   hashl: Int64;
begin
    inc(oEvaluados);
    Result:= 0;
    c:= atablero2BB[i,j];
    habia3:= false;
    hay4:= false;
    hay3:= false;
    for t:=0 to 1 do
    begin
       if (t=0) then signo:= -1 else signo:= 1;
       turnoaux:= aTurno xor (1 xor t);
       for ci:=0 to 3 do
       begin
          if (c[ci].i <> -1) then
          begin
             auxi:= c[ci].i;
             if t=0 then
               hashl:= aHashLineas[auxi]
             else
               hashl:= aHashTable.getHashL2(aHashLineas[auxi],aTurno xor 1,c[ci].j);
             if not(aHashTable.getLinea(hashl,turnoaux,puntlinea,danger)) then
             begin
                puntlinea := 0;
                danger:= 0;
                for m:=0 to 1 do
                begin
                   k:= (m xor turnoaux) xor 1;
                   aux:= aBBFichas[k xor 1,auxi] or aBBfuera[auxi];
                   cant:= aCantFichas[k,auxi];
                   linea:= aBBfichas[k,auxi];
                   n:= 0;
                   while (cant > 0) and (n < 5) do
                   begin
                      if (cant > (4 - n)) then
                      begin
                         for l:=0 to (length(aPatrones[0,n]) - 1) do
                         begin
                            ppatron:= @aPatrones[m,n,l];
                            for auxj:=0 to 10 do
                            begin
                               if ((((linea and (ppatron^.mask shl auxj)) xor (ppatron^.patron shl auxj))
                                    or ((ppatron^.mask shl auxj) and aux)) = 0) then
                               begin
                                  puntlinea:= puntlinea + ppatron^.puntaje;
                                  cant:= cant - (5 - n);
                                  linea:= linea xor (ppatron^.patron shl j);
                                  if (n=1) and (k=0) then danger:= danger or 1;
                                  if (n=2) and (l < 4) and (k=0)then danger:= danger or 4;
                                  if (n=1) and (k=1) then danger:= danger or 2;
                                  if (n=2) and (l < 4) and (k=1)then danger:= danger or 8;
                                  break;
                               end;
                            end;
                            if (cant < (5-n)) then break;
                         end;
                      end;
                      inc(n);
                   end; //while
                end; //for m:= 0
                aHashTable.guardarLinea(hashl,turnoaux,puntlinea,danger);
             end;  // if not(aHashTable
             Result:= Result + signo*puntlinea;
             if ((danger and 1)<>0) and (t=1) and (aTurno=1) then
             begin
                 Result:= Result + a4dif;
                 hay4:= true;
             end;
             if ((danger and 2)<>0) and (t=1) and (aTurno=0) then
             begin
                 Result:= Result + a4dif;
                 hay4:= true;
             end;
             {if ((danger and 4)<>0) and (t=1) and (aTurno=1) then
                     hay3:=true;
             if ((danger and 8)<>0) and (t=1) and (aTurno=0) then
                     hay3:=true;
             }

             if ((danger and 4)<>0) and (t=0) and (aTurno=1) then
                habia3:= true;
             if ((danger and 8)<>0) and (t=0) and (aTurno=0) then
                habia3:= true;
          end; // if (c[ci].i
       end; // for ci:=0
       pone_ficha_BB_sinhash(i,j,(t=0));
    end; //for t:= 0
    //if hay4 and hay3 then Result:= Result + a4y3;
end;



function TColosus2.evaluarDif43(const i, j: Tsi; var hay4, tapa3, hay3: Boolean): integer;
var
   m, n, t, l, k, ci, auxi, auxj, signo, cant, puntlinea, turnoaux:integer;
   aux, linea: Tui;
   c: TCoordBB;
   danger: integer;
   ppatron: TPPatron;
   hay3adv: Boolean;
   hashl: Int64;
begin
    inc(oEvaluados);
    Result:= 0;
    c:= atablero2BB[i,j];
    tapa3:= false;
    hay3:= false;
    hay4:= false;
    hay3adv:= false;
    for t:=0 to 1 do
    begin
       if (t=0) then signo:= -1 else signo:= 1;
       turnoaux:= aTurno xor (1 xor t);
       for ci:=0 to 3 do
       begin
          if (c[ci].i <> -1) then
          begin
             auxi:= c[ci].i;
             if t=0 then
               hashl:= aHashLineas[auxi]
             else
               hashl:= aHashTable.getHashL2(aHashLineas[auxi],aTurno xor 1,c[ci].j);
             if not(aHashTable.getLinea(hashl,turnoaux,puntlinea,danger)) then
             begin
                puntlinea := 0;
                danger:= 0;
                for m:=0 to 1 do
                begin
                   k:= (m xor turnoaux) xor 1;
                   aux:= aBBFichas[k xor 1,auxi] or aBBfuera[auxi];
                   cant:= aCantFichas[k,auxi];
                   linea:= aBBfichas[k,auxi];
                   n:= 0;
                   while (cant > 0) and (n < 5) do
                   begin
                      if (cant > (4 - n)) then
                      begin
                         for l:=0 to (length(aPatrones[0,n]) - 1) do
                         begin
                            ppatron:= @aPatrones[m,n,l];
                            for auxj:=0 to 10 do
                            begin
                               if ((((linea and (ppatron^.mask shl auxj)) xor (ppatron^.patron shl auxj))
                                    or ((ppatron^.mask shl auxj) and aux)) = 0) then
                               begin
                                  puntlinea:= puntlinea + ppatron^.puntaje;
                                  cant:= cant - (5 - n);
                                  linea:= linea xor (ppatron^.patron shl j);
                                  if (n=1) and (k=0) then danger:= danger or 1;
                                  if (n=2) and (l < 4) and (k=0)then danger:= danger or 4;
                                  if (n=1) and (k=1) then danger:= danger or 2;
                                  if (n=2) and (l < 4) and (k=1)then danger:= danger or 8;
                                  break;
                               end;
                            end;
                            if (cant < (5-n)) then break;
                         end;
                      end;
                      inc(n);
                   end; //while
                end; //for m:= 0
                aHashTable.guardarLinea(hashl,turnoaux,puntlinea,danger);
             end;  // if not(aHashTable
             Result:= Result + signo*puntlinea;
             if ((danger and 1)<>0) and (t=1) and (aTurno=1) then
             begin
                 hay4:= true;
             end;
             if ((danger and 2)<>0) and (t=1) and (aTurno=0) then
             begin
                 hay4:= true;
             end;
             if ((danger and 4)<>0) and (t=1) then
             begin
                 if (aTurno=1) then
                    hay3:= true
                 else
                    hay3adv:= true;
             end;
             if ((danger and 8)<>0) and (t=1) then
             begin
                 if (aTurno=0) then
                    hay3:= true
                 else
                    hay3adv:= true;
             end;
             if ((danger and 4)<>0) and (t=0) and (aTurno=1) then
                tapa3:= true;
             if ((danger and 8)<>0) and (t=0) and (aTurno=0) then
                tapa3:= true;
          end; // if (c[ci].i
       end; // for ci:=0
       pone_ficha_BB_sinhash(i,j,(t=0));
    end; //for t:= 0
    if hay3adv or (Result > 10000) then
    begin
       tapa3:= false;
       hay3:= false;
    end;
end;


function TColosus2.alphabeta( const prof: shortint; alpha: integer; const  beta: integer; const i, j: integer): TJugada;
var
  m: integer;
  lj: TJugadasR;
  best, jugada: TJugada;
  auxi, auxj: integer;
  ultima, punt, puntaux, tipohash: Integer;
  profhash: shortint;
  h3gral, estaenhash: Boolean;
  pmax: Integer;
  terminar: boolean;
begin
    if (prof = 0) then
    begin
         if (aQuies3=0) then
            Result:= quies(alpha,beta,i,j,0)
         else
            Result:= quies43(alpha,beta,i,j,0);
    end
    else
    begin
       inc(oAlphaBetas); //---
       lj:= TJugadasR.Create;
       legales(lj,prof, h3gral);
       if (lj.count = 0) then
       begin
          Result:= TJugada.Create(-1,-1,0);
          exit;
       end;
       oLegales:= oLegales + lj.Count;
       pmax:= lj.getp(0);
       if (pmax > 600000) then
       begin
          Result:= TJugada.Create(lj.geti(0),lj.getj(0),lj.getp(0));
          lj.Free;
          exit;
       end;
       best:= TJugada.Create(-1,-1,-10000000);
       m:= 0;
       auxi:= -1;
       auxj:= -1;
       while ((m<lj.Count) and (best.p < beta)) do
       begin
          if ( (prof <> 1) and (prof <> aProfact) and  (lj.getp(m) < (pmax - 100)) and (lj.getp(m) < 30)) then break;
          if (not(h3gral) or (lj.getp(m) > 600) or (lj.geth4(m))) then
          begin

             inc(oNodos);    //---
             auxi:= lj.geti(m);
             auxj:= lj.getj(m);

             if (best.p > alpha) then alpha := best.p;

             estaenhash:= aHashtable.getPosicion(aHash,aTurno,auxi,auxj,punt, profhash,tipohash);
             if not(estaenhash) or (prof > profhash) or ((tipohash=1)and(punt<beta)) or ((tipohash=2)and(punt>alpha)) then
             begin
                pone_ficha_BB(auxi,auxj,true);
                if not(aesPV) and (aSel=1) and (aProfact > 3) and (prof > 1) and (prof<4) then
                begin
                   puntaux:= evaluarnull;
                   if ((puntaux < (alpha -aSelBanda)) or (puntaux > (beta +aSelBanda))) and (abs(puntaux)<3000) then
                       jugada:= TJugada.Create(-1,-1,-puntaux)
                   else
                      jugada:= alphabeta(prof-1, -beta, -alpha,auxi,auxj);
                end else
                   jugada:= alphabeta(prof-1, -beta, -alpha,auxi,auxj);
                punt := -jugada.p;
                {if not(aesPV) and (aProfact > 3) and (prof = 2) then
                begin
                   inc(oSeltotal);
                   puntaux:= evaluarnull;
                   if ((puntaux < (alpha -150)) or (puntaux > (beta +150))) and (abs(puntaux)<3000) then
                      if (punt > alpha) and (punt < beta) then
                         inc(oSelmal)
                      else
                         inc(oSelBien);
                end; }


                terminar:=  aTerminarGuess or ((prof > 1) and aCortarPorTiempo and (telapsed > 3*aTpromactual));
                if  (punt > alpha) and (punt < beta) and not(terminar) then
                begin
                    if (punt > 3000) and (punt < 600000) then punt:= 3100 - jugada.prof;
                    if (punt < -3000) and (punt > -600000) then punt:= -3100 + jugada.prof;
                    aHashTable.guardarPosicion(aHash,punt,prof,0);
                end;    
                if (punt <= alpha) and not(terminar) then
                    aHashTable.guardarPosicion(aHash,punt,prof,2);
                if (punt >= beta) and not(terminar) then
                    aHashTable.guardarPosicion(aHash,punt,prof,1);
                pone_ficha_BB(auxi,auxj,false);
             end else
             begin
                jugada:= TJugada.Create(-1,-1,punt);
                terminar:=  aTerminarGuess or ((prof > 1) and aCortarPorTiempo and (telapsed > 3*aTpromactual));
             end;
             if terminar then
             begin
                if (best.i = -1) then
                begin
                   best.prox:= jugada.copiar;
                   best.p:= punt;
                   best.i := auxi;
                   best.j := auxj;
                   if (prof=aProfAct) then
                      aCortoPrimera:= true;
                end;
                Result:= best;
                lj.Free;
                jugada.Free;
                exit;
             end;

             if (punt > best.p) then
             begin
                best.prox.free;
                best.prox:= jugada.copiar;
                best.p := punt;
                best.i := auxi;
                best.j := auxj;
             end;
             jugada.Free;
             if (lj.getp(m) > 3000) then m:= 1000;
             if ((best.p > 600000) and (aProfAct = 1)) or ((best.p > 3000) and (aProfAct <> 1)) then m:=1000;  //para terminar
          end;
          inc(m);
          aesPV:= false;
       end; // while
       lj.Free;
       if (best.p > beta) then
       begin
          inc(oCutOffs);
       end;
       Result:= best;
    end;
end;


function TColosus2.alphabeta2( const prof: shortint; alpha: integer; const  beta: integer; const i, j: integer): TJugada;
var
  m: integer;
  lj: TJugadasR;
  best, jugada: TJugada;
  auxi, auxj: integer;
  ultima, punt, tipohash: Integer;
  profhash: shortint;
  h3gral, estaenhash: Boolean;
  pmax: Integer;
  terminar: boolean;
begin
    if (prof = 0) then
    begin
         if (aQuies3=0) then
            Result:= quies(alpha,beta,i,j,0)
         else
            Result:= quies43(alpha,beta,i,j,0);
    end
    else
    begin
       inc(oAlphaBetas); //---
       lj:= TJugadasR.Create;
       legales(lj,prof, h3gral);
       if (lj.count = 0) then
       begin
          Result:= TJugada.Create(-1,-1,0);
          exit;
       end;
       oLegales:= oLegales + lj.Count;
       pmax:= lj.getp(0);
       if (pmax > 600000) then
       begin
          Result:= TJugada.Create(lj.geti(0),lj.getj(0),lj.getp(0));
          lj.Free;
          exit;
       end;
       best:= TJugada.Create(-1,-1,-10000000);
       m:= 0;
       auxi:= -1;
       auxj:= -1;
       while ((m<lj.Count) and (best.p < beta)) do
       begin
          if ( (prof <> 1) and (prof <> aProfact) and  (lj.getp(m) < (pmax - 100)) and (lj.getp(m) < 30)) then break;
          if (not(h3gral) or (lj.getp(m) > 600) or (lj.geth4(m))) then
          begin

             inc(oNodos);    //---
             auxi:= lj.geti(m);
             auxj:= lj.getj(m);

             if (best.p > alpha) then alpha := best.p;

             estaenhash:= aHashtable.getPosicion(aHash,aTurno,auxi,auxj,punt, profhash,tipohash);
             if not(estaenhash) or (prof > profhash) or ((tipohash=1)and(punt<beta)) or ((tipohash=2)and(punt>alpha)) then
             begin
                pone_ficha_BB(auxi,auxj,true);
                if aesPV then
                begin
                   jugada:= alphabeta(prof-1, -beta, -alpha,auxi,auxj);
                   punt := -jugada.p;
                end else
                begin
                   jugada:= alphabeta(prof-1, -alpha-1, -alpha,auxi,auxj);
                   punt := -jugada.p;
                   if (punt > alpha) and (punt < beta) then
                   begin
                      jugada.Free;
                      jugada:= alphabeta(prof-1, -beta, -alpha,auxi,auxj);
                      punt := -jugada.p;
                   end;
                end;
                terminar:=  (prof > 2) and (telapsed > 3*aTpromactual);
                if  (punt > alpha) and (punt < beta) and not(terminar) then
                begin
                    if (punt > 3000) and (punt < 600000) then punt:= 3100 - jugada.prof;
                    if (punt < -3000) and (punt > -600000) then punt:= -3100 + jugada.prof;
                    aHashTable.guardarPosicion(aHash,punt,prof,0);
                end;    
                if (punt <= alpha) and not(terminar) then
                    aHashTable.guardarPosicion(aHash,punt,prof,2);
                if (punt >= beta) and not(terminar) then
                    aHashTable.guardarPosicion(aHash,punt,prof,1);
                pone_ficha_BB(auxi,auxj,false);
             end else
             begin
                jugada:= TJugada.Create(-1,-1,punt);
                terminar:=  (prof <> 1) and (telapsed > 3*aTpromactual);
             end;
             if terminar then
             begin
                if (best.i = -1) then
                begin
                   best.prox:= jugada.copiar;
                   best.p:= punt;
                   best.i := auxi;
                   best.j := auxj;
                   if (prof=aProfAct) then
                      aCortoPrimera:= true;
                end;
                Result:= best;
                lj.Free;
                jugada.Free;
                exit;
             end;

             if ((punt > best.p) {and (punt > -3000) and (best.p < 3000)) or
                  ((best.p < -3000) and (punt < -3000) and (jugada.prof >= best.prof)) or
                  ((best.p > 3000) and (punt > 3000) and (jugada.prof < (best.prof - 1))}) then
             begin
                best.prox.free;
                best.prox:= jugada.copiar;
                best.p := punt;
                best.i := auxi;
                best.j := auxj;
             end;
             jugada.Free;
             if (lj.getp(m) > 3000) then m:= 1000;
             if ((best.p > 600000) and (aProfAct = 1)) or ((best.p > 3000) and (aProfAct <> 1)) then m:=1000;  //para terminar
          end;
          inc(m);
          aesPV:= false;
       end; // while
       lj.Free;
       if (best.p > beta) then
       begin
          inc(oCutOffs);
       end;
       Result:= best;
    end;
end;


function TColosus2.quies(alpha: integer; const beta: integer; const i, j: integer; const prof: shortint): TJugada;
var
 lj: TjugadasR;
 best, jugada: Tjugada;
 m, auxi, auxj, punt, ultima, tipohash: integer;
 aux: shortint;
 estaenhash: Boolean;
 auxb: Boolean;
 pmax: Integer;
begin
   oPmax:= min(oPmax,prof);
   best:= Tjugada.Create(-1,-1,-evaluarNull);
   if (best.p < -3000) then
   begin
       Result:= best;
       exit;
   end;
   lj:= TJugadasR.Create;
   legales4(lj);

   if (lj.count = 0) then
   begin
      if (aParImpar<>0) and ((prof and 1)<>0) then
      begin
         legales(lj,0,auxb);
         auxi:= lj.geti(0);
         auxj:= lj.getj(0);
         pone_ficha_BB(auxi,auxj,true);
         best.p:= evaluarNull;
         best.i:= auxi;
         best.j:= auxj;
         pone_ficha_BB(auxi,auxj,false);
      end;
      Result:= best;
      lj.Free;
      exit;
   end;

   pmax:= lj.getp(0);
   if (pmax > 600000)then
   begin
      Result:= best;
      Result.p:= pmax;
      lj.Free;
      exit;
   end;

   if (pmax > 10000) and (best.p < (alpha - aPatrones[0,1,1].puntaje)) then   //jugada demasado buena que sigue mejorando
   begin
      Result:= best;
      lj.Free;
      exit;
   end;
   if (pmax < 10000) and (best.p > beta) then  //jugada mala que sigue empeorando
   begin
      Result:= best;
      lj.Free;
      exit;
   end;

   m:= 0;
   best.p:= -10000000;
   if (prof > -2) then
      ultima:= min(aNCorteQuiesIni, lj.Count)
   else
      ultima:= min(aNCorteQuiesFin, lj.Count);
   while (m < ultima) and (best.p < beta) do
   begin
     inc(oNodosQ);    //---
     auxi:= lj.geti(m);
     auxj:= lj.getj(m);
     if (lj.getp(m) > 3000) then m:= 1000;
     if (best.p > alpha) then alpha := best.p;
    estaenhash:= aHashtable.getPosicion(aHash,aTurno,auxi,auxj,punt, aux, tipohash);
    if not(estaenhash) or ((tipohash=1)and(punt<beta)) or ((tipohash=2)and(punt>alpha)) then
    begin
     pone_ficha_BB(auxi,auxj,true);
     jugada:= quies(-beta, -alpha, auxi,auxj,prof-1);
     punt := -jugada.p;
     if  (punt > alpha) and (punt < beta) then
         aHashTable.guardarPosicion(aHash,punt,0,0);
     if (punt <= alpha) then
         aHashTable.guardarPosicion(aHash,alpha,0,2);
     if (punt >= beta) then
         aHashTable.guardarPosicion(aHash,beta,0,1);
     pone_ficha_BB(auxi,auxj,false);

     end else
        jugada:= TJugada.Create(-1,-1,punt);
     if (punt > best.p) then
     begin
        best.prox.free;
        best.prox:= jugada.copiar;
        best.p := punt;
        best.i := auxi;
        best.j := auxj;
     end;
     jugada.Free;

     if (punt > 3000) then m:=1000;  //para terminar
   inc(m);
   end;
   lj.Free;
   Result:= best;
end;


procedure TColosus2.legales43(var lj: TJugadasR; var tapa4, hay4, tapa3, hay3: Boolean; const prof: shortint);
var
  i, j, punt: integer;
  tapa4aux, hay4aux, tapa3aux, hay3aux: Boolean;
  lj3, lj4: TJugadasR;
begin
   tapa4:= false;
   hay4:= false;
   tapa3:= false;
   hay3:= false;

   if (prof > (-aProfAct - 1 - aQ3prof)) then
   begin
      lj3:= TJugadasR.Create;
      lj4:= TJugadasR.Create;
      for i:=0 to 14 do
         for j:=0 to 14 do
            if esLegal3(i,j) then
            begin
               punt:= evaluarDif43(i,j,hay4aux,tapa3aux,hay3aux);
               if punt > 600000 then
               begin
                  lj.add(i,j,punt,false);
                  lj.ordenar;
                  lj.Count:= 1;
                  lj3.Free;
                  lj4.Free;
                  exit;
               end;
               if punt > 10000 then tapa4:= true;

               if hay4aux or (punt > 10000) then
                  lj4.add(i,j,punt,true)
               else
                  if tapa3aux or hay3aux then
                    lj3.add(i,j,punt,hay4aux);
            end;
      if lj4.Count <> 0 then
      begin
         lj4.ordenar;
         if lj4.getp(0) > 10000 then
         begin
            lj4.Count:= 1;

            lj3.Free;
            lj.Free;
            lj:= lj4;
            tapa4:= true;
            exit;
         end else
            hay4:= true;
         lj4.Count:= min(aNCorteQuiesIni, lj4.Count);
      end;

      if (lj3.count <> 0) then
      begin
         lj3.ordenar;
         if (lj3.getp(0) > 500) then tapa3:= true else hay3:= true;
         lj3.Count:= min(aNCorteQuiesIni, lj3.Count);
         if  not((prof < (-aProfAct - aQ3prof)) and (lj3.getp(0) > 500)) then //hay 3 para seguir
         begin
           if (lj4.Count = 0) then
           begin
              lj4.Free;
              lj.Free;
              lj:= lj3;
           end else
           begin
              for i:=0 to (lj4.Count - 1) do
                 lj.add(lj4.geti(i),lj4.getj(i),lj4.getp(i),lj4.geth4(i));
              if (lj4.getp(0) < 3000) then
                 for i:=0 to (lj3.Count - 1) do
                    lj.add(lj3.geti(i),lj3.getj(i),lj3.getp(i),false);
              lj4.Free;
              lj3.Free;
           end;
         end;
      end else
      begin
        lj.Free;
        lj:= lj4;
        lj3.Free;
      end;
   end else
   begin
      legales4(lj);
      if lj.Count <> 0 then
      begin
         punt:= lj.getp(0);
         if (punt > 10000) and (punt < 600000) then
         begin
           tapa4:= true;
           lj.Count:= 1;
         end;
         if (punt < 10000) then
         begin
           hay4:= true;
           lj.Count:= min(aNCorteQuiesIni, lj.Count);
         end;
      end;
   end;
end;

procedure TColosus2.legales432(var lj: TJugadasR; var tapa4, hay4, tapa3, hay3: Boolean; const prof: shortint);
var
  i, j, punt: integer;
  tapa4aux, hay4aux, tapa3aux, hay3aux: Boolean;
  lj3, lj4, lj2: TJugadasR;
begin
   tapa4:= false;
   hay4:= false;
   tapa3:= false;
   hay3:= false;

   if (prof > (-aProfAct - 1 - aQ3prof)) then
   begin
      lj3:= TJugadasR.Create;
      lj4:= TJugadasR.Create;
      lj2:= TJugadasR.Create;
      for i:=0 to 14 do
         for j:=0 to 14 do
            if esLegal(i,j) then
            begin
               punt:= evaluarDif43(i,j,hay4aux,tapa3aux,hay3aux);
               if punt > 600000 then
               begin
                  lj.add(i,j,punt,false);
                  lj.ordenar;
                  lj.Count:= 1;
                  lj3.Free;
                  lj2.Free;
                  lj4.Free;
                  exit;
               end;
               if punt > 10000 then tapa4:= true;

               if hay4aux or (punt > 10000) then
                  lj4.add(i,j,punt,true)
               else
                  if tapa3aux or hay3aux then
                    lj3.add(i,j,punt,hay4aux)
                  else
                    lj2.add(i,j,punt,false);
            end;
      if lj4.Count <> 0 then
      begin
         lj4.ordenar;
         if lj4.getp(0) > 10000 then
         begin
            lj4.Count:= 1;

            lj3.Free;
            lj2.Free;
            lj.Free;
            lj:= lj4;
            tapa4:= true;
            exit;
         end else
            hay4:= true;
         lj4.Count:= min(aNCorteQuiesIni, lj4.Count);
      end;

      if (lj3.count <> 0) then
      begin
         lj3.ordenar;
         if (lj3.getp(0) > 500) then tapa3:= true else hay3:= true;
         if (aTipoSel <> 0) or tapa3 then
             lj3.Count:= min(aNCorteQuiesIni, lj3.Count)
         else
             lj3.Count:= min(2*aNCorteQuiesIni, lj3.Count);
         if  not((prof < (-aProfAct - aQ3prof)) and (lj3.getp(0) > 500)) then //hay 3 para seguir
         begin
           if (lj4.Count = 0) then
           begin
              lj4.Free;
              lj.Free;
              lj:= lj3;
           end else
           begin
              for i:=0 to (lj4.Count - 1) do
                 lj.add(lj4.geti(i),lj4.getj(i),lj4.getp(i),lj4.geth4(i));
              if (lj4.getp(0) < 3000) then
                 for i:=0 to (lj3.Count - 1) do
                    lj.add(lj3.geti(i),lj3.getj(i),lj3.getp(i),false);
              lj4.Free;
              lj3.Free;
           end;
         end;
      end else
      begin
        lj.Free;
        lj:= lj4;
        lj3.Free;
      end;
      if aTipoSel = 0 then
      begin
         if (lj2.Count <> 0) and not(tapa3) and not(tapa4) and not(hay3) then
         begin
            lj2.ordenar;
            lj2.Count:= min(aNCorteQuiesIni, lj2.Count);
            for i:=0 to (lj2.Count - 1) do
               lj.add(lj2.geti(i),lj2.getj(i),lj2.getp(i),false);
         end;
      end else
      begin
         if (lj2.Count <> 0) and not(tapa3) and not(tapa4) then
         begin
            lj2.ordenar;
            lj2.Count:= min(aNCorteQuiesIni, lj2.Count);
            for i:=0 to (lj2.Count - 1) do
               lj.add(lj2.geti(i),lj2.getj(i),lj2.getp(i),false);
         end;
      end;
      lj2.Free;
   end else
   begin
      legales4(lj);
      if lj.Count <> 0 then
      begin
         punt:= lj.getp(0);
         if (punt > 10000) and (punt < 600000) then
         begin
           tapa4:= true;
           lj.Count:= 1;
         end;
         if (punt < 10000) then
         begin
           hay4:= true;
           lj.Count:= min(aNCorteQuiesIni, lj.Count);
         end;
      end;
   end;
end;


function TColosus2.quies43(alpha: integer; const beta: integer; const i, j: integer; const prof: shortint): TJugada;
var
 lj, ljaux: TjugadasR;
 best, jugada: Tjugada;
 m, auxi, auxj, punt, ultima, tipohash: integer;
 aux: shortint;
 estaenhash: Boolean;
 auxb: Boolean;
 pmax: Integer;
 umbral: Integer;
 restaalpha: Integer;
 tapa4, tapa3, hay4, hay3: Boolean;
 tapa4_, tapa3_, hay4_, hay3_: Boolean;
begin
   oPmax:= min(oPmax,prof);
   restaalpha:= aPatrones[0,1,1].puntaje;
   best:= Tjugada.Create(-1,-1,-evaluarNull);
   if (best.p < -3000) then
   begin
       Result:= best;
       exit;
   end;

   lj:= TJugadasR.Create;

   if (aSel=0) or (best.p < (alpha - aSelBanda)) or (best.p > (beta + aSelBanda)) then
      legales43(lj,tapa4,hay4,tapa3,hay3,prof)
   else
      legales432(lj,tapa4,hay4,tapa3,hay3,prof);


   if not(tapa4) and not(hay4) then  restaalpha:= 105 - 53;

   if (lj.count = 0) then
   begin
      if (aParImpar<>0) and ((prof and 1)<>0) then
      begin
         legales(lj,0,auxb);
         auxi:= lj.geti(0);
         auxj:= lj.getj(0);
         pone_ficha_BB(auxi,auxj,true);
         best.p:= evaluarNull;
         best.i:= auxi;
         best.j:= auxj;
         pone_ficha_BB(auxi,auxj,false);
      end;
      Result:= best;
      lj.Free;
      exit;
   end;

   pmax:= lj.getp(0);
   if (pmax > 600000)then
   begin
      Result:= best;
      Result.p:= pmax;
      lj.Free;
      exit;
   end;


   if (tapa4 or (tapa3 and not(hay4))) and (best.p < (alpha - restaalpha)) then   //jugada demasado buena que sigue mejorando
   begin
      Result:= best;
      lj.Free;
      exit;
   end;
   if ((hay4 and not(tapa3)) or hay3) and (best.p > beta) then  //jugada mala que sigue empeorando
   begin
      Result:= best;
      lj.Free;
      exit;
   end;

   m:= 0;
   best.p:= -10000000;
   ultima:= lj.Count;
   while (m < ultima) and (best.p < beta) do
   begin
     if hay4 then inc(oNodosQ) else inc(oNodosQ3);
     auxi:= lj.geti(m);
     auxj:= lj.getj(m);
     if (lj.getp(m) > 3000) then m:= 1000;
     if (best.p > alpha) then alpha := best.p;
    estaenhash:= aHashtable.getPosicion(aHash,aTurno,auxi,auxj,punt, aux, tipohash);
    if not(estaenhash) or ((tipohash=1)and(punt<beta)) or ((tipohash=2)and(punt>alpha)) then
    begin
     pone_ficha_BB(auxi,auxj,true);
     jugada:= quies43(-beta, -alpha, auxi,auxj,prof-1);
     punt := -jugada.p;
     if  (punt > alpha) and (punt < beta) then
         aHashTable.guardarPosicion(aHash,punt,0,0);
     if (punt <= alpha) then
         aHashTable.guardarPosicion(aHash,alpha,0,2);
     if (punt >= beta) then
         aHashTable.guardarPosicion(aHash,beta,0,1);
     pone_ficha_BB(auxi,auxj,false);

     end else
        jugada:= TJugada.Create(-1,-1,punt);
     if (punt > best.p) then
     begin
        best.prox.free;
        best.prox:= jugada.copiar;
        best.p := punt;
        best.i := auxi;
        best.j := auxj;
     end;
     jugada.Free;

     if (punt > 3000) then m:=1000;  //para terminar
   inc(m);
   end;
   lj.Free;
   Result:= best;
end;



procedure TColosus2.cargarPV(best: TJugada);
var
   i: Integer;
   j: TJugada;
begin
   if (best = nil) then
     for i:=0 to (length(aPV) - 1) do
     begin
        aPVant[i].i:= -1;
        aPVant[i].j:= -1;
     end
   else  
     for i:=0 to (length(aPV) - 1) do
        aPVant[i]:= aPV[i];
   i:= 0;
   j:= best;
   while (j <> nil) do
   begin
      aPV[i].i:= j.i;
      aPV[i].j:= j.j;
      j:= j.prox;
      inc(i);
   end;
   for i:=i to (length(aPV) - 1) do
   begin
      aPV[i].i:= -1;
      aPV[i].j:= -1;
   end;

end;


function TColosus2.getBest(): TCoordenada;
var
  i, j: integer;
  jugada: TJugada;
  Ahora: TDateTime;
  alpha, beta: integer;
  puntant: Integer;
begin
   inc(aCantMovidas);
   if not(aGuessCorriendo) then
   begin
      aBestAnt.i:= -1;
      aBestAnt.j:= -1;
      aOutput:= '';
      aYo := aTurno;
      puntant:= 0;
      aFechaInicio:= Now;
      aCortoPrimera:= false;
      aTerminarGuess:= false;
      aCortarPorTiempo:= true;
      aesPV:= true;
      cargarPV(nil);
      if not(aVacio) then
      begin
         resetContadores;
         aHashTable.resetContadores;
        if aFichasTotales = 1 then
        begin
           Result:= segunda;
        end else
        begin
            for i:=1 to aProf do
            begin
               aProfact:= i;
               oPmax:= 0;
               jugada := alphabeta(i,-10000000,10000000,-1,-1);
               Result.i := jugada.i;
               Result.j := jugada.j;
               if not(aCortoprimera) then
               begin
                  cargarPV(jugada);
                  oPuntaje:= jugada.p;
                  oBestPath:= jugada.ruta;
                  oPmax:= aProfAct - oPmax;
               end;
               oTiempo:= tElapsed;
               aOutput:= aOutPut + floattostr(oPuntaje/100) +' '+ oBestPath + '  ' +
                         floattostr(oTiempo)+'s  p:' + inttostr(i) + '/' + inttostr(oPmax) +''#13#10;
               UpdateOutput;
               jugada.Free;
               if (abs(oPuntaje) > 3000) and (oTiempo > (aTPromActual/6)) then break;
               if (oTiempo > (aTPromActual/3)) and (oTiempo < (2*aTPromActual/3))
                   and (Result.i = aBestAnt.i) and (Result.j = aBestAnt.j) then break;
               if (oTiempo >= (2*aTPromActual/3)) then break;
               puntant:= oPuntaje;
               aBestAnt:= Result;
            end;
         end;
      end
      else
      begin
         REsult.i:= Random(5) + 5;
         REsult.j:= Random(5) + 5;
      end;
   end else
   begin
      aTiempoGuess:= tElapsed;
      aFechaInicio:= now;
      if (aTiempoGuess > aTPromActual) then
         aTerminarGuess:= true
      else
         aCortarPorTiempo:= true;
      aThreadGuess.WaitFor;
      aThreadGuess.Free;
      oTiempo:= tElapsed;
      Result:= aGuessBest;
      pone_ficha(aGuess.i,aGuess.j);
   end;
   aTAcumulado:= aTAcumulado + aTprom - oTiempo;
   aTPromActual:= max(aTprom + aTAcumulado/5,aTprom/5);
   aTTotalPensar:= aTTotalPensar + oTiempo;
   aTpromPensar:= aTTotalPensar/aCantMovidas;
   self.armarOutput;
   UpdateOutput;
   if (Result.i <> -1) then
     pone_ficha(Result.i,Result.j);

   //if  true or (Result.i <> -1) and not(estapegado(Result.i,Result.j)) and (aTurno = 1) then
     // MessageDlg('fichas: ' + inttostr(aFichasTotales),mtWarning,[mbOk],0);

   if (aPermanentBrain = 1) and (aPV[1].i <> -1) and (abs(oPuntaje) <= 3000) then
   begin
      aThreadGuess:= TThreadMetodo.Crear(guessBest);
   end;
end;



procedure TColosus2.guessBest();
var
  i, j: integer;
  jugada: TJugada;
  Ahora: TDateTime;
  alpha, beta: integer;
  puntant: Integer;
  profini: shortint;
begin
   aGuessCorriendo:= true;
   aBestAnt.i:= -1;
   aBestAnt.j:= -1;
   aOutput:= '';
   puntant:= 0;
   aCortoPrimera:= false;
   aCortarPorTiempo:= false;
   aTerminarGuess:= false;
   aesPV:= true;
   aFechaInicio:= Now;
   aGuess:= aPV[1];
   aOutput:= 'Guess: ('+Inttostr(aGuess.i)+','+Inttostr(aGuess.j)+')'+''#13#10;
   aThreadGuess.sincronizar(UpdateOutput);
   profini:=1;
   for i:=0 to (length(aPV)-3) do
   begin
      aPv[i]:= aPV[i+2];
      if (aPV[i].i <> -1) then inc(profini);
   end;
   aPV[length(aPV)-2].i:= -1;
   aPV[length(aPV)-2].j:= -1;
   aPV[length(aPV)-1].i:= -1;
   aPV[length(aPV)-1].j:= -1;
   resetContadores;
   aHashTable.resetContadores;
   self.pone_ficha_BB(aGuess.i,aGuess.j,true);
   for i:=1 to 1000 do
   begin
      if aTerminarGuess then break;
      aProfact:= i;
      oPmax:= 0;
      jugada := alphabeta(i,-10000000,10000000,-1,-1);
      aGuessBest.i:= jugada.i;
      aGuessBest.j:= jugada.j;
      if not(aCortoprimera) then
      begin
         cargarPV(jugada);
         oPuntaje:= jugada.p;
         oBestPath:= jugada.ruta;
         oPmax:= aProfAct - oPmax;
      end;
      oTiempo:= tElapsed;
      aOutput:= aOutPut + floattostr(oPuntaje/100) +' '+ oBestPath + '  ' +
                floattostr(oTiempo)+'s  p:' + inttostr(i) + '/' + inttostr(oPmax) +''#13#10;
      aThreadGuess.sincronizar(UpdateOutput);
      jugada.Free;
      if (abs(oPuntaje) > 600000) then break;
      if aCortarPorTiempo then
      begin
         if (oTiempo > (aTPromActual/3)) and (oTiempo < (2*aTPromActual/3))
             and (aGuessBest.i = aBestAnt.i) and (aGuessBest.j = aBestAnt.j) then break;
         if (oTiempo >= (2*aTPromActual/3)) then break;
      end;
      puntant:= oPuntaje;
      aBestAnt:= aGuessBest;
   end;
   self.pone_ficha_BB(aGuess.i,aGuess.j,false);
   aGuessCorriendo:= false;
end;


procedure TColosus2.inicializarBB;
var
  n, m, i, j: Tsi;
begin
  for m:=0 to 71 do
  begin
    aHashLineas[m]:= 0;
    aBBfichas[0,m]:= 0;
    aBBfichas[1,m]:= 0;
    aBBmuertos[0,m]:= 0;
    aBBmuertos[1,m]:= 0;
    aCantFichas[0,m]:= 0;
    aCantFichas[1,m]:= 0;
    aBBfuera[m]:= 0;
    aHashLineas[m]:= 0;
    for n:= 5 to 15 do
    begin
       BB2Tablero(m,n,i,j);
       if ((i>14)or(i<0)or(j>14)or(j<0)) then
       begin
          aBBfuera[m]:= $FFFF shl n;
          if (n <> 15) then
             aHashLineas[m]:= aHashTable.getHashLIni(15 - n);
          break;
       end;
    end;
  end;
end;


procedure TColosus2.inicializarTablero2BB;
var
  i, j: integer;
begin
  for i:=0 to 14 do
     for j:=0 to 14 do
        aTablero2BB[i,j]:= Tablero2BB(i,j);
end;

function TColosus2.pone_ficha(i, j: integer): Boolean;
begin
   if aGuessCorriendo then
   begin
      if (aGuess.i <> i) or (aGuess.j <> j) then
      begin
         aTerminarGuess:= true;
         aThreadGuess.WaitFor;
         aThreadGuess.Free;
      end else
      begin
         Result:= true;
         exit;
      end;
   end;
   Result:= inherited pone_ficha(i,j);
   if (Result) then
   begin
      inc(aFichasTotales);
      self.pone_ficha_BB(i,j,true);
      self.actualizarMuertos(i,j);
      aJAnterior.i:= i;
      aJAnterior.j:= j;
   end;
end;


function TColosus2.getParametros: TParametros;
begin
  aProf:= 100;
  aPermanentBrain:= 0;
  aNCorteQuiesIni:= 2;
  aNCorteQuiesFin:= 2;
  aDos4:= 5000;
  a4y3:= 2500;
  a4y3adv:= 920;
  aDos3:= 160;
  a4Dif:= 65;
  aTProm:= 1;
  aTpromActual:= aTProm;
  aPegado:= 1;
  aFinpegado:= 12;
  aParImpar:= 0;
  aSel:= 0;
  aSelBanda:= 150;
  aTipoSel:= 0;
  aQuies3:= 1;
  aQ3prof:= -1;
  aRandom:= 1;
  SetLength(Result,19);
  Result[0].name := 'Tiempo';
  Result[0].value := FloattoStr(aTProm);
  Result[1].name := 'prof';
  Result[1].value := InttoStr(aProf);
  Result[2].name := 'PermanentBrain';
  Result[2].value := InttoStr(aPermanentBrain);
  Result[3].name := 'NCorteQuiesIni';
  Result[3].value := InttoStr(aNCorteQuiesIni);
  Result[4].name := 'NCorteQuiesFin';
  Result[4].value := InttoStr(aNCorteQuiesFin);
  Result[5].name := 'Dos4';
  Result[5].value := InttoStr(aDos4);
  Result[6].name := '4y3';
  Result[6].value := InttoStr(a4y3);
  Result[7].name := '4y3adv';
  Result[7].value := InttoStr(a4y3adv);
  Result[8].name := 'Dos3';
  Result[8].value := InttoStr(aDos3);
  Result[9].name := '4Dif';
  Result[9].value := InttoStr(a4Dif);
  Result[10].name := 'Pegado';
  Result[10].value := InttoStr(aPegado);
  Result[11].name := 'FinPegado';
  Result[11].value := InttoStr(aFinPegado);
  Result[12].name := 'ParImpar';
  Result[12].value := InttoStr(aParImpar);
  Result[13].name := 'Sel';
  Result[13].value := InttoStr(aSel);
  Result[14].name := 'SelBanda';
  Result[14].value := InttoStr(aSelBanda);
  Result[15].name := 'TipoSel';
  Result[15].value := InttoStr(aTipoSel);
  Result[16].name := 'Quies3';
  Result[16].value := InttoStr(aQuies3);
  Result[17].name := 'Q3prof';
  Result[17].value := InttoStr(aQ3prof);
  Result[18].name := 'Random';
  Result[18].value := InttoStr(aRandom);
end;


procedure TColosus2.setParametros(params: TParametros);
var
   i: integer;
begin
   for i:=0 to (length(params) - 1) do
   begin
     if (params[i].name)='Tiempo' then
        if (aTprom <> StrtoFloat(params[i].value)) then
        begin
           aTprom := Strtofloat(params[i].value);
           aTpromActual:= aTProm;
        end;
     if (params[i].name)='prof' then
        aProf:= Strtoint(params[i].value);
     if (params[i].name)='PermanentBrain' then
        aPermanentBrain:= Strtoint(params[i].value);
     if (params[i].name)='Sel' then
        aSel:= Strtoint(params[i].value);
     if (params[i].name)='SelBanda' then
        aSelBanda:= Strtoint(params[i].value);
     if (params[i].name)='TipoSel' then
        aTipoSel:= Strtoint(params[i].value);
     if (params[i].name)='NCorteQuiesIni' then
        aNCorteQuiesIni:= Strtoint(params[i].value);
     if (params[i].name)='NCorteQuiesFin' then
        aNCorteQuiesFin:= Strtoint(params[i].value);
     if (params[i].name)='Dos4' then
        aDos4:= Strtoint(params[i].value);
     if (params[i].name)='4y3' then
        a4y3:= Strtoint(params[i].value);
     if (params[i].name)='4y3adv' then
        a4y3adv:= Strtoint(params[i].value);
     if (params[i].name)='Dos3' then
        aDos3:= Strtoint(params[i].value);
     if (params[i].name)='4Dif' then
        a4Dif:= Strtoint(params[i].value);
     if (params[i].name)='Pegado' then
        aPegado:= Strtoint(params[i].value);
     if (params[i].name)='FinPegado' then
        aFinPegado:= Strtoint(params[i].value);
     if (params[i].name)='ParImpar' then
        aParImpar:= Strtoint(params[i].value);
     if (params[i].name)='Quies3' then
        aQuies3:= Strtoint(params[i].value);
     if (params[i].name)='Q3prof' then
        aQ3prof:= Strtoint(params[i].value);
     if (params[i].name)='Random' then
        aRandom:= Strtoint(params[i].value);
   end;

end;


procedure TColosus2.setPatron(Patron: string; valor: Real);
var
  long, cant, i: integer;
  pat, mask: Tui;
  ficha: Tui;
begin
  inherited;
  cant:= 0;
  ficha:= 0;
  pat:= 0;
  mask:= 0;
  long:= Length(Patron);
  for i:=0 to (long-1) do
  begin
    mask:= mask + (1 shl i);
    if (Patron[1+i] = 'o') then
    begin
      pat:= pat + (1 shl i);
      cant:= cant + 1;
      ficha:= 0
    end;
    if (Patron[1+i] = 'x') then
    begin
      pat:= pat + (1 shl i);
      cant:= cant + 1;
      ficha:= 1
    end;
  end;

  SetLength(aPatrones[ficha,5-cant],Length(aPatrones[ficha,5-cant])+1);
  aPatrones[ficha,5-cant,Length(aPatrones[ficha,5-cant])-1].patron := pat;
  aPatrones[ficha,5-cant,Length(aPatrones[ficha,5-cant])-1].mask := mask;
  if (ficha = 0) then
     aPatrones[ficha,5-cant,Length(aPatrones[ficha,5-cant])-1].puntaje := Round(valor*100)
  else
     aPatrones[ficha,5-cant,Length(aPatrones[ficha,5-cant])-1].puntaje := -Round(valor*100)
end;


procedure TColosus2.setTurno(turno: char);
begin
  inherited;
  if (turno = 'o') then aTurno:= 0 else aTurno:= 1;
end;


function TColosus2.takeback: Boolean;
begin

end;


function TColosus2.takeforward: Boolean;
begin

end;


procedure TColosus2.BB2Tablero(const iBB, jBB: Tsi; var i, j: Tsi);
begin
  case iBB of
  0..14: begin
            i:=iBB;
            j:=jBB;
         end;
  15..29:begin
            i:=jBB;
            j:=iBB - 15;
         end;
  30..40:begin
            i:=40-iBB+jBB;
            j:=jBB;
         end;
  41..50:begin
            i:=jBB;
            j:=iBB+jBB-40;
         end;
  51..61:begin
            i:=jBB;
            j:=iBB-jBB-47;
         end;
  62..71:begin
            i:=iBB+jBB-61;
            j:=14-jBB;
         end;
  end;

end;


procedure TColosus2.actualizarMuertos(i, j: Tsi);
var
  c: TCoordBB;
  m, n: integer;
  puso, cant: Tsi;
  linea: Tui;
  nomuertos: Tui;
begin
  c:= aTablero2BB[i,j];
  puso:= aTurno xor 1;
  for m:=0 to 3 do
  begin
     if (c[m].i <> -1) then
     begin
        i:= c[m].i;
        j:=c[m].j;
        if ((aBBmuertos[aTurno,i] and (j shl 1)) = 0) then
        begin
           linea:= not(aBBfichas[puso,i] or aBBfuera[i]);
           nomuertos:= 0;
           for n:=0 to 10 do
           begin
              if (((linea and ($1F shl n)) xor ($1F shl n)) = 0) then
                 nomuertos:= nomuertos or ($1F shl n);
           end;
           aBBmuertos[aTurno,i]:= not nomuertos;
           linea:= aBBfichas[aTurno,i] and nomuertos;
           cant:= 0;
           for n:=0 to 14 do
              if ((linea and (1 shl n)) <> 0) then inc(cant);
           aCantFichas[aTurno,i]:= cant;
        end;
     end;
  end;
end;


function TColosus2.Tablero2BB(const i, j: Tsi): TCoordBB;
begin
   inc(oTablero2BB);
   Result[0].i := i;
   Result[0].j := j;
   Result[1].i :=  j + 15;
   Result[1].j := i;
   if ((i-j)<11) and ((j-i)<1) then
   begin
      Result[2].i := 40-i+j;
      Result[2].j := j;
   end else
      if ((j-i)>0) and ((j-i)<11) then
      begin
         Result[2].i := 41+j-1-i;
         Result[2].j := i;
      end else
      begin
         Result[2].i := -1;
         Result[2].j := -1;
      end;

   if ((j+i)>3) and ((i+j)<15) then
   begin
      Result[3].i := 51+i+j-4;
      Result[3].j := i;
   end else
      if ((i+j)>14) and ((i+j)<25) then
      begin
         Result[3].i := 62+i+j-15;
         Result[3].j := 14 - j;
      end else
      begin
         Result[3].i := -1;
         Result[3].j := -1;
      end;

end;


function TColosus2.getOutput: string;
begin
  Result:= aOutput;
end;

procedure TColosus2.resetContadores;
var
  i: integer;
begin
  oNodos:= 0;
  oNodosQ:= 0;
  oNodosQ3:= 0;
  oAlphaBetas:= 0;
  oEvaluados:= 0;
  oEvaluadosNull:= 0;
  oCutOffs:= 0;
  oTablero2BB:= 0;
  oLegales:= 0;
  oLegalesp1:= 0;
  oLegalespn:= 0;
  jdif:= 0;
  jcreadas:= 0;
  ljcreadas:= 0;
  oEvhash:= 0;
  oEvNoHash:= 0;
  oCorteNM:= 0;
  oPone:= 0;
  oSelTotal:=0;
  oSelbien:=0;
  oSelmal:=0;
  for i:= 0 to 5 do
  begin
    oHash[i]:= 0;
    oNoHash[i]:= 0;
  end;
end;

destructor TColosus2.Destroy;
begin
  if aGuessCorriendo then
  begin
     aTerminarGuess:= true;
     aThreadGuess.WaitFor;
     aThreadGuess.Free;
  end;
  aHashTable.Free;   
end;

procedure TColosus2.test(const funcion: string);
var
  i, punt, tipohash,aux1,aux2: Integer;
  prof: shortint;
  lj: TJugadas;
  ljr: TJugadasR;
  j: TJugada;
  x: Int64;
  danger: integer;
  habia3, hay4: Boolean;
  c: TCoordBB;
begin
   x:= $1212121212121212;

   if (funcion = 'gl') then
   begin
     aHashTable.guardarLinea(x,1,10,danger);
     for i:=0 to 10000000 do
       aHashTable.getLinea(x,1,punt,danger);
   end;

   if (funcion = 't2bb') then
   begin
      for i:=0 to 100000000 do
         c:= self.tablero2bb(7,7)
   end;
   if (funcion = 'en') then
      for i:=0 to 1000000 do
         self.evaluarnull
   else
   if (funcion = 'ed') then
      for i:=0 to 1000000 do
         self.evaluardif(4,6, habia3, hay4)
   else
   if (funcion = 'gp') then
     for i:=0 to 1000000 do
       aHashTable.getPosicion(aHash,1,5,5,punt,prof,tipohash)
   else
   if (funcion = 'el') then
     for i:=0 to 10000000 do
       eslegal(1,1)
   else
   if (funcion = 'mod') then
     for i:=0 to 1000000 do
       aHash:= ($2385238594769476 + i) mod 2000000
   else
   if (funcion = 'mod2') then
     for i:=0 to 1000000 do
       aHash:= ($2385238594769476 + i) and 2097151
   else
   if (funcion = 'le') then
     for i:=0 to 100000 do
     begin
       lj:= TJugadas.Create(true);
       //self.legalesv(lj,2);
       lj.free;
     end
   else
   if (funcion = 'ler') then
     for i:=0 to 10000 do
     begin
       ljr:= TJugadasR.Create;
       self.legales(ljr,2, habia3);
       ljr.free;
     end
   else
   if (funcion = 'j') then
     for i:=0 to 1400000 do
     begin
       j:= TJugada.Create(2,2,10);
       j.Free;
     end
   else
   if (funcion = 'pf') then
     for i:=0 to 10000000 do
     begin
       self.pone_ficha_BB(5,5,true);
     end;
   if (funcion = 'lj') then
     for i:=0 to 437000 do
     begin
       ljr:= TJugadasR.Create();
       ljr.Free;
     end;
   if (funcion = 'ghl') then
     for i:=0 to 100000000 do
     begin
       aHashTable.getHashL(x,0,3);
     end;

end;





function TColosus2.int2bin(n: Integer): string;
var
  i: integer;
  s: string;
begin
   Result:= '';
   for i:=0 to 15 do
   begin
      if ((n and (1 shl i)) = 0) then s:='0' else s:= '1';
      REsult:= Result + s;
   end;
end;

procedure TColosus2.reset;
begin
   inherited reset;
   aHashTable.vaciar;
   aHash:= 0;
   aVacio:= true;
   aFichasTotales:= 0;
   aCantMovidas:= 0;
   aTTotalPensar:= 0;
   inicializarBB;
end;





function TColosus2.segunda: Tcoordenada;
begin
   Result.i:= Random(3) - 1 + aJAnterior.i;
   if Result.i = aJAnterior.i then
      Result.j:= Random(2)*2 - 1 + aJAnterior.j
   else
      Result.j:= Random(3) - 1 + aJAnterior.j;
end;

procedure TColosus2.armarOutput;
var
  punt: real;
begin
   punt:= oPuntaje/100;
   if (oAlphabetas=0) then oaLphabetas:= High(oAlphabetas);
   aOutput:= aOutput + ''#13#10 +
            '----------------'#13#10 +
            'Tprom: ' + floattostr(aTprompensar)+ ''#13#10 +
            'TpromActual: ' + floattostr(aTpromActual)+ ''#13#10 +
            'TAcumulado: ' + floattostr(aTAcumulado)+ ''#13#10 +
            'Nodos: ' + InttoStr(oNodos) + ''#13#10 +
            'NodosQ4: ' + InttoStr(oNodosQ) + ''#13#10 +
            'NodosQ3: ' + InttoStr(oNodosQ3) + ''#13#10 +
            'jdif: ' + InttoStr(jdif) + ''#13#10 +
            {'jcreadas: ' + InttoStr(jcreadas) + ''#13#10 +
            'ljcreadas: ' + InttoStr(ljcreadas) + ''#13#10 + }
            'Seltotal: ' + InttoStr(oSeltotal) + ''#13#10 +
            'Selbien: ' + InttoStr(oSelbien) + ''#13#10 +
            'Selmal: ' + InttoStr(oSelmal) + ''#13#10 +
            'Nodos/s: ' + FloattoStr(oNodos/(oTiempo+0.0001)) + ''#13#10 +
            'AlphaBetas: ' + InttoStr(oAlphaBetas) + ''#13#10 +
            'Evaluados: ' + InttoStr(oEvaluados) + ''#13#10 +
            'EvaluadosNull: ' + InttoStr(oEvaluadosNull) + ''#13#10 +
            'Tablero2BB: ' + InttoStr(oTablero2BB) + ''#13#10 +
            'Legales: ' + InttoStr(oLegales) + ''#13#10 +
            'LegalesP1: ' + InttoStr(oLegalesp1) + ''#13#10 +
            'LegalesPn: ' + InttoStr(oLegalespn) + ''#13#10 +
            'Prom Legales: ' + FloattoStr(oLegales/oAlphabetas) + ''#13#10 +
            'CutOffs por NullMove: ' + InttoStr(oCorteNM) + ''#13#10 +
            'CutOffs: ' + InttoStr(oCutOffs) + ''#13#10 +
            'CutOffs en j: ' + FloattoStr(oNodos/oAlphaBetas) + ''#13#10 +
            'Pone ficha: ' + FloattoStr(oPone) + ''#13#10 +
//            'Hash 5: ' + InttoStr(oHash[5]) + ''#13#10 +
//            'No Hash 5: ' + InttoStr(oNoHash[5]) + ''#13#10 +
//            'Hash 4: ' + InttoStr(oHash[4]) + ''#13#10 +
//            'No Hash 4: ' + InttoStr(oNoHash[4]) + ''#13#10 +
//            'Hash 3: ' + InttoStr(oHash[3]) + ''#13#10 +
//            'No Hash 3: ' + InttoStr(oNoHash[3]) + ''#13#10 +
//            'Hash 2: ' + InttoStr(oHash[2]) + ''#13#10 +
//            'No Hash 2: ' + InttoStr(oNoHash[2]) + ''#13#10 +
//            'Hash 1: ' + InttoStr(oHash[1]) + ''#13#10 +
//            'No Hash 1: ' + InttoStr(oNoHash[1]) + ''#13#10 +
            'EvHash: ' + InttoStr(oEvHash) + ''#13#10 +
            'EvNoHash: ' + InttoStr(oEvNoHash) + ''#13#10#13#10 +
            aHashTable.getOutput;

end;

function TColosus2.tElapsed: Real;
begin
   Result:= MilliSecondsBetween(aFechaInicio,Now)/1000;
end;


end.
