program FancyWords;

{$mode objfpc}{$H+}

{ FancyWords - a tiny figlet clone, built from scratch.
  Font glyphs in this file were auto-generated from a bitmap font
  (see gen_pas.py) into a simple block style - this is OUR font data,
  not a copy of any figlet .flf font file.
  Covers: A-Z, a-z, 0-9, and basic punctuation: . , ! ? : ; - ' " ( ) }

uses
  SysUtils, termio;

const
  GLYPH_H = 12;
  GLYPH_W = 8;
  KERNING = 1; // columns of blank space between letters

type
  TColorMode = (cmNone, cmFixed, cmRainbow);

type
  TGlyphRows = array[0..GLYPH_H - 1] of string[GLYPH_W];
  TFontChar = record
    Ch: Char;
    Rows: TGlyphRows;
  end;

const
  FONT_SIZE_COUNT = 73;
  FONT: array[0..FONT_SIZE_COUNT - 1] of TFontChar = (
    (Ch: 'A'; Rows: ('        ', '        ', '  ##    ', '  ###   ', '  ###   ', ' ## #   ', ' ## ##  ', ' #####  ', ' #  ##  ', '##   #  ', '        ', '        ')),
    (Ch: 'B'; Rows: ('        ', '        ', ' ####   ', ' #  ##  ', ' #  ##  ', ' ####   ', ' #  ##  ', ' #   #  ', ' #  ##  ', ' ####   ', '        ', '        ')),
    (Ch: 'C'; Rows: ('        ', '        ', '  ###   ', ' ##  #  ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##  #  ', '  ###   ', '        ', '        ')),
    (Ch: 'D'; Rows: ('        ', '        ', ' ####   ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' ####   ', '        ', '        ')),
    (Ch: 'E'; Rows: ('        ', '        ', ' #####  ', ' ##     ', ' ##     ', ' #####  ', ' ##     ', ' ##     ', ' ##     ', ' #####  ', '        ', '        ')),
    (Ch: 'F'; Rows: ('        ', '        ', ' #####  ', ' ##     ', ' ##     ', ' #####  ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', '        ', '        ')),
    (Ch: 'G'; Rows: ('        ', '        ', '  ###   ', ' ##  #  ', ' ##     ', ' #      ', ' #  ##  ', ' ##  #  ', ' ##  #  ', '  ####  ', '        ', '        ')),
    (Ch: 'H'; Rows: ('        ', '        ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #####  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #  ##  ', '        ', '        ')),
    (Ch: 'I'; Rows: ('        ', '        ', ' #####  ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', ' #####  ', '        ', '        ')),
    (Ch: 'J'; Rows: ('        ', '        ', '  ###   ', '    #   ', '    #   ', '    #   ', '    #   ', '    #   ', '   ##   ', ' ####   ', '        ', '        ')),
    (Ch: 'K'; Rows: ('        ', '        ', ' #  ##  ', ' # ##   ', ' ####   ', ' ###    ', ' ####   ', ' # ##   ', ' #  ##  ', ' #  ##  ', '        ', '        ')),
    (Ch: 'L'; Rows: ('        ', '        ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', ' #####  ', '        ', '        ')),
    (Ch: 'M'; Rows: ('        ', '        ', '### ##  ', '### ##  ', '######  ', '######  ', '#### #  ', '##   #  ', '##   #  ', '##   #  ', '        ', '        ')),
    (Ch: 'N'; Rows: ('        ', '        ', ' ##  #  ', ' ##  #  ', ' ##  #  ', ' ### #  ', ' # ###  ', ' # ###  ', ' #  ##  ', ' #  ##  ', '        ', '        ')),
    (Ch: 'O'; Rows: ('        ', '        ', '  ###   ', ' ## ##  ', ' #  ##  ', '##  ##  ', '##  ##  ', ' #  ##  ', ' ## ##  ', '  ###   ', '        ', '        ')),
    (Ch: 'P'; Rows: ('        ', '        ', ' ####   ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ####   ', ' ##     ', ' ##     ', ' ##     ', '        ', '        ')),
    (Ch: 'Q'; Rows: ('        ', '        ', '  ###   ', ' ## ##  ', ' #  ##  ', '##  ##  ', '##  ##  ', ' #  ##  ', ' ## ##  ', '  ###   ', '    #   ', '        ')),
    (Ch: 'R'; Rows: ('        ', '        ', ' ####   ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' ####   ', ' # ##   ', ' #  ##  ', ' #   #  ', '        ', '        ')),
    (Ch: 'S'; Rows: ('        ', '        ', '  ###   ', ' ##     ', ' ##     ', ' ###    ', '  ####  ', '    ##  ', ' #  ##  ', ' ####   ', '        ', '        ')),
    (Ch: 'T'; Rows: ('        ', '        ', '######  ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '        ', '        ')),
    (Ch: 'U'; Rows: ('        ', '        ', '##  ##  ', '##  ##  ', '##  ##  ', '##  ##  ', '##  ##  ', ' #  ##  ', ' ## ##  ', ' ####   ', '        ', '        ')),
    (Ch: 'V'; Rows: ('        ', '        ', '##   #  ', ' #  ##  ', ' #  ##  ', ' ## ##  ', ' ## #   ', '  ###   ', '  ###   ', '  ###   ', '        ', '        ')),
    (Ch: 'W'; Rows: ('        ', '        ', '##   ## ', '##   ## ', '#### #  ', '#### #  ', '######  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', '        ', '        ')),
    (Ch: 'X'; Rows: ('        ', '        ', '##  ##  ', ' ## ##  ', '  ###   ', '  ##    ', '  ###   ', '  ###   ', ' ## ##  ', '##  ##  ', '        ', '        ')),
    (Ch: 'Y'; Rows: ('        ', '        ', '##   #  ', ' ## ##  ', ' ## #   ', '  ###   ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '        ', '        ')),
    (Ch: 'Z'; Rows: ('        ', '        ', ' #####  ', '    ##  ', '   ##   ', '   ##   ', '  ##    ', ' ##     ', ' ##     ', ' #####  ', '        ', '        ')),
    (Ch: 'a'; Rows: ('        ', '        ', '        ', '        ', ' ####   ', '    ##  ', ' #####  ', ' ## ##  ', ' #  ##  ', ' #####  ', '        ', '        ')),
    (Ch: 'b'; Rows: ('        ', ' #      ', ' #      ', ' #      ', ' ####   ', ' ## ##  ', ' #  ##  ', ' #  ##  ', ' ## ##  ', ' ####   ', '        ', '        ')),
    (Ch: 'c'; Rows: ('        ', '        ', '        ', '        ', '  ####  ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', '  ####  ', '        ', '        ')),
    (Ch: 'd'; Rows: ('        ', '    ##  ', '    ##  ', '    ##  ', ' #####  ', ' ## ##  ', '##  ##  ', '##  ##  ', ' ## ##  ', ' #####  ', '        ', '        ')),
    (Ch: 'e'; Rows: ('        ', '        ', '        ', '        ', '  ###   ', ' #  ##  ', ' #####  ', ' #      ', ' ##     ', '  ####  ', '        ', '        ')),
    (Ch: 'f'; Rows: ('        ', '   ###  ', '  ##    ', '  ##    ', ' #####  ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '        ', '        ')),
    (Ch: 'g'; Rows: ('        ', '        ', '        ', '        ', ' #####  ', ' ## ##  ', ' #  ##  ', ' #  ##  ', ' ## ##  ', ' #####  ', '    ##  ', ' ####   ')),
    (Ch: 'h'; Rows: ('        ', ' ##     ', ' ##     ', ' ##     ', ' ####   ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', '        ', '        ')),
    (Ch: 'i'; Rows: ('        ', '   #    ', '   #    ', '        ', ' ###    ', '   #    ', '   #    ', '   #    ', '   #    ', ' #####  ', '        ', '        ')),
    (Ch: 'j'; Rows: ('        ', '   ##   ', '   ##   ', '        ', ' ####   ', '   ##   ', '   ##   ', '   ##   ', '   ##   ', '   ##   ', '   ##   ', ' ###    ')),
    (Ch: 'k'; Rows: ('        ', ' ##     ', ' ##     ', ' ##     ', ' ## ##  ', ' ####   ', ' ###    ', ' ####   ', ' ## ##  ', ' ## ##  ', '        ', '        ')),
    (Ch: 'l'; Rows: ('        ', '####    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '   ###  ', '        ', '        ')),
    (Ch: 'm'; Rows: ('        ', '        ', '        ', '        ', '######  ', '## # #  ', '## # #  ', '## # #  ', '## # #  ', '## # #  ', '        ', '        ')),
    (Ch: 'n'; Rows: ('        ', '        ', '        ', '        ', ' ####   ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', '        ', '        ')),
    (Ch: 'o'; Rows: ('        ', '        ', '        ', '        ', '  ###   ', ' ## ##  ', ' #  ##  ', ' #  ##  ', ' ## ##  ', '  ###   ', '        ', '        ')),
    (Ch: 'p'; Rows: ('        ', '        ', '        ', '        ', ' ####   ', ' ## ##  ', ' #  ##  ', ' #  ##  ', ' ## ##  ', ' ####   ', ' #      ', ' #      ')),
    (Ch: 'q'; Rows: ('        ', '        ', '        ', '        ', ' #####  ', ' ## ##  ', '##  ##  ', '##  ##  ', ' ## ##  ', ' #####  ', '    ##  ', '    ##  ')),
    (Ch: 'r'; Rows: ('        ', '        ', '        ', '        ', ' #####  ', ' ###    ', ' ##     ', ' ##     ', ' ##     ', ' ##     ', '        ', '        ')),
    (Ch: 's'; Rows: ('        ', '        ', '        ', '        ', '  ###   ', ' ##     ', ' ####   ', '  ####  ', '    ##  ', ' ####   ', '        ', '        ')),
    (Ch: 't'; Rows: ('        ', '        ', '  ##    ', '  ##    ', ' #####  ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '   ###  ', '        ', '        ')),
    (Ch: 'u'; Rows: ('        ', '        ', '        ', '        ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' ## ##  ', ' #####  ', '        ', '        ')),
    (Ch: 'v'; Rows: ('        ', '        ', '        ', '        ', ' #  ##  ', ' ## ##  ', ' ## #   ', ' ## #   ', '  ###   ', '  ###   ', '        ', '        ')),
    (Ch: 'w'; Rows: ('        ', '        ', '        ', '        ', '#    ## ', '##   #  ', '#### #  ', ' #####  ', ' ## ##  ', ' ## ##  ', '        ', '        ')),
    (Ch: 'x'; Rows: ('        ', '        ', '        ', '        ', ' ## ##  ', ' ####   ', '  ##    ', '  ###   ', ' ####   ', ' #  ##  ', '        ', '        ')),
    (Ch: 'y'; Rows: ('        ', '        ', '        ', '        ', '##  ##  ', ' ## ##  ', ' ## #   ', '  ###   ', '  ###   ', '  ##    ', '  ##    ', ' ##     ')),
    (Ch: 'z'; Rows: ('        ', '        ', '        ', '        ', ' #####  ', '    ##  ', '   ##   ', '  ##    ', ' ##     ', ' #####  ', '        ', '        ')),
    (Ch: '0'; Rows: ('        ', '        ', '  ###   ', ' ## ##  ', ' #  ##  ', ' #  ##  ', ' #####  ', ' #  ##  ', ' ## ##  ', '  ###   ', '        ', '        ')),
    (Ch: '1'; Rows: ('        ', '        ', ' ###    ', '   #    ', '   #    ', '   #    ', '   #    ', '   #    ', '   #    ', ' #####  ', '        ', '        ')),
    (Ch: '2'; Rows: ('        ', '        ', ' ####   ', '    ##  ', '    ##  ', '    #   ', '   ##   ', '  ##    ', ' ##     ', ' #####  ', '        ', '        ')),
    (Ch: '3'; Rows: ('        ', '        ', ' ####   ', '    ##  ', '    ##  ', '  ###   ', '    ##  ', '    ##  ', '    ##  ', ' ####   ', '        ', '        ')),
    (Ch: '4'; Rows: ('        ', '        ', '   ##   ', '   ##   ', '  ###   ', ' ## #   ', ' #  #   ', '######  ', '    #   ', '    #   ', '        ', '        ')),
    (Ch: '5'; Rows: ('        ', '        ', ' ####   ', ' #      ', ' #      ', ' ####   ', '    ##  ', '    ##  ', '    ##  ', ' ####   ', '        ', '        ')),
    (Ch: '6'; Rows: ('        ', '        ', '  ####  ', ' ##     ', ' #      ', ' ####   ', ' ## ##  ', ' #  ##  ', ' ## ##  ', '  ###   ', '        ', '        ')),
    (Ch: '7'; Rows: ('        ', '        ', ' #####  ', '    ##  ', '   ##   ', '   ##   ', '   ##   ', '  ##    ', '  ##    ', '  #     ', '        ', '        ')),
    (Ch: '8'; Rows: ('        ', '        ', '  ###   ', ' ## ##  ', ' ## ##  ', '  ###   ', ' ## ##  ', ' #  ##  ', ' ## ##  ', '  ###   ', '        ', '        ')),
    (Ch: '9'; Rows: ('        ', '        ', ' ####   ', ' #  ##  ', ' #  ##  ', ' #  ##  ', ' #####  ', '    ##  ', '    #   ', ' ####   ', '        ', '        ')),
    (Ch: '.'; Rows: ('        ', '        ', '        ', '        ', '        ', '        ', '        ', '        ', '  ##    ', '  ##    ', '        ', '        ')),
    (Ch: ','; Rows: ('        ', '        ', '        ', '        ', '        ', '        ', '        ', '        ', '  ##    ', '  ##    ', '  ##    ', '  #     ')),
    (Ch: '!'; Rows: ('        ', '        ', '   #    ', '   #    ', '   #    ', '   #    ', '   #    ', '        ', '   #    ', '   #    ', '        ', '        ')),
    (Ch: '?'; Rows: ('        ', '        ', '  ###   ', ' #  ##  ', '    #   ', '   #    ', '  ##    ', '        ', '  ##    ', '  ##    ', '        ', '        ')),
    (Ch: ':'; Rows: ('        ', '        ', '        ', '        ', '  ##    ', '  ##    ', '        ', '        ', '  ##    ', '  ##    ', '        ', '        ')),
    (Ch: ';'; Rows: ('        ', '        ', '        ', '        ', '  ##    ', '  ##    ', '        ', '        ', '  ##    ', '  ##    ', '  ##    ', '  #     ')),
    (Ch: '-'; Rows: ('        ', '        ', '        ', '        ', '        ', '        ', '  ###   ', '  ###   ', '        ', '        ', '        ', '        ')),
    (Ch: ''''; Rows: ('        ', '        ', '   #    ', '   #    ', '   #    ', '        ', '        ', '        ', '        ', '        ', '        ', '        ')),
    (Ch: '"'; Rows: ('        ', '        ', ' ## #   ', ' ## #   ', ' ## #   ', '        ', '        ', '        ', '        ', '        ', '        ', '        ')),
    (Ch: '('; Rows: ('        ', '   ##   ', '   #    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '  ##    ', '   #    ', '   ##   ', '        ')),
    (Ch: ')'; Rows: ('        ', '  #     ', '  ##    ', '   #    ', '   #    ', '   ##   ', '   ##   ', '   #    ', '   #    ', '  ##    ', '  #     ', '        '))
  );

function FindGlyph(c: Char): TGlyphRows;
var
  i: Integer;
  blank: TGlyphRows;
  row: Integer;
begin
  // case-sensitive lookup now - upper and lower case have distinct glyphs
  for i := 0 to FONT_SIZE_COUNT - 1 do
    if FONT[i].Ch = c then
    begin
      Result := FONT[i].Rows;
      Exit;
    end;
  // unknown character -> blank glyph of the same size
  for row := 0 to GLYPH_H - 1 do
    blank[row] := StringOfChar(' ', GLYPH_W);
  Result := blank;
end;

function ColorCode(const name: string): string;
var
  n: string;
begin
  n := LowerCase(name);
  if n = 'red' then Result := '31'
  else if n = 'green' then Result := '32'
  else if n = 'yellow' then Result := '33'
  else if n = 'blue' then Result := '34'
  else if n = 'magenta' then Result := '35'
  else if n = 'cyan' then Result := '36'
  else if n = 'white' then Result := '37'
  else Result := '';
end;

procedure PrintBanner(const Text: string; ColorMode: TColorMode; FixedColor: string);
const
  ESC = #27;
  RAINBOW: array[0..5] of string = ('31', '33', '32', '36', '34', '35');
var
  row, i, colorIdx: Integer;
  line: string;
  glyph: TGlyphRows;
  kerningGap: string;
  segColor: string;
begin
  kerningGap := StringOfChar(' ', KERNING);
  for row := 0 to GLYPH_H - 1 do
  begin
    line := '';
    colorIdx := 0;
    for i := 1 to Length(Text) do
    begin
      if Text[i] = ' ' then
        line := line + StringOfChar(' ', GLYPH_W + KERNING)
      else
      begin
        glyph := FindGlyph(Text[i]);
        case ColorMode of
          cmFixed:
            line := line + ESC + '[' + FixedColor + 'm' + glyph[row] + ESC + '[0m' + kerningGap;
          cmRainbow:
            begin
              segColor := RAINBOW[colorIdx mod Length(RAINBOW)];
              line := line + ESC + '[' + segColor + 'm' + glyph[row] + ESC + '[0m' + kerningGap;
              Inc(colorIdx);
            end;
        else
          line := line + glyph[row] + kerningGap;
        end;
      end;
    end;
    WriteLn(line);
  end;
end;

function IsPiped: Boolean;
begin
  // IsATTY returns 1 for an interactive terminal, 0 if redirected/piped
  Result := IsATTY(Input) = 0;
end;

function ReadAllStdin: string;
var
  line: string;
begin
  Result := '';
  while not Eof(Input) do
  begin
    ReadLn(line);
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + line;
  end;
end;

procedure PrintUsage;
begin
  WriteLn('FancyWords - a tiny figlet clone written in Pascal');
  WriteLn;
  WriteLn('Usage:');
  WriteLn('  fancywords <text>              render text given as arguments');
  WriteLn('  echo "text" | fancywords       render text piped via stdin');
  WriteLn('  fancywords -c <color> <text>   colored output');
  WriteLn('  fancywords -c rainbow <text>   rainbow output (color per letter)');
  WriteLn('  fancywords -h | --help         show this help');
  WriteLn;
  WriteLn('Colors: red, green, yellow, blue, magenta, cyan, white, rainbow');
end;

var
  i, argIdx: Integer;
  input: string;
  colorMode: TColorMode;
  fixedColor: string;
  args: array of string;
begin
  colorMode := cmNone;
  fixedColor := '';
  SetLength(args, 0);

  i := 1;
  while i <= ParamCount do
  begin
    if (ParamStr(i) = '-h') or (ParamStr(i) = '--help') then
    begin
      PrintUsage;
      Halt(0);
    end
    else if (ParamStr(i) = '-c') or (ParamStr(i) = '--color') then
    begin
      Inc(i);
      if i > ParamCount then
      begin
        WriteLn('Error: -c/--color requires a value');
        Halt(1);
      end;
      if LowerCase(ParamStr(i)) = 'rainbow' then
        colorMode := cmRainbow
      else
      begin
        fixedColor := ColorCode(ParamStr(i));
        if fixedColor = '' then
        begin
          WriteLn('Unknown color: ', ParamStr(i));
          WriteLn('Available: red, green, yellow, blue, magenta, cyan, white, rainbow');
          Halt(1);
        end;
        colorMode := cmFixed;
      end;
    end
    else
    begin
      SetLength(args, Length(args) + 1);
      args[High(args)] := ParamStr(i);
    end;
    Inc(i);
  end;

  if Length(args) = 0 then
  begin
    if IsPiped then
      input := ReadAllStdin
    else
    begin
      PrintUsage;
      Halt(1);
    end;
  end
  else
  begin
    input := args[0];
    for argIdx := 1 to High(args) do
      input := input + ' ' + args[argIdx];
  end;

  if Trim(input) = '' then
  begin
    PrintUsage;
    Halt(1);
  end;

  PrintBanner(input, colorMode, fixedColor);
end.
