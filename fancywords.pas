program fancywords;
{Turns into object pascal mode}
{$mode objfpc}{$H+}

uses
  SysUtils; { for IntToHex, GetEnvironmentVariable }

const
  FONT_HEIGHT = 6; { Height of each glyph in rows }
  CHAR_MIN = $20;
  CHAR_MAX = $7E;
  DEFAULT_SCREEN_WIDTH = 80; { Fallback if $COLUMNS is not set }

type
  TLetter = array[0..FONT_HEIGHT - 1] of string;
  TFontChar = record
     Code: Cardinal;
     W: Integer;
     Rows: TLetter;
  end;
  TLine = array[0..FONT_HEIGHT - 1] of string; { one wrapped line, all rows }

{$I fontdata.inc} { include ASCII Figlet-Like Letters (FONT, FONT_COUNT) }

function CharToIndex_inc(ch: char): integer; { Translate char to ASCII number }
begin
  if (Ord(ch) >= CHAR_MIN) and (Ord(ch) <= CHAR_MAX) then
    CharToIndex_inc := Ord(ch) - CHAR_MIN
  else
    CharToIndex_inc := -1;
end;

procedure ValidateFont; { Sanity-check font data at startup: catches width/index bugs early }
var
  i, j, w, expectedCode: Integer;
begin
  expectedCode := CHAR_MIN;
  for i := 0 to FONT_COUNT - 1 do
  begin
    if FONT[i].Code <> Cardinal(expectedCode) then
    begin
      writeln('FONT error: gap or misorder at index ', i,
              ' expected code $', IntToHex(expectedCode, 4),
              ' got $', IntToHex(FONT[i].Code, 4));
      Halt(1);
    end;

    w := Length(FONT[i].Rows[0]);
    if FONT[i].W <> w then
    begin
      writeln('FONT error: W mismatch for code $',
              IntToHex(FONT[i].Code, 4),
              ' (declared ', FONT[i].W, ', actual ', w, ')');
      Halt(1);
    end;

    for j := 1 to FONT_HEIGHT - 1 do
      if Length(FONT[i].Rows[j]) <> w then
      begin
        writeln('FONT error: row ', j, ' width mismatch for code $',
                IntToHex(FONT[i].Code, 4));
        Halt(1);
      end;

    Inc(expectedCode);
  end;
end;

function GetScreenWidth: Integer; { Read $COLUMNS if set, else fall back to default }
var
  colsEnv: string;
  colsVal: Integer;
begin
  colsEnv := GetEnvironmentVariable('COLUMNS');
  if (colsEnv <> '') and TryStrToInt(colsEnv, colsVal) and (colsVal > 0) then
    GetScreenWidth := colsVal
  else
    GetScreenWidth := DEFAULT_SCREEN_WIDTH;
end;

function WordWidth(const w: string): Integer; { Rendered ASCII width of a word }
var
  k, idx, total: Integer;
begin
  total := 0;
  for k := 1 to Length(w) do
  begin
    idx := CharToIndex_inc(w[k]);
    if idx >= 0 then
      total := total + FONT[idx].W;
  end;
  WordWidth := total;
end;

procedure FlushLine(var line: TLine; var lineWidth: Integer); { Print buffered line and reset it }
var
  r: Integer;
begin
  if lineWidth = 0 then
    Exit;
  for r := 0 to FONT_HEIGHT - 1 do
    writeln(line[r]);
  for r := 0 to FONT_HEIGHT - 1 do
    line[r] := '';
  lineWidth := 0;
end;

procedure AppendChar(var line: TLine; ch: char); { Append one glyph's rows to the buffered line }
var
  idx, r: Integer;
begin
  idx := CharToIndex_inc(ch);
  if idx < 0 then Exit;
  for r := 0 to FONT_HEIGHT - 1 do
    line[r] := line[r] + FONT[idx].Rows[r];
end;

procedure PrintWrapped(const s: string; screenWidth: Integer); { figlet-style word wrap }
var
  line: TLine;
  lineWidth: Integer;
  words: TStringArray;
  wIndex, k: Integer;
  spaceW: Integer;
begin
  for k := 0 to FONT_HEIGHT - 1 do
    line[k] := '';
  lineWidth := 0;
  spaceW := FONT[CharToIndex_inc(' ')].W;

  words := s.Split(' ');
  for wIndex := 0 to Length(words) - 1 do
  begin
    if words[wIndex] = '' then Continue; { collapse repeated spaces }

    { word (plus a leading space, if the line already has content) doesn't fit -> wrap }
    if (lineWidth > 0) and
       (lineWidth + spaceW + WordWidth(words[wIndex]) > screenWidth) then
      FlushLine(line, lineWidth);

    if lineWidth > 0 then
    begin
      AppendChar(line, ' ');
      lineWidth := lineWidth + spaceW;
    end;

    for k := 1 to Length(words[wIndex]) do
    begin
      AppendChar(line, words[wIndex][k]);
      lineWidth := lineWidth + FONT[CharToIndex_inc(words[wIndex][k])].W;
    end;
  end;

  FlushLine(line, lineWidth);
end;

var
  UserRequest: string;

begin
  ValidateFont;

  readln(UserRequest);
  PrintWrapped(UserRequest, GetScreenWidth);
end.
