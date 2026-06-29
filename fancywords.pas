program FancyWords;

{$mode objfpc}{$H+}

{ FancyWords - a tiny figlet clone, built from scratch.
  Font glyphs in this file were auto-generated from a bitmap font
  (see gen_pas.py) into a simple block style - this is OUR font data,
  not a copy of any figlet .flf font file. }

uses
  SysUtils;

const
  GLYPH_H = 8;
  GLYPH_W = 8;
  KERNING = 1; // columns of blank space between letters

type
  TGlyphRows = array[0..GLYPH_H - 1] of string[GLYPH_W];
  TFontChar = record
    Ch: Char;
    Rows: TGlyphRows;
  end;

const
  FONT_SIZE_COUNT = 36;
  FONT: array[0..FONT_SIZE_COUNT - 1] of TFontChar = (
    (Ch: 'A'; Rows: ('  ##    ', '  ###   ', '  ###   ', ' ## #   ', ' ## ##  ', ' #####  ', ' #  ##  ', '##   #  ')),
    (Ch: 'B'; Rows: (' ####   ', ' #  ##  ', ' #  ##  ', ' ####   ', ' #  ##  ', ' #   #  ', ' #  ##  ', ' ####   ')),
    (Ch: 'C'; Rows: ('  ###   ', ' ##  #  ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##  #  ', '  ###   ')),
    (Ch: 'D'; Rows: (' ####   ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' ####   ')),
    (Ch: 'E'; Rows: (' #####  ', ' ##     ', ' ##     ', ' #####  ', ' ##     ', ' ##     ', ' ##     ', ' #####  ')),
    (Ch: 'F'; Rows: (' #####  ', ' ##     ', ' ##     ', ' #####  ', ' ##     ', ' ##     ', ' ##     ', ' ##     ')),
    (Ch: 'G'; Rows: ('  ###   ', ' ##  #  ', ' ##     ', ' #      ', ' #  ##  ', ' ##  #  ', ' ##  #  ', '  ####  ')),
    (Ch: 'H'; Rows: (' #  ##  ', ' #  ##  ', ' #  ##  ', ' #####  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ')),
    (Ch: 'I'; Rows: (' #####  ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', ' #####  ')),
    (Ch: 'J'; Rows: ('  ###   ', '    #   ', '    #   ', '    #   ', '    #   ', '    #   ', '   ##   ', ' ####   ')),
    (Ch: 'K'; Rows: (' #  ##  ', ' # ##   ', ' ####   ', ' ###    ', ' ####   ', ' # ##   ', ' #  ##  ', ' #  ##  ')),
    (Ch: 'L'; Rows: (' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' #####  ')),
    (Ch: 'M'; Rows: ('### ##  ', '### ##  ', '######  ', '######  ', '#### #  ', '##   #  ', '##   #  ', '##   #  ')),
    (Ch: 'N'; Rows: (' ##  #  ', ' ##  #  ', ' ##  #  ', ' ### #  ', ' # ###  ', ' # ###  ', ' #  ##  ', ' #  ##  ')),
    (Ch: 'O'; Rows: ('  ###   ', ' ## ##  ', ' #  ##  ', '##  ##  ', '##  ##  ', ' #  ##  ', ' ## ##  ', '  ###   ')),
    (Ch: 'P'; Rows: (' ####   ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ####   ', ' ##     ', ' ##     ', ' ##     ')),
    (Ch: 'Q'; Rows: ('  ###   ', ' ## ##  ', ' #  ##  ', '##  ##  ', '##  ##  ', ' #  ##  ', ' ## ##  ', '  ###   ')),
    (Ch: 'R'; Rows: (' ####   ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' ####   ', ' # ##   ', ' #  ##  ', ' #   #  ')),
    (Ch: 'S'; Rows: ('  ###   ', ' ##     ', ' ##     ', ' ###    ', '  ####  ', '    ##  ', ' #  ##  ', ' ####   ')),
    (Ch: 'T'; Rows: ('######  ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ')),
    (Ch: 'U'; Rows: ('##  ##  ', '##  ##  ', '##  ##  ', '##  ##  ', '##  ##  ', ' #  ##  ', ' ## ##  ', ' ####   ')),
    (Ch: 'V'; Rows: ('##   #  ', ' #  ##  ', ' #  ##  ', ' ## ##  ', ' ## #   ', '  ###   ', '  ###   ', '  ###   ')),
    (Ch: 'W'; Rows: ('##   ## ', '##   ## ', '#### #  ', '#### #  ', '######  ', ' ## ##  ', ' ## ##  ', ' ## ##  ')),
    (Ch: 'X'; Rows: ('##  ##  ', ' ## ##  ', '  ###   ', '  ##    ', '  ###   ', '  ###   ', ' ## ##  ', '##  ##  ')),
    (Ch: 'Y'; Rows: ('##   #  ', ' ## ##  ', ' ## #   ', '  ###   ', '  ##    ', '  ##    ', '  ##    ', '  ##    ')),
    (Ch: 'Z'; Rows: (' #####  ', '    ##  ', '   ##   ', '   ##   ', '  ##    ', ' ##     ', ' ##     ', ' #####  ')),
    (Ch: '0'; Rows: ('  ###   ', ' ## ##  ', ' #  ##  ', ' #  ##  ', ' #####  ', ' #  ##  ', ' ## ##  ', '  ###   ')),
    (Ch: '1'; Rows: (' ###    ', '   #    ', '   #    ', '   #    ', '   #    ', '   #    ', '   #    ', ' #####  ')),
    (Ch: '2'; Rows: (' ####   ', '    ##  ', '    ##  ', '    #   ', '   ##   ', '  ##    ', ' ##     ', ' #####  ')),
    (Ch: '3'; Rows: (' ####   ', '    ##  ', '    ##  ', '  ###   ', '    ##  ', '    ##  ', '    ##  ', ' ####   ')),
    (Ch: '4'; Rows: ('   ##   ', '   ##   ', '  ###   ', ' ## #   ', ' #  #   ', '######  ', '    #   ', '    #   ')),
    (Ch: '5'; Rows: (' ####   ', ' #      ', ' #      ', ' ####   ', '    ##  ', '    ##  ', '    ##  ', ' ####   ')),
    (Ch: '6'; Rows: ('  ####  ', ' ##     ', ' #      ', ' ####   ', ' ## ##  ', ' #  ##  ', ' ## ##  ', '  ###   ')),
    (Ch: '7'; Rows: (' #####  ', '    ##  ', '   ##   ', '   ##   ', '   ##   ', '  ##    ', '  ##    ', '  #     ')),
    (Ch: '8'; Rows: ('  ###   ', ' ## ##  ', ' ## ##  ', '  ###   ', ' ## ##  ', ' #  ##  ', ' ## ##  ', '  ###   ')),
    (Ch: '9'; Rows: (' ####   ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #####  ', '    ##  ', '    #   ', ' ####   '))
  );

function FindGlyph(c: Char): TGlyphRows;
var
  i: Integer;
  blank: TGlyphRows;
  row: Integer;
begin
  c := UpCase(c);
  for i := 0 to FONT_SIZE_COUNT - 1 do
    if FONT[i].Ch = c then
    begin
      Result := FONT[i].Rows;
      Exit;
    end;
  // unknown character (punctuation, etc.) -> blank glyph of same size
  for row := 0 to GLYPH_H - 1 do
    blank[row] := StringOfChar(' ', GLYPH_W);
  Result := blank;
end;

procedure PrintBanner(const Text: string);
var
  row, i: Integer;
  line: string;
  glyph: TGlyphRows;
  kerningGap: string;
begin
  kerningGap := StringOfChar(' ', KERNING);
  for row := 0 to GLYPH_H - 1 do
  begin
    line := '';
    for i := 1 to Length(Text) do
    begin
      if Text[i] = ' ' then
        line := line + StringOfChar(' ', GLYPH_W + KERNING)
      else
      begin
        glyph := FindGlyph(Text[i]);
        line := line + glyph[row] + kerningGap;
      end;
    end;
    WriteLn(line);
  end;
end;

var
  i: Integer;
  input: string;
begin
  if ParamCount = 0 then
  begin
    WriteLn('Usage: fancywords <text>');
    Halt(1);
  end;

  input := ParamStr(1);
  for i := 2 to ParamCount do
    input := input + ' ' + ParamStr(i);

  PrintBanner(input);
end.
