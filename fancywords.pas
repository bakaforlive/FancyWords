program FancyWords;

{$mode objfpc}{$H+}

{ FancyWords - a tiny figlet clone, built from scratch.
  Font glyphs in this file were auto-generated from a bitmap font
  (see gen_pas4.py) into a proportional block style, trimmed to each
  glyph's real ink width - this is OUR font data, not a copy of any
  figlet .flf font file.
  Covers: A-Z, a-z, 0-9, basic + extended punctuation, and the full
  Cyrillic alphabet (А-Я, а-я, Ё, ё). Input is decoded from UTF-8 so
  multi-byte characters (Cyrillic) render correctly. }

uses
  SysUtils, termio;

const
  GLYPH_H = 12;
  MAX_GLYPH_W = 7;
  KERNING = 1;   // columns of blank space between letters
  SPACE_W = 3;   // width used for a literal space character

type
  TColorMode = (cmNone, cmFixed, cmRainbow);

type
  TGlyphRows = array[0..GLYPH_H - 1] of string[MAX_GLYPH_W];
  TFontChar = record
    Code: Cardinal;    // Unicode code point
    W: Integer;        // actual ink width of this glyph (proportional)
    Rows: TGlyphRows;
  end;

const
  FONT_SIZE_COUNT = 158;
  FONT: array[0..FONT_SIZE_COUNT - 1] of TFontChar = (
    (Code: $0041; W: 6; Rows: ('      ', '      ', '  ##  ', '  ### ', '  ### ', ' ## # ', ' ## ##', ' #####', ' #  ##', '##   #', '      ', '      ')),
    (Code: $0042; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#### ', '#  ##', '#   #', '#  ##', '#### ', '     ', '     ')),
    (Code: $0043; W: 5; Rows: ('     ', '     ', ' ### ', '##  #', '##   ', '##   ', '##   ', '##   ', '##  #', ' ### ', '     ', '     ')),
    (Code: $0044; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '#### ', '     ', '     ')),
    (Code: $0045; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '#####', '##   ', '##   ', '##   ', '#####', '     ', '     ')),
    (Code: $0046; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '#####', '##   ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Code: $0047; W: 5; Rows: ('     ', '     ', ' ### ', '##  #', '##   ', '#    ', '#  ##', '##  #', '##  #', ' ####', '     ', '     ')),
    (Code: $0048; W: 5; Rows: ('     ', '     ', '#  ##', '#  ##', '#  ##', '#####', '#  ##', '#  ##', '#  ##', '#  ##', '     ', '     ')),
    (Code: $0049; W: 5; Rows: ('     ', '     ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '#####', '     ', '     ')),
    (Code: $004A; W: 4; Rows: ('    ', '    ', ' ###', '   #', '   #', '   #', '   #', '   #', '  ##', '####', '    ', '    ')),
    (Code: $004B; W: 5; Rows: ('     ', '     ', '#  ##', '# ## ', '#### ', '###  ', '#### ', '# ## ', '#  ##', '#  ##', '     ', '     ')),
    (Code: $004C; W: 5; Rows: ('     ', '     ', '##   ', '##   ', '##   ', '##   ', '##   ', '##   ', '##   ', '#####', '     ', '     ')),
    (Code: $004D; W: 6; Rows: ('      ', '      ', '### ##', '### ##', '######', '######', '#### #', '##   #', '##   #', '##   #', '      ', '      ')),
    (Code: $004E; W: 5; Rows: ('     ', '     ', '##  #', '##  #', '##  #', '### #', '# ###', '# ###', '#  ##', '#  ##', '     ', '     ')),
    (Code: $004F; W: 6; Rows: ('      ', '      ', '  ### ', ' ## ##', ' #  ##', '##  ##', '##  ##', ' #  ##', ' ## ##', '  ### ', '      ', '      ')),
    (Code: $0050; W: 5; Rows: ('     ', '     ', '#### ', '## ##', '## ##', '## ##', '#### ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Code: $0051; W: 6; Rows: ('      ', '      ', '  ### ', ' ## ##', ' #  ##', '##  ##', '##  ##', ' #  ##', ' ## ##', '  ### ', '    # ', '      ')),
    (Code: $0052; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#  ##', '#### ', '# ## ', '#  ##', '#   #', '     ', '     ')),
    (Code: $0053; W: 5; Rows: ('     ', '     ', ' ### ', '##   ', '##   ', '###  ', ' ####', '   ##', '#  ##', '#### ', '     ', '     ')),
    (Code: $0054; W: 6; Rows: ('      ', '      ', '######', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '      ', '      ')),
    (Code: $0055; W: 6; Rows: ('      ', '      ', '##  ##', '##  ##', '##  ##', '##  ##', '##  ##', ' #  ##', ' ## ##', ' #### ', '      ', '      ')),
    (Code: $0056; W: 6; Rows: ('      ', '      ', '##   #', ' #  ##', ' #  ##', ' ## ##', ' ## # ', '  ### ', '  ### ', '  ### ', '      ', '      ')),
    (Code: $0057; W: 7; Rows: ('       ', '       ', '##   ##', '##   ##', '#### # ', '#### # ', '###### ', ' ## ## ', ' ## ## ', ' ## ## ', '       ', '       ')),
    (Code: $0058; W: 6; Rows: ('      ', '      ', '##  ##', ' ## ##', '  ### ', '  ##  ', '  ### ', '  ### ', ' ## ##', '##  ##', '      ', '      ')),
    (Code: $0059; W: 6; Rows: ('      ', '      ', '##   #', ' ## ##', ' ## # ', '  ### ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '      ', '      ')),
    (Code: $005A; W: 5; Rows: ('     ', '     ', '#####', '   ##', '  ## ', '  ## ', ' ##  ', '##   ', '##   ', '#####', '     ', '     ')),
    (Code: $0061; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '   ##', '#####', '## ##', '#  ##', '#####', '     ', '     ')),
    (Code: $0062; W: 5; Rows: ('     ', '#    ', '#    ', '#    ', '#### ', '## ##', '#  ##', '#  ##', '## ##', '#### ', '     ', '     ')),
    (Code: $0063; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ####', '##   ', '##   ', '##   ', '##   ', ' ####', '     ', '     ')),
    (Code: $0064; W: 6; Rows: ('      ', '    ##', '    ##', '    ##', ' #####', ' ## ##', '##  ##', '##  ##', ' ## ##', ' #####', '      ', '      ')),
    (Code: $0065; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '#  ##', '#####', '#    ', '##   ', ' ####', '     ', '     ')),
    (Code: $0066; W: 5; Rows: ('     ', '  ###', ' ##  ', ' ##  ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '     ', '     ')),
    (Code: $0067; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '## ##', '#  ##', '#  ##', '## ##', '#####', '   ##', '#### ')),
    (Code: $0068; W: 5; Rows: ('     ', '##   ', '##   ', '##   ', '#### ', '## ##', '## ##', '## ##', '## ##', '## ##', '     ', '     ')),
    (Code: $0069; W: 5; Rows: ('     ', '  #  ', '  #  ', '     ', '###  ', '  #  ', '  #  ', '  #  ', '  #  ', '#####', '     ', '     ')),
    (Code: $006A; W: 4; Rows: ('    ', '  ##', '  ##', '    ', '####', '  ##', '  ##', '  ##', '  ##', '  ##', '  ##', '### ')),
    (Code: $006B; W: 5; Rows: ('     ', '##   ', '##   ', '##   ', '## ##', '#### ', '###  ', '#### ', '## ##', '## ##', '     ', '     ')),
    (Code: $006C; W: 6; Rows: ('      ', '####  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '   ###', '      ', '      ')),
    (Code: $006D; W: 6; Rows: ('      ', '      ', '      ', '      ', '######', '## # #', '## # #', '## # #', '## # #', '## # #', '      ', '      ')),
    (Code: $006E; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '## ##', '## ##', '## ##', '## ##', '## ##', '     ', '     ')),
    (Code: $006F; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '## ##', '#  ##', '#  ##', '## ##', ' ### ', '     ', '     ')),
    (Code: $0070; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '## ##', '#  ##', '#  ##', '## ##', '#### ', '#    ', '#    ')),
    (Code: $0071; W: 6; Rows: ('      ', '      ', '      ', '      ', ' #####', ' ## ##', '##  ##', '##  ##', ' ## ##', ' #####', '    ##', '    ##')),
    (Code: $0072; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '###  ', '##   ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Code: $0073; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '##   ', '#### ', ' ####', '   ##', '#### ', '     ', '     ')),
    (Code: $0074; W: 5; Rows: ('     ', '     ', ' ##  ', ' ##  ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '  ###', '     ', '     ')),
    (Code: $0075; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '## ##', '## ##', '## ##', '## ##', '#####', '     ', '     ')),
    (Code: $0076; W: 5; Rows: ('     ', '     ', '     ', '     ', '#  ##', '## ##', '## # ', '## # ', ' ### ', ' ### ', '     ', '     ')),
    (Code: $0077; W: 7; Rows: ('       ', '       ', '       ', '       ', '#    ##', '##   # ', '#### # ', ' ##### ', ' ## ## ', ' ## ## ', '       ', '       ')),
    (Code: $0078; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '#### ', ' ##  ', ' ### ', '#### ', '#  ##', '     ', '     ')),
    (Code: $0079; W: 6; Rows: ('      ', '      ', '      ', '      ', '##  ##', ' ## ##', ' ## # ', '  ### ', '  ### ', '  ##  ', '  ##  ', ' ##   ')),
    (Code: $007A; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '   ##', '  ## ', ' ##  ', '##   ', '#####', '     ', '     ')),
    (Code: $0030; W: 5; Rows: ('     ', '     ', ' ### ', '## ##', '#  ##', '#  ##', '#####', '#  ##', '## ##', ' ### ', '     ', '     ')),
    (Code: $0031; W: 5; Rows: ('     ', '     ', '###  ', '  #  ', '  #  ', '  #  ', '  #  ', '  #  ', '  #  ', '#####', '     ', '     ')),
    (Code: $0032; W: 5; Rows: ('     ', '     ', '#### ', '   ##', '   ##', '   # ', '  ## ', ' ##  ', '##   ', '#####', '     ', '     ')),
    (Code: $0033; W: 5; Rows: ('     ', '     ', '#### ', '   ##', '   ##', ' ### ', '   ##', '   ##', '   ##', '#### ', '     ', '     ')),
    (Code: $0034; W: 6; Rows: ('      ', '      ', '   ## ', '   ## ', '  ### ', ' ## # ', ' #  # ', '######', '    # ', '    # ', '      ', '      ')),
    (Code: $0035; W: 5; Rows: ('     ', '     ', '#### ', '#    ', '#    ', '#### ', '   ##', '   ##', '   ##', '#### ', '     ', '     ')),
    (Code: $0036; W: 5; Rows: ('     ', '     ', ' ####', '##   ', '#    ', '#### ', '## ##', '#  ##', '## ##', ' ### ', '     ', '     ')),
    (Code: $0037; W: 5; Rows: ('     ', '     ', '#####', '   ##', '  ## ', '  ## ', '  ## ', ' ##  ', ' ##  ', ' #   ', '     ', '     ')),
    (Code: $0038; W: 5; Rows: ('     ', '     ', ' ### ', '## ##', '## ##', ' ### ', '## ##', '#  ##', '## ##', ' ### ', '     ', '     ')),
    (Code: $0039; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#  ##', '#####', '   ##', '   # ', '#### ', '     ', '     ')),
    (Code: $002E; W: 2; Rows: ('  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '##', '##', '  ', '  ')),
    (Code: $002C; W: 2; Rows: ('  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ', '##', '##', '##', '# ')),
    (Code: $0021; W: 1; Rows: (' ', ' ', '#', '#', '#', '#', '#', ' ', '#', '#', ' ', ' ')),
    (Code: $003F; W: 5; Rows: ('     ', '     ', ' ### ', '#  ##', '   # ', '  #  ', ' ##  ', '     ', ' ##  ', ' ##  ', '     ', '     ')),
    (Code: $003A; W: 2; Rows: ('  ', '  ', '  ', '  ', '##', '##', '  ', '  ', '##', '##', '  ', '  ')),
    (Code: $003B; W: 2; Rows: ('  ', '  ', '  ', '  ', '##', '##', '  ', '  ', '##', '##', '##', '# ')),
    (Code: $002D; W: 3; Rows: ('   ', '   ', '   ', '   ', '   ', '   ', '###', '###', '   ', '   ', '   ', '   ')),
    (Code: $0027; W: 1; Rows: (' ', ' ', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ')),
    (Code: $0022; W: 4; Rows: ('    ', '    ', '## #', '## #', '## #', '    ', '    ', '    ', '    ', '    ', '    ', '    ')),
    (Code: $0028; W: 3; Rows: ('   ', ' ##', ' # ', '## ', '## ', '## ', '## ', '## ', '## ', ' # ', ' ##', '   ')),
    (Code: $0029; W: 3; Rows: ('   ', '#  ', '## ', ' # ', ' # ', ' ##', ' ##', ' # ', ' # ', '## ', '#  ', '   ')),
    (Code: $0040; W: 6; Rows: ('      ', '      ', '  ### ', ' #   #', '## ###', '# ## #', '# #  #', '# ## #', '## ###', ' ##  #', '  ####', '      ')),
    (Code: $0023; W: 7; Rows: ('       ', '       ', '  ## # ', '  # ## ', ' ######', '  # #  ', ' ## #  ', '###### ', ' # ##  ', ' # #   ', '       ', '       ')),
    (Code: $0024; W: 5; Rows: ('     ', '     ', '  #  ', ' ### ', '###  ', '###  ', ' ####', '  ###', '# ###', ' ### ', '  #  ', '  #  ')),
    (Code: $0025; W: 7; Rows: ('       ', '       ', ' ##    ', '# ##   ', ' ##  # ', '    #  ', '  #    ', '    ## ', '   # ##', '    ## ', '       ', '       ')),
    (Code: $005E; W: 5; Rows: ('     ', '     ', ' ##  ', '#### ', '#  ##', '     ', '     ', '     ', '     ', '     ', '     ', '     ')),
    (Code: $0026; W: 7; Rows: ('       ', '       ', '  ###  ', ' ## #  ', ' ##    ', ' ###   ', '#### ##', '## ### ', '##  ## ', ' ##### ', '       ', '       ')),
    (Code: $002A; W: 5; Rows: ('     ', '     ', '  #  ', '# # #', ' ### ', ' ### ', '# # #', '  #  ', '     ', '     ', '     ', '     ')),
    (Code: $002B; W: 6; Rows: ('      ', '      ', '      ', '      ', '   #  ', '   #  ', '######', '   #  ', '   #  ', '      ', '      ', '      ')),
    (Code: $003D; W: 6; Rows: ('      ', '      ', '      ', '      ', '      ', '######', '      ', '######', '      ', '      ', '      ', '      ')),
    (Code: $002F; W: 5; Rows: ('     ', '     ', '    #', '   # ', '   # ', '  #  ', '  #  ', ' ##  ', ' #   ', '##   ', '#    ', '     ')),
    (Code: $005C; W: 5; Rows: ('     ', '     ', '#    ', '##   ', ' #   ', ' ##  ', '  #  ', '  #  ', '   # ', '   # ', '    #', '     ')),
    (Code: $003C; W: 5; Rows: ('     ', '     ', '     ', '     ', '    #', ' ####', '##   ', '##   ', ' ####', '    #', '     ', '     ')),
    (Code: $003E; W: 6; Rows: ('      ', '      ', '      ', '      ', '##    ', ' ###  ', '   ###', '   ###', ' ###  ', '##    ', '      ', '      ')),
    (Code: $005B; W: 3; Rows: ('   ', '###', '## ', '## ', '## ', '## ', '## ', '## ', '## ', '## ', '###', '   ')),
    (Code: $005D; W: 2; Rows: ('  ', '##', ' #', ' #', ' #', ' #', ' #', ' #', ' #', ' #', '##', '  ')),
    (Code: $007B; W: 5; Rows: ('     ', '  ###', '  #  ', '  #  ', '  #  ', ' ##  ', '###  ', ' ##  ', '  #  ', '  #  ', '  ###', '     ')),
    (Code: $007D; W: 5; Rows: ('     ', '###  ', ' ##  ', ' ##  ', '  #  ', '  #  ', '  ###', '  #  ', ' ##  ', ' ##  ', '###  ', '     ')),
    (Code: $007E; W: 5; Rows: ('     ', '     ', '     ', '     ', '     ', '     ', '###  ', '  ###', '     ', '     ', '     ', '     ')),
    (Code: $005F; W: 3; Rows: ('   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ')),
    (Code: $0410; W: 6; Rows: ('      ', '      ', '  ##  ', '  ### ', '  ### ', ' ## # ', ' ## ##', ' #####', ' #  ##', '##   #', '      ', '      ')),
    (Code: $0411; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '#### ', '## ##', '## ##', '## ##', '#### ', '     ', '     ')),
    (Code: $0412; W: 5; Rows: ('     ', '     ', '#### ', '#  ##', '#  ##', '#### ', '#  ##', '#   #', '#  ##', '#### ', '     ', '     ')),
    (Code: $0413; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '##   ', '##   ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Code: $0414; W: 6; Rows: ('      ', '      ', ' #####', ' ## ##', ' ## ##', ' ## ##', ' ## ##', ' ## ##', ' ## ##', '######', '##   #', '##   #')),
    (Code: $0415; W: 5; Rows: ('     ', '     ', '#####', '##   ', '##   ', '#####', '##   ', '##   ', '##   ', '#####', '     ', '     ')),
    (Code: $0401; W: 5; Rows: (' # # ', '     ', '#####', '##   ', '##   ', '#####', '##   ', '##   ', '##   ', '#####', '     ', '     ')),
    (Code: $0416; W: 6; Rows: ('      ', '      ', '## # #', ' #####', ' #####', ' #### ', ' #####', ' #####', '## # #', '## # #', '      ', '      ')),
    (Code: $0417; W: 5; Rows: ('     ', '     ', '#### ', '   ##', '   ##', ' ### ', '   ##', '   ##', '   ##', '#### ', '     ', '     ')),
    (Code: $0418; W: 5; Rows: ('     ', '     ', '#  ##', '#  ##', '# ###', '# ###', '### #', '##  #', '##  #', '##  #', '     ', '     ')),
    (Code: $0419; W: 5; Rows: (' ### ', '     ', '#  ##', '#  ##', '# ###', '# ###', '### #', '##  #', '##  #', '##  #', '     ', '     ')),
    (Code: $041A; W: 5; Rows: ('     ', '     ', '#  ##', '# ## ', '#### ', '###  ', '#### ', '# ## ', '#  ##', '#  ##', '     ', '     ')),
    (Code: $041B; W: 6; Rows: ('      ', '      ', ' #####', ' ## ##', ' ## ##', ' ## ##', ' ## ##', ' ## ##', ' ## ##', '##  ##', '      ', '      ')),
    (Code: $041C; W: 6; Rows: ('      ', '      ', '### ##', '### ##', '######', '######', '#### #', '##   #', '##   #', '##   #', '      ', '      ')),
    (Code: $041D; W: 5; Rows: ('     ', '     ', '#  ##', '#  ##', '#  ##', '#####', '#  ##', '#  ##', '#  ##', '#  ##', '     ', '     ')),
    (Code: $041E; W: 6; Rows: ('      ', '      ', '  ### ', ' ## ##', ' #  ##', '##  ##', '##  ##', ' #  ##', ' ## ##', '  ### ', '      ', '      ')),
    (Code: $041F; W: 5; Rows: ('     ', '     ', '#####', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '#  ##', '     ', '     ')),
    (Code: $0420; W: 5; Rows: ('     ', '     ', '#### ', '## ##', '## ##', '## ##', '#### ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Code: $0421; W: 5; Rows: ('     ', '     ', ' ### ', '##  #', '##   ', '##   ', '##   ', '##   ', '##  #', ' ### ', '     ', '     ')),
    (Code: $0422; W: 6; Rows: ('      ', '      ', '######', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '  ##  ', '      ', '      ')),
    (Code: $0423; W: 6; Rows: ('      ', '      ', '##   #', ' ## ##', ' ## ##', '  ### ', '  ### ', '   #  ', '  ##  ', ' ##   ', '      ', '      ')),
    (Code: $0424; W: 6; Rows: ('      ', '      ', '   #  ', ' #### ', ' ### #', '## # #', '## # #', ' ### #', ' #### ', '   #  ', '      ', '      ')),
    (Code: $0425; W: 6; Rows: ('      ', '      ', '##  ##', ' ## ##', '  ### ', '  ##  ', '  ### ', '  ### ', ' ## ##', '##  ##', '      ', '      ')),
    (Code: $0426; W: 6; Rows: ('      ', '      ', '##  ##', '##  ##', '##  ##', '##  ##', '##  ##', '##  ##', '##  ##', '######', '     #', '     #')),
    (Code: $0427; W: 6; Rows: ('      ', '      ', '##  ##', '##  ##', ' #  ##', ' #####', '    ##', '    ##', '    ##', '    ##', '      ', '      ')),
    (Code: $0428; W: 6; Rows: ('      ', '      ', '## # #', '## # #', '## # #', '## # #', '## # #', '## # #', '## # #', '######', '      ', '      ')),
    (Code: $0429; W: 7; Rows: ('       ', '       ', '## # # ', '## # # ', '## # # ', '## # # ', '## # # ', '## # # ', '## # # ', '#######', '     ##', '     ##')),
    (Code: $042A; W: 6; Rows: ('      ', '      ', '###   ', ' ##   ', ' ##   ', ' #### ', ' ## ##', ' ##  #', ' ## ##', ' #### ', '      ', '      ')),
    (Code: $042B; W: 6; Rows: ('      ', '      ', '##   #', '##   #', '##   #', '###  #', '#### #', '## ###', '## # #', '#### #', '      ', '      ')),
    (Code: $042C; W: 5; Rows: ('     ', '     ', '#    ', '#    ', '#    ', '#### ', '#  ##', '#  ##', '#  ##', '#### ', '     ', '     ')),
    (Code: $042D; W: 5; Rows: ('     ', '     ', '#### ', '# ## ', '   ##', '#####', '#####', '   ##', '# ## ', '#### ', '     ', '     ')),
    (Code: $042E; W: 7; Rows: ('       ', '       ', '## ### ', '## # # ', '#### ##', '#### ##', '#### ##', '#### # ', '## # # ', '## ### ', '       ', '       ')),
    (Code: $042F; W: 5; Rows: ('     ', '     ', ' ####', '##  #', '##  #', '##  #', ' ####', ' ## #', '##  #', '##  #', '     ', '     ')),
    (Code: $0430; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '   ##', '#####', '## ##', '#  ##', '#####', '     ', '     ')),
    (Code: $0431; W: 6; Rows: ('      ', '      ', '  ### ', ' #    ', '##### ', '### ##', '##  ##', ' #  ##', ' ## ##', '  ### ', '      ', '      ')),
    (Code: $0432; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '#  ##', '#### ', '#  ##', '#  ##', '#### ', '     ', '     ')),
    (Code: $0433; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '##   ', '##   ', '##   ', '##   ', '##   ', '     ', '     ')),
    (Code: $0434; W: 6; Rows: ('      ', '      ', '      ', '      ', ' #####', ' ## ##', ' ## ##', ' ## ##', ' ## ##', '######', '##   #', '##   #')),
    (Code: $0435; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '#  ##', '#####', '#    ', '##   ', ' ####', '     ', '     ')),
    (Code: $0451; W: 5; Rows: ('     ', ' # # ', '     ', '     ', ' ### ', '#  ##', '#####', '#    ', '##   ', ' ####', '     ', '     ')),
    (Code: $0436; W: 6; Rows: ('      ', '      ', '      ', '      ', '## # #', ' #####', ' #### ', ' #####', ' # # #', '## # #', '      ', '      ')),
    (Code: $0437; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '   ##', ' ### ', '   ##', '   ##', '#### ', '     ', '     ')),
    (Code: $0438; W: 5; Rows: ('     ', '     ', '     ', '     ', '#  ##', '# ###', '# ###', '#####', '## ##', '## ##', '     ', '     ')),
    (Code: $0439; W: 5; Rows: ('     ', ' # # ', ' ### ', '     ', '#  ##', '# ###', '# ###', '#####', '## ##', '## ##', '     ', '     ')),
    (Code: $043A; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '#### ', '###  ', '#### ', '## ##', '## ##', '     ', '     ')),
    (Code: $043B; W: 6; Rows: ('      ', '      ', '      ', '      ', ' #####', ' ## ##', ' ## ##', ' ## ##', ' ## ##', '##  ##', '      ', '      ')),
    (Code: $043C; W: 6; Rows: ('      ', '      ', '      ', '      ', '### ##', '### ##', '######', '######', '#### #', '##   #', '      ', '      ')),
    (Code: $043D; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '## ##', '#####', '## ##', '## ##', '## ##', '     ', '     ')),
    (Code: $043E; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ### ', '## ##', '#  ##', '#  ##', '## ##', ' ### ', '     ', '     ')),
    (Code: $043F; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', '## ##', '## ##', '## ##', '## ##', '## ##', '     ', '     ')),
    (Code: $0440; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '## ##', '#  ##', '#  ##', '## ##', '#### ', '#    ', '#    ')),
    (Code: $0441; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ####', '##   ', '##   ', '##   ', '##   ', ' ####', '     ', '     ')),
    (Code: $0442; W: 5; Rows: ('     ', '     ', '     ', '     ', '#####', ' ##  ', ' ##  ', ' ##  ', ' ##  ', ' ##  ', '     ', '     ')),
    (Code: $0443; W: 6; Rows: ('      ', '      ', '      ', '      ', '##  ##', ' ## ##', ' ## # ', '  ### ', '  ### ', '  ##  ', '  ##  ', ' ##   ')),
    (Code: $0444; W: 6; Rows: ('      ', '   #  ', '   #  ', '   #  ', '  ### ', ' #####', '## # #', '## # #', ' #####', '  ### ', '   #  ', '   #  ')),
    (Code: $0445; W: 5; Rows: ('     ', '     ', '     ', '     ', '## ##', '#### ', ' ##  ', ' ### ', '#### ', '#  ##', '     ', '     ')),
    (Code: $0446; W: 6; Rows: ('      ', '      ', '      ', '      ', '##  # ', '##  # ', '##  # ', '##  # ', '##  # ', '######', '     #', '     #')),
    (Code: $0447; W: 5; Rows: ('     ', '     ', '     ', '     ', '#  ##', '#  ##', '## ##', '#####', '   ##', '   ##', '     ', '     ')),
    (Code: $0448; W: 6; Rows: ('      ', '      ', '      ', '      ', '## # #', '## # #', '## # #', '## # #', '## # #', '######', '      ', '      ')),
    (Code: $0449; W: 7; Rows: ('       ', '       ', '       ', '       ', '#### # ', '#### # ', '#### # ', '#### # ', '#### # ', '#######', '     ##', '     ##')),
    (Code: $044A; W: 6; Rows: ('      ', '      ', '      ', '      ', '###   ', ' ##   ', ' #### ', ' #####', ' ## ##', ' #####', '      ', '      ')),
    (Code: $044B; W: 7; Rows: ('       ', '       ', '       ', '       ', '##   ##', '##   ##', '###  ##', '#### ##', '#### ##', '#### ##', '       ', '       ')),
    (Code: $044C; W: 5; Rows: ('     ', '     ', '     ', '     ', '#    ', '#    ', '#### ', '#  ##', '#  ##', '#### ', '     ', '     ')),
    (Code: $044D; W: 5; Rows: ('     ', '     ', '     ', '     ', '#### ', '  ## ', ' ####', ' ####', '  ## ', '#### ', '     ', '     ')),
    (Code: $044E; W: 6; Rows: ('      ', '      ', '      ', '      ', '## ## ', '#### #', '#### #', '#### #', '#### #', '## ## ', '      ', '      ')),
    (Code: $044F; W: 5; Rows: ('     ', '     ', '     ', '     ', ' ####', '## ##', '## ##', ' ####', ' # ##', '## ##', '     ', '     '))
  );

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

function FindGlyph(code: Cardinal; out W: Integer): TGlyphRows;
var
  i: Integer;
  blank: TGlyphRows;
  row: Integer;
begin
  for i := 0 to FONT_SIZE_COUNT - 1 do
    if FONT[i].Code = code then
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

type
  TStringArray = array of string;

{ Renders the banner into an array of plain (uncolored, unbordered)
  text lines - used both for plain output and as the basis for the
  bordered / colored output modes. }
function BuildLines(const codepoints: specialize TArray<Cardinal>): TStringArray;
var
  row, i, w: Integer;
  line: string;
  glyph: TGlyphRows;
  lines: TStringArray;
begin
  SetLength(lines, GLYPH_H);
  for row := 0 to GLYPH_H - 1 do
  begin
    line := '';
    for i := 0 to High(codepoints) do
    begin
      if codepoints[i] = Ord(' ') then
        line := line + StringOfChar(' ', SPACE_W + KERNING)
      else
      begin
        glyph := FindGlyph(codepoints[i], w);
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
  WriteLn('  fancywords <text>              render text given as arguments');
  WriteLn('  echo "text" | fancywords       render text piped via stdin');
  WriteLn('  fancywords -c <color> <text>   colored output');
  WriteLn('  fancywords -c rainbow <text>   rainbow output (color per letter)');
  WriteLn('  fancywords -b <text>           draw a border around the banner');
  WriteLn('  fancywords -h | --help         show this help');
  WriteLn;
  WriteLn('Colors: red, green, yellow, blue, magenta, cyan, white, rainbow');
  WriteLn('Supports: A-Z a-z 0-9, Cyrillic А-Я а-я, and common punctuation.');
end;

var
  i, argIdx, maxLineLen: Integer;
  input: string;
  colorMode: TColorMode;
  fixedColor: string;
  border: Boolean;
  args: array of string;
  codepoints: specialize TArray<Cardinal>;
  lines: array of string;
begin
  colorMode := cmNone;
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
  lines := BuildLines(codepoints);

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
