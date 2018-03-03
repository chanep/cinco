unit UCinco;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Ucolosus, Ucolosus2, Grids, ValEdit, DateUtils, Contnrs,
  ExtCtrls, UTablero, Menus, Ujugada;

const
  coffx: Integer= 22;
  coffy: Integer= 20;

type
  Tfruta=class
  x: array[0..1000000] of integer;
  end;


  TFcinco = class(TForm)
    VLPunt: TValueListEditor;
    VLPunt_adv: TValueListEditor;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label16: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Menu: TMainMenu;
    Nuevo: TMenuItem;
    Salvar: TMenuItem;
    Cargar: TMenuItem;
    RE: TRichEdit;
    Jugar: TMenuItem;
    Bback: TButton;
    Bforward: TButton;
    CvsC: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Escore1: TEdit;
    Escore2: TEdit;
    EEmpates: TEdit;
    Label34: TLabel;
    RBo: TRadioButton;
    Rbx: TRadioButton;
    VLParametros1: TValueListEditor;
    MOutput: TMemo;
    BTest: TButton;
    LTime: TLabel;
    ETest: TEdit;
    VLPunt2: TValueListEditor;
    VLPunt_adv2: TValueListEditor;
    VLParametros2: TValueListEditor;
    Emax: TEdit;
    Eprom: TEdit;
    BReset: TButton;
    LTTotal1: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    LTprom1: TLabel;
    LTTotal2: TLabel;
    LTprom2: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label3: TLabel;
    Label37: TLabel;
    procedure BResetClick(Sender: TObject);
    procedure BTestClick(Sender: TObject);

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtiempoClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    function juegacolosus(c: TColosus): TCoordenada;

    procedure cambiarturno;
    procedure RBoClick(Sender: TObject);
    procedure RbxClick(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure CargarClick(Sender: TObject);
    procedure JugarClick(Sender: TObject);
    procedure NuevoClick(Sender: TObject);
    procedure BbackClick(Sender: TObject);
    procedure BforwardClick(Sender: TObject);
    procedure CvsCClick(Sender: TObject);

  private
    procedure getParametros(c: TColosus; player: integer);
    procedure setParametros(c: TColosus; player: integer);
    procedure setpatrones(c: TColosus; player: integer);
    procedure getOutput(c: TColosus);
  public
    { Public declarations }
  end;

var
  Fcinco: TFcinco;
  x,y: array[0..14] of char;
  p:Pchar;
  i:integer;
  j:Integer;
  colosus, colosus2: Tcolosus;
  Vpato: TVpatrones;
  Vpatx: TVpatrones;
  s2: string;
  r: real;
  td2: Tvectores;
  Tablero: TTablero;
  turno, jugador: Char;
  lineaganadora: TVLinea5;
  terminado: boolean;
  CvsCstat: Boolean;
  prof: Integer;
implementation

{$R *.dfm}

procedure TFcinco.FormCreate(Sender: TObject);
begin
Randomize;
DecimalSeparator:= '.';
Tablero:= TTablero.Create(self);
colosus:= Tcolosus2.Create;
colosus.UpdateMethod:= getoutput;
self.setpatrones(colosus,1);
self.getParametros(colosus,1);
self.getParametros(colosus,2);
turno:='o';
jugador:='o';
terminado:= false;
CvsCstat:= false;
end;


procedure TFcinco.Button1Click(Sender: TObject);
var
s,s1,s2: string;
jugada: Tjugada;
Ahora: TDateTime;
segundos, punt_ini: Real;
ev: char;

begin
{
self.Caption:= '5 - Pensando...';
Application.ProcessMessages;
colosus:= Tcolosus.Create;
td2:= colosus.tablerod;


colosus.carga_patrones(Vpato,Vpatx,Vpj,Vpa);
colosus.cargar_tablero(RE.lines);
colosus.llena_tablerod;
s:= Eturno.text;
colosus.Aficha:=s[1];
colosus.sel:= strtoint(Esel.Text);
Ahora:= Now;
if s[1]= 'x' then ev:='o' else ev:='x';
punt_ini:=colosus.evaluar_2(ev,colosus.tablerod);
Jugada := colosus.lamejor(s[1],colosus.tablerod,strtoint(Eprof.text),-punt_ini);
segundos:=MilliSecondsBetween(Ahora,Now)/1000;

ETiempo.Text:= floattostr(segundos);
Enodos.Text:= inttostr(colosus.nodos);
Enodos_ev.Text:= inttostr(colosus.nodos_ev);
ERuta.Text:= jugada.ruta;
Ei.text:= Inttostr(jugada.i);
Ej.text:= Inttostr(jugada.j);
Epunt.text:= Floattostr(jugada.pabs);
jugada.free;
colosus.Free;
self.Caption:= '5';
 }
end;


procedure TFcinco.BtiempoClick(Sender: TObject);
var
s,s1,s2: string;
jugada, j2: Tjugada2;
j1: Tjugada;
Ahora: TDateTime;
segundos: Real;
  p: PChar;
  v2: array[0..15] of char;
  v: array[0..1,0..15] of char;
begin
{
jugada:= Tjugada2.Create(1,2,3.3,4.4,true);
j2:= Tjugada2.Create(5,6,7.7,8.8,false);
j2:= jugada.copiar;
j1:= j2;
Etiempo.Text:= inttostr(j1.i);
Enodos.Text:= floattostr(j1.pabs);


colosus2:= Tcolosus2.Create;
for i:=0 to 28 do
begin
   s1:=VLPunt.Keys[i + 1];
   s2:= VLPunt_adv.Keys[i + 1];
   for j:=0 to 6 do
   begin
      Vpato[i,j]:= s1[j+1];
      Vpatx[i,j]:= s2[j+1];
   end;
   Vpj[i]:= strtofloat(VLPunt.Values[VLPunt.Keys[i + 1]]);
   Vpa[i]:= strtofloat(VLPunt_adv.Values[VLPunt_adv.Keys[i + 1]]);
end;
colosus2.carga_patrones(Vpato,Vpatx,Vpj,Vpa);
colosus2.cargar_tablero(RE.lines);
colosus2.llena_tablerod;
s:= Eturno.text;
colosus2.sel:= strtoint(Esel.Text);
colosus2.poner_ficha('x',strtoint(Ei.text),strtoint(Ej.text),td2);

v[0]:='----------------';
v[1]:='----------ooo--';
i:=18;
v[0,i]:='x';
v2:='ooo';
p:= StrPos(v[0],v2);
i:= p-v[0];
Enodos_ev.Text:= inttostr(i);
Ahora:= Now;
for i:=0 to 1000 do
begin
   //colosus2.evaluar31('o',colosus2.tablerod,td2,strtoint(Ei.text),strtoint(Ej.text));
   colosus2.evaluar('o',colosus2.tablerod);
   //colosus2.es_cerca(strtoint(Ei.text),strtoint(Ej.text),colosus2.tablerod);
   // v2:=v;
   //p:= StrPos(v2,'--o--');
end;
segundos:=MilliSecondsBetween(Ahora,Now)/1000;
ETiempo.Text:= floattostr(segundos);
}

end;



procedure TFcinco.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
i,j: integer;
n: Integer;
begin


  if (turno=jugador) and not(terminado) then
  begin
     x:= x - coffx;
     y:= y - coffy;
     if tablero.pxtocoord(x,y,i,j) then
        if colosus.pone_ficha(i,j) then
        begin
           tablero.pone(i,j,jugador);
           cambiarturno;
           if colosus.gano(jugador,i,j,lineaganadora) then
           begin
              terminado:= true;
              for n:=0 to 4 do
                tablero.cuadrado(lineaganadora[n].i,lineaganadora[n].j,jugador);
           end else
           begin
              setparametros(colosus,1);
              juegacolosus(colosus);
              LTtotal1.Caption:= floattoStr(Round(colosus.TtotalPensar*10)/10);
              LTprom1.Caption:= floattoStr(Round(colosus.TpromPensar*10)/10);
           end;
        end;
  end;

end;

procedure TFcinco.Button2Click(Sender: TObject);
begin
//Tablero:= TTablero.Create(Image1);
end;

procedure TFcinco.FormPaint(Sender: TObject);
begin
   tablero.refresh;
end;


function TFcinco.juegacolosus(c: Tcolosus): Tcoordenada;
var
s,s1,s2: string;
coord: TCoordenada;
Ahora: TDateTime;
segundos, punt_ini: Real;
col: char;
n: Integer;
begin

   self.Caption:= 'Colosus - Pensando...';
   self.OnMouseDown:= nil;
   Application.ProcessMessages;
   Ahora:= Now;
   if jugador= 'x' then col:='o' else col:='x';
   coord := c.getBest;
   MOutput.Text:= c.getOutput;
   segundos:=MilliSecondsBetween(Ahora,Now)/1000;
   if (coord.i <>-1) then
   begin
      tablero.pone(coord.i,coord.j,col);
      cambiarturno;
   end else
      terminado := true;
    Caption:= 'Colosus';
   if c.gano(col,coord.i,coord.j,lineaganadora) then
   begin
      terminado:= true;
      for n:=0 to 4 do
         tablero.cuadrado(lineaganadora[n].i,lineaganadora[n].j,col);
   end;
    application.ProcessMessages;
    self.OnMouseDown:= FormMouseDown;
   REsult:= coord;
end;

procedure TFcinco.setpatrones(c: TColosus; player: integer);
var
  patron,puntaje: string;
begin
DecimalSeparator:= '.';
if (player=1) then
begin
   for i:=1 to (VLpunt.RowCount - 1) do
   begin
      patron:=VLPunt.Keys[i];
      puntaje:= VLPunt.Values[VLPunt.Keys[i]];
      c.setPatron(patron,strtofloat(puntaje));
   end;

   for i:=1 to (VLpunt_adv.RowCount - 1) do
   begin
      patron:=VLPunt_adv.Keys[i];
      puntaje:= VLPunt_adv.Values[VLPunt_adv.Keys[i]];
      c.setPatron(patron,strtofloat(puntaje));
   end;
end else
begin
   for i:=1 to (VLpunt2.RowCount - 1) do
   begin
      patron:=VLPunt2.Keys[i];
      puntaje:= VLPunt2.Values[VLPunt2.Keys[i]];
      c.setPatron(patron,strtofloat(puntaje));
   end;

   for i:=1 to (VLpunt_adv2.RowCount - 1) do
   begin
      patron:=VLPunt_adv2.Keys[i];
      puntaje:= VLPunt_adv2.Values[VLPunt_adv2.Keys[i]];
      c.setPatron(patron,strtofloat(puntaje));
   end;
end;

end;

procedure TFcinco.cambiarturno;
begin
   if turno='o' then turno:='x' else turno:='o';
end;

procedure TFcinco.RBoClick(Sender: TObject);
begin

   jugador:='o';
   if turno<>jugador then
   begin
      setparametros(colosus,1);
      juegacolosus(colosus);
   end;

end;

procedure TFcinco.RbxClick(Sender: TObject);
begin
   jugador:='x';
   if turno<>jugador then
   begin
      setparametros(colosus,1);
      juegacolosus(colosus);
   end;
end;

procedure TFcinco.SalvarClick(Sender: TObject);
var
  i, j: Integer;
  s: string;
begin
  RE.Lines.Clear;
  for i:= 0 to 14 do
  begin
    s:='---------------';
    for j:= 0 to 14 do
      s[j+1]:=colosus.tablero[i,j];
    RE.Lines.Add(s);
  end;
  RE.Lines.Add(turno)

end;

procedure TFcinco.CargarClick(Sender: TObject);
var
  s: string;
begin

  colosus.Free;
  colosus:= Tcolosus2.Create;
  colosus.UpdateMethod:= getOutput;
  tablero.inicializar;
  colosus.cargar_tablero(RE.Lines);
  self.setpatrones(colosus,1);
  tablero.cargar_tablero(RE.Lines);
  turno:=colosus.turno;
  terminado:= false;

end;

procedure TFcinco.JugarClick(Sender: TObject);
begin
   if turno<>jugador then
   begin
      setparametros(colosus,1);
      juegacolosus(colosus);
   end;
end;

procedure TFcinco.NuevoClick(Sender: TObject);
var
  i, j: Integer;
  s: string;
begin

  colosus.Free;
  colosus:= Tcolosus2.Create;
  colosus.UpdateMethod:= getOutput;
  setpatrones(colosus,1);
  tablero.inicializar;
  turno:='o';
  jugador:='o';
  RBo.Checked:= true;
  terminado:= false;

end;

procedure TFcinco.BbackClick(Sender: TObject);
var
  i,j, n, m: Integer;
begin
   {
   if colosus.takeback then
   begin
         i:= colosus.AMovelist[colosus.Ajug_num,0];
         j:= colosus.AMovelist[colosus.Ajug_num,1];
         cambiarturno;
         tablero.cuadrado(i,j,'-');
      if terminado then
      begin
         m:= colosus.Ajug_num;
         terminado:= false;
         for n:=1 to m do
             BbackClick(nil);
         for n:=1 to m do
             BforwardClick(nil);
      end;
   end;
   }
end;

procedure TFcinco.BforwardClick(Sender: TObject);
var
  i,j, n: Integer;
begin
   {
   if colosus.takeforward then
   begin
     i:= colosus.AMovelist[colosus.Ajug_num-1,0];
     j:= colosus.AMovelist[colosus.Ajug_num-1,1];
     tablero.pone(i,j,turno);
     if colosus.gano(turno,i,j,lineaganadora) then
     begin
         terminado:= true;
          for n:=0 to 4 do
             tablero.cuadrado(lineaganadora[n,0],lineaganadora[n,1],turno);
     end;
     cambiarturno;
   end;
   }
end;

procedure TFcinco.CvsCClick(Sender: TObject);
var
  j, j2: TJugada;
  l: TObjectlist;
  c1, c2: TColosus;
  coord: Tcoordenada;
  ultimo: char;
  empate: Boolean;
begin

If not(CvsCstat) then
begin
  DecimalSeparator:= '.';
  colosus.Free;
  c1:= TColosus2.Create;
  c2:= TColosus2.Create;
  c1.UpdateMethod:= getOutput;
  c2.UpdateMethod:= getOutput;
  setparametros(c1,1);
  setparametros(c2,2);
  setpatrones(c1,1);
  setpatrones(c2,2);
  Nuevo.Enabled:= false;
  Salvar.Enabled:= false;
  Cargar.Enabled:= false;
  Jugar.Enabled:= false;
  CvsC.Caption:='Detener';
  Application.ProcessMessages;
  CvsCstat:= true;


While CvsCstat do
begin
  terminado:= false;
  empate:=false;
  while (not(terminado) and CvsCstat) do
  begin
    turno:='o';
    jugador:='x';
    coord:=juegacolosus(c1);
    LTtotal1.Caption:= floattoStr(Round(c1.TtotalPensar*10)/10);
    LTprom1.Caption:= floattoStr(Round(c1.TpromPensar*10)/10);
    ultimo:='o';
    if (coord.i=-1) then empate:=true;
    if (not(terminado) and CvsCstat) then
    begin
      turno:='x';
      jugador:='o';
      c2.pone_ficha(coord.i,coord.j);
      coord:=juegacolosus(c2);
      LTtotal2.Caption:= floattoStr(Round(c2.TtotalPensar*10)/10);
      LTprom2.Caption:= floattoStr(Round(c2.TpromPensar*10)/10);
      ultimo:='x';
      if coord.i=-1 then empate:=true;
      if not(terminado) then
         c1.pone_ficha(coord.i,coord.j);
    end;
  end;
  if empate and CvsCStat then
     EEmpates.Text:= inttostr(1+strtoint(EEmpates.Text))
  else
  begin
    if (ultimo='o') and CvsCStat then
       Escore1.Text:= inttostr(1+strtoint(Escore1.Text));
    if (ultimo='x') and CvsCStat then
       Escore2.Text:= inttostr(1+strtoint(Escore2.Text));
  end;
  //sleep(100);

  Application.ProcessMessages;
  if (Escore1.Text = Emax.Text) then CvsCstat:= false;
  c1.reset;
  c2.reset;
  tablero.inicializar;

end;
  Eprom.Text:= inttostr(Round( 1000*(strtoint(EScore2.Text) + strtoint(EEmpates.Text)/2)/
                        (strtoint(EScore1.Text) + strtoint(EEmpates.Text)/2)));
  tablero.refresh;                      
  Nuevo.Enabled:= true;
  Salvar.Enabled:= true;
  Cargar.Enabled:= true;
  Jugar.Enabled:= true;
  CvsC.Caption:='Colosus vs Colosus';
  c1.free;
  c2.Free;
  colosus:= Tcolosus2.Create;
  colosus.UpdateMethod:= getOutput;
  setpatrones(colosus,1);
  tablero.inicializar;
  turno:='o';
  jugador:='o';
  RBo.Checked:= true;
  terminado:= false;
end else
begin
   CvsCstat:= false;
end;

end;





procedure TFcinco.getParametros(c: TColosus; player: integer);
var
  i: integer;
  p: TParametros;
begin
  p:= c.getParametros;
  if (player=1) then
     for i:=0 to (length(p) - 1) do
        VLParametros1.InsertRow(p[i].name,p[i].value,true)
  else
     for i:=0 to (length(p) - 1) do
        VLParametros2.InsertRow(p[i].name,p[i].value,true)
end;


procedure TFcinco.setparametros(c: TColosus; player: integer);
var
  name, value: string;
  p: TParametros;
begin
  DecimalSeparator:= '.';
  if (player=1) then
     for i:=1 to (VLParametros1.RowCount - 1) do
     begin
        name := VLParametros1.Keys[i];
        value:= VLParametros1.Values[VLParametros1.Keys[i]];
        SetLength(p,length(p)+1);
        p[length(p)-1].name:= name;
        p[length(p)-1].value:= value;
     end
  else
     for i:=1 to (VLParametros2.RowCount - 1) do
     begin
        name := VLParametros2.Keys[i];
        value:= VLParametros2.Values[VLParametros2.Keys[i]];
        SetLength(p,length(p)+1);
        p[length(p)-1].name:= name;
        p[length(p)-1].value:= value;
     end;
  c.setParametros(p);
end;



procedure TFcinco.BTestClick(Sender: TObject);
var
  Ahora: TDateTime;
begin
  Ahora:= now;
  colosus.test(ETest.Text);
  LTime.Caption:= FloattoStr(MilliSecondsBetween(Ahora,Now)/1000);
end;

procedure TFcinco.BResetClick(Sender: TObject);
begin
  Escore1.Text:= '0';
  Escore2.Text:= '0';
  EEmpates.Text:= '0';
end;

procedure TFcinco.getOutput(c: TColosus);
begin
   MOutput.Text:= c.getOutput;
   Application.ProcessMessages;
end;

end.
