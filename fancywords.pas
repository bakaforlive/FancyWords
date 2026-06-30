program FancyWords;

{$mode objfpc}{$H+}

{ FancyWords - a tiny figlet clone, built from scratch.
  Font glyphs come from auto-generated .inc files (see gen_pas6.py),
  trimmed to each glyph's real ink width - this is OUR font data,
  not a copy of any figlet .flf font file.
  Covers: A-Z, a-z, 0-9, basic + extended punctuation, and the full
  Cyrillic alphabet (А-Я, а-я, Ё, ё). Input is decoded from UTF-8 so
  multi-byte characters (Cyrillic) render correctly.
  Three font heights are available: Small, Standard (default), Big -
  selectable via -s/--size.

  Font data lives in separate files so this file stays readable:
    fontdata_small.inc
    fontdata_standard.inc
    fontdata_big.inc
  All three must be present in the same directory when compiling. }

uses
  SysUtils, termio;

const
  MAX_GLYPH_W = 10;
  MAX_GLYPH_H = 17;
  KERNING = 1;   // columns of blank space between letters
  SPACE_W = 3;   // width used for a literal space character

type
  TColorMode = (cmNone, cmFixed, cmRainbow);
  TSizeMode = (szSmall, szStandard, szBig);

type
  TGlyphRows = array[0..MAX_GLYPH_H - 1] of string[MAX_GLYPH_W];
  TFontChar = record
    Code: Cardinal;    // Unicode code point
    W: Integer;        // actual ink width of this glyph (proportional)
    Rows: TGlyphRows;  // only the first <font height> rows are meaningful
  end;

{$I fontdata_small.inc}
{$I fontdata_standard.inc}
{$I fontdata_big.inc}

{ Decodes a UTF-8 byte string into an array of Unicode code points,
  so multi-byte characters (e.g. Cyrillic) are handled as single
  logical characters instead of being split into raw bytes. }
function DecodeUTF8(const s: string): specialize TArray<Cardinal>;
var
  res: array of Cardinal;
  count, i, len: Integer;
  b0, b1, b2, b3: Byte;
  cp: Cardinal;
begin
  SetLength(res, Length(s));
  count := 0;
  i := 1;
  len := Length(s);
  while i <= len do
  begin
    b0 := Byte(s[i]);
    if b0 < $80 then
    begin
      cp := b0;
      Inc(i);
    end
    else if (b0 and $E0) = $C0 then
    begin
      if i + 1 <= len then
      begin
        b1 := Byte(s[i + 1]);
        cp := ((b0 and $1F) shl 6) or (b1 and $3F);
        Inc(i, 2);
      end
      else
      begin
        cp := b0;
        Inc(i);
      end;
    end
    else if (b0 and $F0) = $E0 then
    begin
      if i + 2 <= len then
      begin
        b1 := Byte(s[i + 1]);
        b2 := Byte(s[i + 2]);
        cp := ((b0 and $0F) shl 12) or ((b1 and $3F) shl 6) or (b2 and $3F);
        Inc(i, 3);
      end
      else
      begin
        cp := b0;
        Inc(i);
      end;
    end
    else if (b0 and $F8) = $F0 then
    begin
      if i + 3 <= len then
      begin
        b1 := Byte(s[i + 1]);
        b2 := Byte(s[i + 2]);
        b3 := Byte(s[i + 3]);
        cp := ((b0 and $07) shl 18) or ((b1 and $3F) shl 12) or
              ((b2 and $3F) shl 6) or (b3 and $3F);
        Inc(i, 4);
      end
      else
      begin
        cp := b0;
        Inc(i);
      end;
    end
    else
    begin
      cp := b0;
      Inc(i);
    end;
    res[count] := cp;
    Inc(count);
  end;
  SetLength(res, count);
  Result := res;
end;

function FindGlyph(const FontArr: array of TFontChar; code: Cardinal; out W: Integer): TGlyphRows;
var
  i: Integer;
  blank: TGlyphRows;
  row: Integer;
begin
  for i := 0 to High(FontArr) do
    if FontArr[i].Code = code then
    begin
      Result := FontArr[i].Rows;
      W := FontArr[i].W;
      Exit;
    end;
  // unknown character -> blank glyph
  for row := 0 to MAX_GLYPH_H - 1 do
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

type
  TStringArray = array of string;

{ Renders the banner into an array of plain (uncolored, unbordered)
  text lines, using whichever font table matches the requested size.
  FontH is the real glyph height for that font - only that many rows
  are emitted, even though TGlyphRows itself is sized to the tallest
  font available. }
function BuildLines(const codepoints: specialize TArray<Cardinal>;
  const FontArr: array of TFontChar; FontH: Integer): TStringArray;
var
  row, i, w: Integer;
  line: string;
  glyph: TGlyphRows;
  lines: TStringArray;
begin
  SetLength(lines, FontH);
  for row := 0 to FontH - 1 do
  begin
    line := '';
    for i := 0 to High(codepoints) do
    begin
      if codepoints[i] = Ord(' ') then
        line := line + StringOfChar(' ', SPACE_W + KERNING)
      else
      begin
        glyph := FindGlyph(FontArr, codepoints[i], w);
        line := line + Copy(glyph[row], 1, w) + StringOfChar(' ', KERNING);
      end;
    end;
    lines[row] := line;
  end;
  Result := lines;
