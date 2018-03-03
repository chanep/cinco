unit Utablero;

interface
uses
 ExtCtrls, Graphics, Forms, Classes;

const
cescaque: Integer = 17;
cradio: Integer = 6;

type
TTablero = class
private
  AForm: TForm;
  ABmp: TBitmap;
public

constructor create(F: TForm);
procedure pone(i,j: Integer; ficha:char);
function pxtocoord(x,y: Integer; var i,j: Integer): Boolean;
procedure coordtopx(i,j: Integer; var x,y: Integer);
procedure cuadrado(i,j: Integer; ficha:char);
procedure inicializar;
procedure refresh;
procedure cargar_tablero(sl: TStrings);
end;

implementation
uses ucinco;

{ TTablero }

constructor TTablero.create(F: TForm);
begin
  AForm:= F;
  aBMp:= nil;
  inicializar;
end;



procedure TTablero.pone(i, j:Integer; ficha: char);
var
  x, y:Integer;
begin
   coordtopx(i,j,x,y);
   with ABMp.canvas do
   begin
      if ficha='o' then
      begin
         Pen.Color:= clBlue;
         Pen.Width:= 2;
         Ellipse(x-cradio,y-cradio,x+cradio+1,y+cradio+1);
      end else if ficha='x' then
            begin
               Pen.Color:= clRed;
               Pen.Width:= 2;
               moveto(x-cradio,y-cradio);
               lineto(x+cradio+0,y+cradio+0);
               moveto(x-cradio,y+cradio);
               lineto(x+cradio+0,y-cradio-0);
            end;
   end;
    refresh;
end;


procedure TTablero.cuadrado(i, j: Integer; ficha: char);
var
  x, y:Integer;
  color: TColor;
begin
   case ficha of
     'o': color:= $00EFBCBC;
     'x': color:= $00BCBCEF;
     '-': color:= $00FFFFFF;
   end;
   coordtopx(i,j,x,y);
   with ABMp.canvas do
   begin
     Pen.Color:= color;
     Brush.Color:= color;
     rectangle(x-cradio-1,y-cradio-1,x+cradio+3,y+cradio+3);
   end;
   if ficha <> '-' then
       pone(i,j,ficha)
   else
      refresh;
end;

function TTablero.pxtocoord(x, y: Integer; var i, j: Integer): Boolean;
begin
   i:= Trunc((y-1)/(cescaque+1));
   j:= Trunc((x-1)/(cescaque+1));
   if (i>=0) and (i<=14) and (j>=0) and (j<=14) then
     Result:= true
   else
     Result:= false;
end;

procedure TTablero.coordtopx(i, j: Integer; var x, y: Integer);
begin
   x:= Trunc(j*(cEscaque + 1) +cEscaque/2 +1);
   y:= Trunc(i*(cEscaque + 1) +cEscaque/2 +1);
end;

procedure TTablero.refresh;
begin
   Aform.Canvas.Draw(coffx,coffy,ABmp);
end;



procedure TTablero.inicializar;
var
 i,x,y,lado: Integer;
begin
  lado:= cescaque*15 + 16;
  ABmp.Free;
  ABmp:= TBitmap.Create;
  ABmp.Height:= lado;
  ABmp.Width:= lado;
  With ABmp.Canvas do
  begin
     pen.Color:= $00606060;
     pen.Width:= 1;
     for i:=0 to 15 do
     begin
        x:= i*(cEscaque + 1);
        moveto(x,0);
        lineto(x,lado);
     end;
     for i:=0 to 15 do
     begin
        y:= i*(cEscaque + 1);
        moveto(0,y);
        lineto(lado,y);
     end;
  end;
  refresh;
end;



procedure TTablero.cargar_tablero(sl: TStrings);
var
  i, j: Integer;
  s: string;
begin
  for i:=0 to 14 do
  begin
     s:= sl[i];
     for j:=0 to 14 do
        self.pone(i,j,s[j+1]);
  end;

end;

end.
