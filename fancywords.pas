program fancywords;

{Turns into object pascal mode}
{$mode objfpc}{$H+}

function CharToIndex_inc(ch: char): integer;
begin
  if (ch >= 'a') and (ch <= 'z') then
    CharToIndex_inc := Ord(ch) - Ord('a')
  else
    CharToIndex_inc := -1;
end;

const
  FONT_SMALL_H = 17;

type
  TLetter = array[0..FONT_SMALL_H - 1] of string;

  TFontChar = record
     Code: Cardinal;
     W: Integer;
     Rows: TLetter;   // rows
  end;

{$I fontdata_small.inc}
{$I fontdata_big.inc}

var
  UserRequest: string;
  i: integer;
  j: integer;
  CharactersNum: integer;
  indexer: integer;

begin
  readln(UserRequest);
  CharactersNum := length(UserRequest);

  for i := 0 to FONT_SMALL_H - 1 do
  begin
    for j := 0 to CharactersNum - 1 do
    begin
      indexer := CharToIndex_inc(UserRequest[j + 1]);
      if indexer >= 0 then
        write(FONT_SMALL[indexer].Rows[i]);
    end;
    writeln;
  end;


end.
