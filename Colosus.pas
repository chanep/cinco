unit Colosus;

interface

uses Classes;

const

f0: Char = '-'; //lugar vacio
f1: Char = 'o'; //ficha jugador 1
f2: Char = 'x'; //ficha jugador 2
f3: Char = '.'; //fuera de tablero

pat_o: array[0..26, 0..5] of Char = (
       'ooooo',
       '-oooo-','oo-oo','ooo-o','o-ooo','oooo-','-oooo',
       '-ooo-','o-o-o','-o-oo','oo-o-','o-oo-','-oo-o','ooo--','--ooo',
       '--oo-','-oo--','-o-o-','o-o--','--o-o','oo---','---oo',
       '--o--','-o---','---o-','o----','----o'
       );
pat_x: array[0..26, 0..5] of Char = (
       'xxxxx',
       '-xxxx-','xx-xx','xxx-x','x-xxx','xxxx-','-xxxx',
       '-xxx-','x-x-x','-x-xx','xx-x-','x-xx-','-xx-x','xxx--','--xxx',
       '--xx-','-xx--','-x-x-','x-x--','--x-x','xx---','---xx',
       '--x--','-x---','---x-','x----','----x'
       );
punt:  array[0..26] of Real = (
       1000,
       5   , 0.9 , 0.9 , 0.9 , 0.85, 0.85,
       1.0 , 0.5 , 0.2 , 0.2 , 0.2 , 0.2 , 0.2, 0.2,
       0.4 , 0.4 , 0.35, 0.15, 0.15, 0.13, 0.13,
       0.15, 0.13, 0.13, 0.1 , 0.1
       );
punt_adv:  array[0..26] of Real = (
       1000,
       100 , 100 , 100 , 100 , 100 , 100 ,
       1.5 , 0.8 , 0.3 , 0.3 , 0.3 , 0.3 , 0.3, 0.3,
       0.4 , 0.4 , 0.35, 0.15, 0.15, 0.13, 0.13,
       0.15, 0.13, 0.13, 0.1 , 0.1
       );


type
//tablero
TMatriz = array[0..14,0..14] of char;

//tablero desglosado en todas sus filas, columnas y diagonales
Tvector = array[0..71,0..14] of char;

TColosus = class
private
  tablero : TMatriz;
  vectores: Tvector;
public
  procedure cargar(sl: TStrings);

end;

implementation

{ TColosus }

procedure TColosus.cargar(sl: TStrings);
var
  i, j: Integer;
  s: string;
begin
  for i:= 0 to 14 do
    for j:= 0 to 14 do
    begin
      s:= sl[i];
      tablero[i,j]:= s[j+1]
    end;
end;

end.
