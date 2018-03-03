program cinco;

{%File 'ModelSupport\UHashtable\UHashtable.txvpck'}
{%File 'ModelSupport\Utablero\Utablero.txvpck'}
{%File 'ModelSupport\UJugada\UJugada.txvpck'}
{%File 'ModelSupport\Utipos2\Utipos2.txvpck'}
{%File 'ModelSupport\UColosus2\UColosus2.txvpck'}
{%File 'ModelSupport\UColosus\UColosus.txvpck'}
{%File 'ModelSupport\UCinco\UCinco.txvpck'}
{%File 'ModelSupport\default.txvpck'}
{%File 'ModelSupport\UJugada2\UJugada2.txvpck'}
{%ToDo 'cinco.todo'}

uses
  Forms,
  UCinco in 'UCinco.pas' {Fcinco},
  Utablero in 'Utablero.pas',
  UJugada in 'UJugada.pas',
  UColosus in 'UColosus.pas',
  UColosus2 in 'UColosus2.pas',
  UHashtable in 'UHashtable.pas',
  Utipos2 in 'Utipos2.pas',
  UJugada2 in 'UJugada2.pas',
  UThreadMetodo in 'UThreadMetodo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFcinco, Fcinco);
  Application.Run;
end.
