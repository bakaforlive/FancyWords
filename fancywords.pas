program FancyWords;

{$mode objfpc}{$H+}

{ FancyWords - a tiny figlet clone, built from scratch.
  Font glyphs in this file were auto-generated from a bitmap font
  (see gen_pas3.py) into a proportional block style, trimmed to each
  glyph's real ink width so letters sit close together instead of
  floating in fixed-width boxes - this is OUR font data, not a copy
  of any figlet .flf font file.
  Covers: A-Z, a-z, 0-9, and basic punctuation: . , ! ? : ; - ' " ( ) }

uses
  SysUtils, termio;

const
  GLYPH_H = 12;
  MAX_GLYPH_W = 7;
  KERNING = 1; // columns of blank space between letters
  SPACE_W = 3; // width used for a literal space character

type
  TColorMode = (cmNone, cmFixed, cmRainbow);

type
  TGlyphRows = array[0..GLYPH_H - 1] of string[MAX_GLYPH_W];
  TFontChar = record
    Ch: Char;
    W: Integer;       // actual ink width of this glyph (proportional)
    Rows: TGlyphRows;
  end;

const
  FONT_SIZE_COUNT = 73;
  FONT: array[0..FONT_SIZE_COUNT - 1] of TFontChar = (
    (Ch: 'A'; W: 6; Rows: ('      ', '      ', '##    ', '###   ', '###   ', '## #  ', '## ## ', '######', '#  ## ', '#   #1', '      ', '      ')),
    (Ch: 'B'; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#### ', '#  ##', '#   #', '#  ##', '#### ', '     ', '     ')),
    (Ch: 'C'; W: 6; Rows: ('      ', '      ', ' ###  ', '##  # ', '##    ', '##    ', '##    ', '##    ', '##  # ', ' ###  ', '      ', '      ')),
    (Ch: 'D'; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '#### ', '     ', '     ')),
    (Ch: 'E'; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '#####', '##   ', '##   ', '##   ', '#####', '     ', '     ')),
    (Ch: 'F'; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '#####', '##   ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Ch: 'G'; W: 6; Rows: ('      ', '      ', ' ###  ', '##  # ', '##    ', '#     ', '#  ## ', '##  # ', '##  # ', ' #### ', '      ', '      ')),
    (Ch: 'H'; W: 5; Rows: ('     ', '     ', '#  ##', '#  ##', '#  ##', '#####', '#  ##', '#  ##', '#  ##', '#  ##', '     ', '     ')),
    (Ch: 'I'; W: 5; Rows: ('     ', '     ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '#####', '     ', '     ')),
    (Ch: 'J'; W: 6; Rows: ('      ', '      ', ' ###  ', '   #  ', '   #  ', '   #  ', '   #  ', '   #  ', '  ##  ', '####  ', '      ', '      ')),
    (Ch: 'K'; W: 5; Rows: ('     ', '     ', '#  ##', '# ## ', '#### ', '###  ', '#### ', '# ## ', '#  ##', '#  ##', '     ', '     ')),
    (Ch: 'L'; W: 5; Rows: ('     ', '     ', '##   ', '##   ', '##   ', '##   ', '##   ', '##   ', '##   ', '#####', '     ', '     ')),
    (Ch: 'M'; W: 6; Rows: ('      ', '      ', '## ## ', '## ## ', '######', '######', '#### #', '##   #', '##   #', '##   #', '      ', '      ')),
    (Ch: 'N'; W: 6; Rows: ('      ', '      ', '##  # ', '##  # ', '##  # ', '### # ', '# ### ', '# ### ', '#  ## ', '#  ## ', '      ', '      ')),
    (Ch: 'O'; W: 6; Rows: ('      ', '      ', ' ###  ', '## ## ', '#  ## ', '#  ## ', '#  ## ', '#  ## ', '## ## ', ' ###  ', '      ', '      ')),
    (Ch: 'P'; W: 5; Rows: ('     ', '     ', '#### ', '## ##', '## ##', '## ##', '#### ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Ch: 'Q'; W: 6; Rows: ('      ', '      ', ' ###  ', '## ## ', '#  ## ', '#  ## ', '#  ## ', '#  ## ', '## ## ', ' ###  ', '   #  ', '      ')),
    (Ch: 'R'; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#  ##', '#### ', '# ## ', '#  ##', '#   #', '     ', '     ')),
    (Ch: 'S'; W: 5; Rows: ('     ', '     ', ' ### ', '##   ', '##   ', '###  ', ' ####', '   ##', '#  ##', '#### ', '     ', '     ')),
    (Ch: 'T'; W: 6; Rows: ('      ', '      ', '######', ' ##   ', ' ##   ', ' ##   ', ' ##   ', ' ##   ', ' ##   ', ' ##   ', '      ', '      ')),
    (Ch: 'U'; W: 6; Rows: ('      ', '      ', '#  ## ', '#  ## ', '#  ## ', '#  ## ', '#  ## ', ' #  ##', ' ## ##', ' #### ', '      ', '      ')),
    (Ch: 'V'; W: 6; Rows: ('      ', '      ', '##   #', ' #  ##', ' #  ##', ' ## ##', ' ## # ', '  ### ', '  ### ', '  ### ', '      ', '      ')),
    (Ch: 'W'; W: 7; Rows: ('       ', '       ', '##   ##', '##   ##', '#### # ', '#### # ', '#######', ' ## ## ', ' ## ## ', ' ## ## ', '       ', '       ')),
    (Ch: 'X'; W: 6; Rows: ('      ', '      ', '#  ## ', ' ## # ', '  ### ', '  ##  ', '  ### ', '  ### ', ' ## # ', '#  ## ', '      ', '      ')),
    (Ch: 'Y'; W: 6; Rows: ('      ', '      ', '##   #', ' ## ##', ' ## # ', '  ### ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '      ', '      ')),
    (Ch: 'Z'; W: 5; Rows: ('     ', '     ', '#####', '   ##', '  ## ', '  ## ', ' ##  ', '##   ', '##   ', '#####', '     ', '     ')),
    (Ch: 'a'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '   ##', '#####', '## ##', '#  ##', '#####', '     ', '     ')),
    (Ch: 'b'; W: 5; Rows: ('     ', '#    ', '#    ', '#    ', '#### ', '## ##', '#  ##', '#  ##', '## ##', '#### ', '     ', '     ')),
    (Ch: 'c'; W: 4; Rows: ('    ', '    ', '    ', '    ', ' ###', '##  ', '##  ', '##  ', '##  ', ' ###', '    ', '    ')),
    (Ch: 'd'; W: 5; Rows: ('   ##', '   ##', '   ##', '   ##', '#####', '## ##', '#  ##', '#  ##', '## ##', '#####', '     ', '     ')),
    (Ch: 'e'; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '#  ##', '#####', '#    ', '##   ', ' ####', '     ', '     ')),
    (Ch: 'f'; W: 5; Rows: ('  ###', ' ##  ', ' ##  ', ' ##  ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '     ', '     ')),
    (Ch: 'g'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '## ##', '#  ##', '#  ##', '## ##', '#####', '   ##', '#### ')),
    (Ch: 'h'; W: 5; Rows: ('#    ', '#    ', '#    ', '#### ', '## ##', '## ##', '## ##', '## ##', '## ##', '     ', '     ', '     ')),
    (Ch: 'i'; W: 4; Rows: ('    ', ' #  ', ' #  ', '    ', '### ', ' #  ', ' #  ', ' #  ', ' #  ', '####', '    ', '    ')),
    (Ch: 'j'; W: 5; Rows: ('  ## ', '  ## ', '     ', '#### ', '  ## ', '  ## ', '  ## ', '  ## ', '  ## ', '  ## ', '### ', '     ')),
    (Ch: 'k'; W: 5; Rows: ('#    ', '#    ', '#    ', '# ## ', '####', '###  ', '####', '# ## ', '# ## ', '     ', '     ', '     ')),
    (Ch: 'l'; W: 4; Rows: ('####', '  # ', '  # ', '  # ', '  # ', '  # ', '  # ', '  # ', '  # ', ' ###', '    ', '    ')),
    (Ch: 'm'; W: 6; Rows: ('      ', '      ', '      ', '      ', '######', '## # #', '## # #', '## # #', '## # #', '## # #', '      ', '      ')),
    (Ch: 'n'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '## ##', '## ##', '## ##', '## ##', '## ##', '     ', '     ')),
    (Ch: 'o'; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '## ##', '#  ##', '#  ##', '## ##', ' ### ', '     ', '     ')),
    (Ch: 'p'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '## ##', '#  ##', '#  ##', '## ##', '#### ', '#    ', '#    ')),
    (Ch: 'q'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '## ##', '#  ##', '#  ##', '## ##', '#####', '   ##', '   ##')),
    (Ch: 'r'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '###  ', '##   ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Ch: 's'; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '##   ', '#### ', ' ####', '   ##', '#### ', '     ', '     ')),
    (Ch: 't'; W: 5; Rows: ('     ', ' ##  ', ' ##  ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '  ###', '     ', '     ', '     ')),
    (Ch: 'u'; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '## ##', '## ##', '## ##', '## ##', '#####', '     ', '     ')),
    (Ch: 'v'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#  ##', '## ##', '## # ', '## # ', ' ### ', ' ### ', '     ', '     ')),
    (Ch: 'w'; W: 7; Rows: ('       ', '       ', '       ', '       ', '#    ##', '##   # ', '#### # ', ' ##### ', ' ## ## ', ' ## ## ', '       ', '       ')),
    (Ch: 'x'; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '#### ', ' ##  ', ' ### ', '#### ', '#  ##', '     ', '     ')),
    (Ch: 'y'; W: 6; Rows: ('      ', '      ', '      ', '      ', '#  ## ', ' ## ##', ' ## # ', '  ### ', '  ### ', '  ##  ', '  ##  ', ' ##   ')),
    (Ch: 'z'; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '   ##', '  ## ', ' ##  ', '##   ', '#####', '     ', '     ')),
    (Ch: '0'; W: 6; Rows: ('      ', '      ', ' ###  ', '## ## ', '#  ## ', '#  ## ', '#####  ', '#  ## ', '## ## ', ' ###  ', '      ', '      ')),
    (Ch: '1'; W: 5; Rows: ('     ', '     ', '###  ', '  #  ', '  #  ', '  #  ', '  #  ', '  #  ', '  #  ', '#####', '     ', '     ')),
    (Ch: '2'; W: 5; Rows: ('     ', '     ', '#### ', '   ##', '   ##', '   # ', '  ## ', ' ##  ', '##   ', '#####', '     ', '     ')),
    (Ch: '3'; W: 5; Rows: ('     ', '     ', '#### ', '   ##', '   ##', ' ### ', '   ##', '   ##', '   ##', '#### ', '     ', '     ')),
    (Ch: '4'; W: 6; Rows: ('      ', '      ', '  ##  ', '  ##  ', ' ###  ', '## #  ', '#  #  ', '######', '   #  ', '   #  ', '      ', '      ')),
    (Ch: '5'; W: 5; Rows: ('     ', '     ', '#### ', '#    ', '#    ', '#### ', '   ##', '   ##', '   ##', '#### ', '     ', '     ')),
    (Ch: '6'; W: 6; Rows: ('      ', '      ', ' #### ', '##    ', '#     ', '#### ', '## ## ', '#  ## ', '## ## ', ' ###  ', '      ', '      ')),
    (Ch: '7'; W: 5; Rows: ('     ', '     ', '#####', '   ##', '  ## ', '  ## ', '  ## ', ' ##  ', ' ##  ', ' #   ', '     ', '     ')),
    (Ch: '8'; W: 6; Rows: ('      ', '      ', ' ###  ', '## ## ', '## ## ', ' ###  ', '## ## ', '#  ## ', '## ## ', ' ###  ', '      ', '      ')),
    (Ch: '9'; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#  ##', '#####', '   ##', '   # ', '#### ', '     ', '     ')),
    (Ch: '.'; W: 2; Rows: ('  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '##', '##', '  ', '  ')),
    (Ch: ','; W: 2; Rows: ('  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '##', '##', '##', '# ')),
    (Ch: '!'; W: 1; Rows: ('1', '1', '#', '#', '#', '#', '#', ' ', '#', '#', ' ', ' ')),
    (Ch: '?'; W: 5; Rows: ('     ', '     ', ' ### ', '#  ##', '   # ', '  #  ', ' ##  ', '     ', ' ##  ', ' ##  ', '     ', '     ')),
    (Ch: ':'; W: 2; Rows: ('  ', '  ', '  ', '  ', '##', '##', '  ', '  ', '##', '##', '  ', '  ')),
    (Ch: ';'; W: 2; Rows: ('  ', '  ', '  ', '  ', '##', '##', '  ', '  ', '##', '##', '##', '# ')),
    (Ch: '-'; W: 3; Rows: ('   ', '   ', '   ', '   ', '   ', '   ', '###', '###', '   ', '   ', '   ', '   ')),
    (Ch: ''''; W: 1; Rows: ('1', '1', '#', '#', '#', '1', '1', '1', '1', '1', '1', '1')),
    (Ch: '"'; W: 5; Rows: ('     ', '     ', '## # ', '## # ', '## # ', '     ', '     ', '     ', '     ', '     ', '     ', '     ')),
    (Ch: '('; W: 4; Rows: ('   #', '   #', '  # ', ' #  ', ' #  ', ' #  ', ' #  ', ' #  ', ' #  ', '  # ', '   #', '    ')),
    (Ch: ')'; W: 4; Rows: ('#   ', '#   ', ' #  ', '  # ', '  # ', '  # ', '  # ', '  # ', '  # ', ' #  ', '#   ', '    '))
  );

function FindGlyph(c: Char; out W: Integer): TGlyphRows;
var
  i: Integer;
  blank: TGlyphRows;
  row: Integer;
begin
  // case-sensitive lookup - upper and lower case have distinct glyphs
  for i := 0 to FONT_SIZE_COUNT - 1 do
    if FONT[i].Ch = c then
    begin
      Result := FONT[i].Rows;
      W := FONT[i].W;
      Exit;
    end;
  // unknown character -> blank glyph
  for row := 0 to GLYPH_H - 1 do
    blank[row] := StringOfChar(' ', SPACE_W);
  Result := blank;
  W := SPACE_W;
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
  row, i, colorIdx, w: Integer;
  line: string;
  glyph: TGlyphRows;
  kerningGap: string;
  segColor: string;
  glyphRow: string;
begin
  kerningGap := StringOfChar(' ', KERNING);
  for row := 0 to GLYPH_H - 1 do
  begin
    line := '';
    colorIdx := 0;
    for i := 1 to Length(Text) do
    begin
      if Text[i] = ' ' then
        line := line + StringOfChar(' ', SPACE_W + KERNING)
      else
      begin
        glyph := FindGlyph(Text[i], w);
        glyphRow := Copy(glyph[row], 1, w);
        case ColorMode of
          cmFixed:
            line := line + ESC + '[' + FixedColor + 'm' + glyphRow + ESC + '[0m' + kerningGap;
          cmRainbow:
            begin
              segColor := RAINBOW[colorIdx mod Length(RAINBOW)];
              line := line + ESC + '[' + segColor + 'm' + glyphRow + ESC + '[0m' + kerningGap;
              Inc(colorIdx);
            end;
        else
          line := line + glyphRow + kerningGap;
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