end;

procedure PrintColored(const lines: array of string; ColorMode: TColorMode; FixedColor: string; Bordered: Boolean);
const
  ESC = #27;
  RAINBOW: array[0..5] of string = ('31', '33', '32', '36', '34', '35');
var
  row, col: Integer;
  outLine: string;
  colorIdx: Integer;
  segColor: string;
  inGlyph: Boolean;
  maxLen, padLen: Integer;
begin
  maxLen := 0;
  for row := 0 to High(lines) do
    if Length(lines[row]) > maxLen then
      maxLen := Length(lines[row]);

  for row := 0 to High(lines) do
  begin
    outLine := '';
    colorIdx := 0;
    inGlyph := False;
    if ColorMode = cmNone then
      outLine := lines[row]
    else
    begin
      for col := 1 to Length(lines[row]) do
      begin
        if lines[row][col] <> ' ' then
        begin
          if not inGlyph then
          begin
            if ColorMode = cmRainbow then
            begin
              segColor := RAINBOW[colorIdx mod Length(RAINBOW)];
              outLine := outLine + ESC + '[' + segColor + 'm';
            end
            else
              outLine := outLine + ESC + '[' + FixedColor + 'm';
            inGlyph := True;
          end;
          outLine := outLine + lines[row][col];
        end
        else
        begin
          if inGlyph then
          begin
            outLine := outLine + ESC + '[0m';
            inGlyph := False;
            if ColorMode = cmRainbow then
              Inc(colorIdx);
          end;
          outLine := outLine + ' ';
        end;
      end;
      if inGlyph then
        outLine := outLine + ESC + '[0m';
    end;

    if Bordered then
    begin
      padLen := maxLen - Length(lines[row]);
      WriteLn('| ' + outLine + StringOfChar(' ', padLen) + ' |');
    end
    else
      WriteLn(outLine);
  end;
end;

function IsPiped: Boolean;
begin
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
  WriteLn('  fancywords <text>                  render text given as arguments');
  WriteLn('  echo "text" | fancywords           render text piped via stdin');
  WriteLn('  fancywords -s <size> <text>        choose font height');
  WriteLn('  fancywords -c <color> <text>       colored output');
  WriteLn('  fancywords -c rainbow <text>       rainbow output (color per letter)');
  WriteLn('  fancywords -b <text>               draw a border around the banner');
  WriteLn('  fancywords -h | --help             show this help');
  WriteLn;
  WriteLn('Sizes: small, standard (default), big');
  WriteLn('Colors: red, green, yellow, blue, magenta, cyan, white, rainbow');
  WriteLn('Supports: A-Z a-z 0-9, Cyrillic А-Я а-я, and common punctuation.');
end;

var
  i, argIdx, maxLineLen: Integer;
  input: string;
  colorMode: TColorMode;
  sizeMode: TSizeMode;
  fixedColor: string;
  border: Boolean;
  args: array of string;
  codepoints: specialize TArray<Cardinal>;
  lines: TStringArray;
begin
  colorMode := cmNone;
  sizeMode := szStandard;
  fixedColor := '';
  border := False;
  SetLength(args, 0);

  i := 1;
  while i <= ParamCount do
  begin
    if (ParamStr(i) = '-h') or (ParamStr(i) = '--help') then
    begin
      PrintUsage;
      Halt(0);
    end
    else if (ParamStr(i) = '-b') or (ParamStr(i) = '--border') then
    begin
      border := True;
    end
    else if (ParamStr(i) = '-s') or (ParamStr(i) = '--size') then
    begin
      Inc(i);
      if i > ParamCount then
      begin
        WriteLn('Error: -s/--size requires a value');
        Halt(1);
      end;
      case LowerCase(ParamStr(i)) of
        'small': sizeMode := szSmall;
        'standard': sizeMode := szStandard;
        'big': sizeMode := szBig;
      else
        begin
          WriteLn('Unknown size: ', ParamStr(i));
          WriteLn('Available: small, standard, big');
          Halt(1);
        end;
      end;
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

  codepoints := DecodeUTF8(input);

  case sizeMode of
    szSmall:    lines := BuildLines(codepoints, FONT_SMALL, FONT_SMALL_H);
    szStandard: lines := BuildLines(codepoints, FONT_STANDARD, FONT_STANDARD_H);
    szBig:      lines := BuildLines(codepoints, FONT_BIG, FONT_BIG_H);
  end;

  if border then
  begin
    maxLineLen := 0;
    for i := 0 to High(lines) do
      if Length(lines[i]) > maxLineLen then
        maxLineLen := Length(lines[i]);
    WriteLn('+' + StringOfChar('-', maxLineLen + 2) + '+');
    PrintColored(lines, colorMode, fixedColor, True);
    WriteLn('+' + StringOfChar('-', maxLineLen + 2) + '+');
  end
  else
    PrintColored(lines, colorMode, fixedColor, False);
end.
