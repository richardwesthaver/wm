;; Copyright (C) 2006-2008 Matthew Kennedy
;;
;;  This file is part of stumpwm.
;;
;; stumpwm is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; stumpwm is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software; see the file COPYING.  If not, see
;; <http://www.gnu.org/licenses/>.

;; Commentary:
;;
;; Mapping a keysym to a name is a client side activity in X11.  Some
;; of the code here was taken from the CMUCL Hemlocks code base.  The
;; actual mappings were taken from Xorg's keysymdefs.h.
;;
;; Code:

(in-package #:wm)

(load-xkbcommon)

(defvar *keysym-name-table* (make-hash-table))
(defvar *name-keysym-table* (make-hash-table :test #'equal))
(defvar *dead-keysym-name-table* (make-hash-table))

(definline keysym-code-name (code)
  (gethash code *keysym-name-table*))

(definline keysym-name-code (name)
  (gethash name *name-keysym-table*))

(defun load-xkb-keysyms (&rest codes)
  "Retrieve and map the names of the keysyms CODES which are all integers. Returns a table of INT->STRING."
  (dolist (c codes (values *keysym-name-table* *name-keysym-table*))
    (declare (fixnum c))
    (lety ((n (io/kbd:kbd-code-name c) :type string))
      (if (and (> (length n) 5) (string= "dead_" (subseq n 0 5)))
          (setf (gethash c *dead-keysym-name-table*) (subseq n 5))
          (setf (gethash c *keysym-name-table*) n
                (gethash n *name-keysym-table*) c)))))

(load-xkb-keysyms
 #xffffff ; "VoidSymbol"   ;Void symbol
 #xff08 ; "BackSpace"      ;Back space, back char
 #xff09 ; "Tab"
 #xff0a ; "Linefeed"       ;Linefeed, LF
 #xff0b ; "Clear"
 #xff0d ; "Return"         ;Return, enter
 #xff13 ; "Pause"          ;Pause, hold
 #xff14 ; "Scroll_Lock"
 #xff15 ; "Sys_Req"
 #xff1b ; "Escape"
 #xffff ; "Delete"         ;Delete, rubout
 #xff20 ; "Multi_key"      ;Multi-key character compose
 #xff37 ; "Codeinput"
 #xff3c ; "SingleCandidate"
 #xff3d ; "MultipleCandidate"
 #xff3e ; "PreviousCandidate"
 #xff21 ; "Kanji"          ;Kanji, Kanji convert
 #xff22 ; "Muhenkan"       ;Cancel Conversion
 #xff23 ; "Henkan_Mode"    ;Start/Stop Conversion
 #xff23 ; "Henkan"         ;Alias for Henkan_Mode
 #xff24 ; "Romaji"         ;to Romaji
 #xff25 ; "Hiragana"       ;to Hiragana
 #xff26 ; "Katakana"       ;to Katakana
 #xff27 ; "Hiragana_Katakana" ;Hiragana/Katakana toggle
 #xff28 ; "Zenkaku"        ;to Zenkaku
 #xff29 ; "Hankaku"        ;to Hankaku
 #xff2a ; "Zenkaku_Hankaku" ;Zenkaku/Hankaku toggle
 #xff2b ; "Touroku"        ;Add to Dictionary
 #xff2c ; "Massyo"         ;Delete from Dictionary
 #xff2d ; "Kana_Lock"      ;Kana Lock
 #xff2e ; "Kana_Shift"     ;Kana Shift
 #xff2f ; "Eisu_Shift"     ;Alphanumeric Shift
 #xff30 ; "Eisu_toggle"    ;Alphanumeric toggle
 #xff37 ; "Kanji_Bangou"   ;Codeinput
 #xff3d ; "Zen_Koho"       ;Multiple/All Candidate(s)
 #xff3e ; "Mae_Koho"       ;Previous Candidate
 #xff50 ; "Home"
 #xff51 ; "Left"           ;Move left, left arrow
 #xff52 ; "Up"             ;Move up, up arrow
 #xff53 ; "Right"          ;Move right, right arrow
 #xff54 ; "Down"           ;Move down, down arrow
 #xff55 ; "Prior"          ;Prior, previous
 #xff55 ; "Page_Up"
 #xff56 ; "Next"           ;Next
 #xff56 ; "Page_Down"
 #xff57 ; "End"            ;EOL
 #xff58 ; "Begin"          ;BOL
 #xff60 ; "Select"         ;Select, mark
 #xff61 ; "Print"
 #xff62 ; "Execute"        ;Execute, run, do
 #xff63 ; "Insert"         ;Insert, insert here
 #xff65 ; "Undo"
 #xff66 ; "Redo"           ;Redo, again
 #xff67 ; "Menu"
 #xff68 ; "Find"           ;Find, search
 #xff69 ; "Cancel"         ;Cancel, stop, abort, exit
 #xff6a ; "Help"           ;Help
 #xff6b ; "Break"
 #xff7e ; "Mode_switch"    ;Character set switch
 #xff7e ; "script_switch"  ;Alias for mode_switch
 #xff7f ; "Num_Lock"
 #xff80 ; "KP_Space"       ;Space
 #xff89 ; "KP_Tab"
 #xff8d ; "KP_Enter"       ;Enter
 #xff91 ; "KP_F1"          ;PF1, KP_A, ...
 #xff92 ; "KP_F2"
 #xff93 ; "KP_F3"
 #xff94 ; "KP_F4"
 #xff95 ; "KP_Home"
 #xff96 ; "KP_Left"
 #xff97 ; "KP_Up"
 #xff98 ; "KP_Right"
 #xff99 ; "KP_Down"
 #xff9a ; "KP_Prior"
 #xff9a ; "KP_Page_Up"
 #xff9b ; "KP_Next"
 #xff9b ; "KP_Page_Down"
 #xff9c ; "KP_End"
 #xff9d ; "KP_Begin"
 #xff9e ; "KP_Insert"
 #xff9f ; "KP_Delete"
 #xffbd ; "KP_Equal"       ;Equals
 #xffaa ; "KP_Multiply"
 #xffab ; "KP_Add"
 #xffac ; "KP_Separator"   ;Separator, often comma
 #xffad ; "KP_Subtract"
 #xffae ; "KP_Decimal"
 #xffaf ; "KP_Divide"
 #xffb0 ; "KP_0"
 #xffb1 ; "KP_1"
 #xffb2 ; "KP_2"
 #xffb3 ; "KP_3"
 #xffb4 ; "KP_4"
 #xffb5 ; "KP_5"
 #xffb6 ; "KP_6"
 #xffb7 ; "KP_7"
 #xffb8 ; "KP_8"
 #xffb9 ; "KP_9"
 #xffbe ; "F1"
 #xffbf ; "F2"
 #xffc0 ; "F3"
 #xffc1 ; "F4"
 #xffc2 ; "F5"
 #xffc3 ; "F6"
 #xffc4 ; "F7"
 #xffc5 ; "F8"
 #xffc6 ; "F9"
 #xffc7 ; "F10"
 #xffc8 ; "F11"
 #xffc9 ; "F12"
 #xffca ; "F13"
 #xffcb ; "F14"
 #xffcc ; "F15"
 #xffcd ; "F16"
 #xffce ; "F17"
 #xffcf ; "F18"
 #xffd0 ; "F19"
 #xffd1 ; "F20"
 #xffd2 ; "F21"
 #xffd3 ; "F22"
 #xffd4 ; "F23"
 #xffd5 ; "F24"
 #xffd6 ; "F25"
 #xffd7 ; "F26"
 #xffd8 ; "F27"
 #xffd9 ; "F28"
 #xffda ; "F29"
 #xffdb ; "F30"
 #xffdc ; "F31"
 #xffdd ; "F32"
 #xffde ; "F33"
 #xffdf ; "F34"
 #xffe0 ; "F35"
 #xffe1 ; "Shift_L"        ;Left shift
 #xffe2 ; "Shift_R"        ;Right shift
 #xffe3 ; "Control_L"      ;Left control
 #xffe4 ; "Control_R"      ;Right control
 #xffe5 ; "Caps_Lock"      ;Caps lock
 #xffe6 ; "Shift_Lock"     ;Shift lock
 #xffe7 ; "Meta_L"         ;Left meta
 #xffe8 ; "Meta_R"         ;Right meta
 #xffe9 ; "Alt_L"          ;Left alt
 #xffea ; "Alt_R"          ;Right alt
 #xffeb ; "Super_L"        ;Left super
 #xffec ; "Super_R"        ;Right super
 #xffed ; "Hyper_L"        ;Left hyper
 #xffee ; "Hyper_R"        ;Right hyper
 #xfe01 ; "ISO_Lock"
 #xfe02 ; "ISO_Level2_Latch"
 #xfe03 ; "ISO_Level3"
 #xfe04 ; "ISO_Level3_Latch"
 #xfe05 ; "ISO_Level3_Lock"
 #xff7e ; "ISO_Group_Shift" ;Alias for mode_switch
 #xfe06 ; "ISO_Group_Latch"
 #xfe07 ; "ISO_Group_Lock"
 #xfe08 ; "ISO_Next_Group"
 #xfe09 ; "ISO_Next_Group_Lock"
 #xfe0a ; "ISO_Prev_Group"
 #xfe0b ; "ISO_Prev_Group_Lock"
 #xfe0c ; "ISO_First_Group"
 #xfe0d ; "ISO_First_Group_Lock"
 #xfe0e ; "ISO_Last_Group"
 #xfe0f ; "ISO_Last_Group_Lock"
 #xfe20 ; "ISO_Left_Tab"
 #xfe21 ; "ISO_Move_Line_Up"
 #xfe22 ; "ISO_Move_Line_Down"
 #xfe23 ; "ISO_Partial_Line_Up"
 #xfe24 ; "ISO_Partial_Line_Down"
 #xfe25 ; "ISO_Partial_Space_Left"
 #xfe26 ; "ISO_Partial_Space_Right"
 #xfe27 ; "ISO_Set_Margin_Left"
 #xfe28 ; "ISO_Set_Margin_Right"
 #xfe29 ; "ISO_Release_Margin_Left"
 #xfe2a ; "ISO_Release_Margin_Right"
 #xfe2b ; "ISO_Release_Both_Margins"
 #xfe2c ; "ISO_Fast_Cursor_Left"
 #xfe2d ; "ISO_Fast_Cursor_Right"
 #xfe2e ; "ISO_Fast_Cursor_Up"
 #xfe2f ; "ISO_Fast_Cursor_Down"
 #xfe30 ; "ISO_Continuous_Underline"
 #xfe31 ; "ISO_Discontinuous_Underline"
 #xfe32 ; "ISO_Emphasize"
 #xfe33 ; "ISO_Center_Object"
 #xfe34 ; "ISO_Enter"
 #xfe50 ; "dead_grave" DEAD
 #xfe51 ; "dead_acute" DEAD
 #xfe52 ; "dead_circumflex" DEAD
 #xfe53 ; "dead_tilde" DEAD
 #xfe54 ; "dead_macron" DEAD
 #xfe55 ; "dead_breve" DEAD
 #xfe56 ; "dead_abovedot" DEAD
 #xfe57 ; "dead_diaeresis" DEAD
 #xfe58 ; "dead_abovering" DEAD
 #xfe59 ; "dead_doubleacute" DEAD
 #xfe5a ; "dead_caron" DEAD
 #xfe5b ; "dead_cedilla" DEAD
 #xfe5c ; "dead_ogonek" DEAD
 #xfe5d ; "dead_iota" DEAD
 #xfe5e ; "dead_voiced_sound" DEAD
 #xfe5f ; "dead_semivoiced_sound" DEAD
 #xfe60 ; "dead_belowdot" DEAD
 #xfe61 ; "dead_hook" DEAD
 #xfe62 ; "dead_horn" DEAD
 #xfed0 ; "First_Virtual_Screen"
 #xfed1 ; "Prev_Virtual_Screen"
 #xfed2 ; "Next_Virtual_Screen"
 #xfed4 ; "Last_Virtual_Screen"
 #xfed5 ; "Terminate_Server"
 #xfe70 ; "AccessX_Enable"
 #xfe71 ; "AccessX_Feedback_Enable"
 #xfe72 ; "RepeatKeys_Enable"
 #xfe73 ; "SlowKeys_Enable"
 #xfe74 ; "BounceKeys_Enable"
 #xfe75 ; "StickyKeys_Enable"
 #xfe76 ; "MouseKeys_Enable"
 #xfe77 ; "MouseKeys_Accel_Enable"
 #xfe78 ; "Overlay1_Enable"
 #xfe79 ; "Overlay2_Enable"
 #xfe7a ; "AudibleBell_Enable"
 #xfee0 ; "Pointer_Left"
 #xfee1 ; "Pointer_Right"
 #xfee2 ; "Pointer_Up"
 #xfee3 ; "Pointer_Down"
 #xfee4 ; "Pointer_UpLeft"
 #xfee5 ; "Pointer_UpRight"
 #xfee6 ; "Pointer_DownLeft"
 #xfee7 ; "Pointer_DownRight"
 #xfee8 ; "Pointer_Button_Dflt"
 #xfee9 ; "Pointer_Button1"
 #xfeea ; "Pointer_Button2"
 #xfeeb ; "Pointer_Button3"
 #xfeec ; "Pointer_Button4"
 #xfeed ; "Pointer_Button5"
 #xfeee ; "Pointer_DblClick_Dflt"
 #xfeef ; "Pointer_DblClick1"
 #xfef0 ; "Pointer_DblClick2"
 #xfef1 ; "Pointer_DblClick3"
 #xfef2 ; "Pointer_DblClick4"
 #xfef3 ; "Pointer_DblClick5"
 #xfef4 ; "Pointer_Drag_Dflt"
 #xfef5 ; "Pointer_Drag1"
 #xfef6 ; "Pointer_Drag2"
 #xfef7 ; "Pointer_Drag3"
 #xfef8 ; "Pointer_Drag4"
 #xfefd ; "Pointer_Drag5"
 #xfef9 ; "Pointer_EnableKeys"
 #xfefa ; "Pointer_Accelerate"
 #xfefb ; "Pointer_DfltBtnNext"
 #xfefc ; "Pointer_DfltBtnPrev"
 #xfd01 ; "3270_Duplicate"
 #xfd02 ; "3270_FieldMark"
 #xfd03 ; "3270_Right2"
 #xfd04 ; "3270_Left2"
 #xfd05 ; "3270_BackTab"
 #xfd06 ; "3270_EraseEOF"
 #xfd07 ; "3270_EraseInput"
 #xfd08 ; "3270_Reset"
 #xfd09 ; "3270_Quit"
 #xfd0a ; "3270_PA1"
 #xfd0b ; "3270_PA2"
 #xfd0c ; "3270_PA3"
 #xfd0d ; "3270_Test"
 #xfd0e ; "3270_Attn"
 #xfd0f ; "3270_CursorBlink"
 #xfd10 ; "3270_AltCursor"
 #xfd11 ; "3270_KeyClick"
 #xfd12 ; "3270_Jump"
 #xfd13 ; "3270_Ident"
 #xfd14 ; "3270_Rule"
 #xfd15 ; "3270_Copy"
 #xfd16 ; "3270_Play"
 #xfd17 ; "3270_Setup"
 #xfd18 ; "3270_Record"
 #xfd19 ; "3270_ChangeScreen"
 #xfd1a ; "3270_DeleteWord"
 #xfd1b ; "3270_ExSelect"
 #xfd1c ; "3270_CursorSelect"
 #xfd1d ; "3270_PrintScreen"
 #xfd1e ; "3270_Enter"
 #x0020 ; "space")          ;U+0020 SPAC
 #x0021 ; "exclam")         ;U+0021 EXCLAMATION MAR
 #x0022 ; "quotedbl")       ;U+0022 QUOTATION MAR
 #x0023 ; "numbersign")     ;U+0023 NUMBER SIG
 #x0024 ; "dollar")         ;U+0024 DOLLAR SIG
 #x0025 ; "percent")        ;U+0025 PERCENT SIG
 #x0026 ; "ampersand")      ;U+0026 AMPERSAN
 #x0027 ; "apostrophe")     ;U+0027 APOSTROPH
 #x0027 ; "quoteright")     ;deprecate
 #x0028 ; "parenleft")      ;U+0028 LEFT PARENTHESI
 #x0029 ; "parenright")     ;U+0029 RIGHT PARENTHESI
 #x002a ; "asterisk")       ;U+002A ASTERIS
 #x002b ; "plus")           ;U+002B PLUS SIG
 #x002c ; "comma")          ;U+002C COMM
 #x002d ; "minus")          ;U+002D HYPHEN-MINU
 #x002e ; "period")         ;U+002E FULL STO
 #x002f ; "slash")          ;U+002F SOLIDU
 #x0030 ; "0")              ;U+0030 DIGIT ZER
 #x0031 ; "1")              ;U+0031 DIGIT ON
 #x0032 ; "2")              ;U+0032 DIGIT TW
 #x0033 ; "3")              ;U+0033 DIGIT THRE
 #x0034 ; "4")              ;U+0034 DIGIT FOU
 #x0035 ; "5")              ;U+0035 DIGIT FIV
 #x0036 ; "6")              ;U+0036 DIGIT SI
 #x0037 ; "7")              ;U+0037 DIGIT SEVE
 #x0038 ; "8")              ;U+0038 DIGIT EIGH
 #x0039 ; "9")              ;U+0039 DIGIT NIN
 #x003a ; "colon")          ;U+003A COLO
 #x003b ; "semicolon")      ;U+003B SEMICOLO
 #x003c ; "less")           ;U+003C LESS-THAN SIG
 #x003d ; "equal")          ;U+003D EQUALS SIG
 #x003e ; "greater")        ;U+003E GREATER-THAN SIG
 #x003f ; "question")       ;U+003F QUESTION MAR
 #x0040 ; "at")             ;U+0040 COMMERCIAL A
 #x0041 ; "A")              ;U+0041 LATIN CAPITAL LETTER 
 #x0042 ; "B")              ;U+0042 LATIN CAPITAL LETTER 
 #x0043 ; "C")              ;U+0043 LATIN CAPITAL LETTER 
 #x0044 ; "D")              ;U+0044 LATIN CAPITAL LETTER 
 #x0045 ; "E")              ;U+0045 LATIN CAPITAL LETTER 
 #x0046 ; "F")              ;U+0046 LATIN CAPITAL LETTER 
 #x0047 ; "G")              ;U+0047 LATIN CAPITAL LETTER 
 #x0048 ; "H")              ;U+0048 LATIN CAPITAL LETTER 
 #x0049 ; "I")              ;U+0049 LATIN CAPITAL LETTER 
 #x004a ; "J")              ;U+004A LATIN CAPITAL LETTER 
 #x004b ; "K")              ;U+004B LATIN CAPITAL LETTER 
 #x004c ; "L")              ;U+004C LATIN CAPITAL LETTER 
 #x004d ; "M")              ;U+004D LATIN CAPITAL LETTER 
 #x004e ; "N")              ;U+004E LATIN CAPITAL LETTER 
 #x004f ; "O")              ;U+004F LATIN CAPITAL LETTER 
 #x0050 ; "P")              ;U+0050 LATIN CAPITAL LETTER 
 #x0051 ; "Q")              ;U+0051 LATIN CAPITAL LETTER 
 #x0052 ; "R")              ;U+0052 LATIN CAPITAL LETTER 
 #x0053 ; "S")              ;U+0053 LATIN CAPITAL LETTER 
 #x0054 ; "T")              ;U+0054 LATIN CAPITAL LETTER 
 #x0055 ; "U")              ;U+0055 LATIN CAPITAL LETTER 
 #x0056 ; "V")              ;U+0056 LATIN CAPITAL LETTER 
 #x0057 ; "W")              ;U+0057 LATIN CAPITAL LETTER 
 #x0058 ; "X")              ;U+0058 LATIN CAPITAL LETTER 
 #x0059 ; "Y")              ;U+0059 LATIN CAPITAL LETTER 
 #x005a ; "Z")              ;U+005A LATIN CAPITAL LETTER 
 #x005b ; "bracketleft")    ;U+005B LEFT SQUARE BRACKE
 #x005c ; "backslash")      ;U+005C REVERSE SOLIDU
 #x005d ; "bracketright")   ;U+005D RIGHT SQUARE BRACKE
 #x005e ; "asciicircum")    ;U+005E CIRCUMFLEX ACCEN
 #x005f ; "underscore")     ;U+005F LOW LIN
 #x0060 ; "grave")          ;U+0060 GRAVE ACCEN
 #x0060 ; "quoteleft")      ;deprecate
 #x0061 ; "a")              ;U+0061 LATIN SMALL LETTER 
 #x0062 ; "b")              ;U+0062 LATIN SMALL LETTER 
 #x0063 ; "c")              ;U+0063 LATIN SMALL LETTER 
 #x0064 ; "d")              ;U+0064 LATIN SMALL LETTER 
 #x0065 ; "e")              ;U+0065 LATIN SMALL LETTER 
 #x0066 ; "f")              ;U+0066 LATIN SMALL LETTER 
 #x0067 ; "g")              ;U+0067 LATIN SMALL LETTER 
 #x0068 ; "h")              ;U+0068 LATIN SMALL LETTER 
 #x0069 ; "i")              ;U+0069 LATIN SMALL LETTER 
 #x006a ; "j")              ;U+006A LATIN SMALL LETTER 
 #x006b ; "k")              ;U+006B LATIN SMALL LETTER 
 #x006c ; "l")              ;U+006C LATIN SMALL LETTER 
 #x006d ; "m")              ;U+006D LATIN SMALL LETTER 
 #x006e ; "n")              ;U+006E LATIN SMALL LETTER 
 #x006f ; "o")              ;U+006F LATIN SMALL LETTER 
 #x0070 ; "p")              ;U+0070 LATIN SMALL LETTER 
 #x0071 ; "q")              ;U+0071 LATIN SMALL LETTER 
 #x0072 ; "r")              ;U+0072 LATIN SMALL LETTER 
 #x0073 ; "s")              ;U+0073 LATIN SMALL LETTER 
 #x0074 ; "t")              ;U+0074 LATIN SMALL LETTER 
 #x0075 ; "u")              ;U+0075 LATIN SMALL LETTER 
 #x0076 ; "v")              ;U+0076 LATIN SMALL LETTER 
 #x0077 ; "w")              ;U+0077 LATIN SMALL LETTER 
 #x0078 ; "x")              ;U+0078 LATIN SMALL LETTER 
 #x0079 ; "y")              ;U+0079 LATIN SMALL LETTER 
 #x007a ; "z")              ;U+007A LATIN SMALL LETTER 
 #x007b ; "braceleft")      ;U+007B LEFT CURLY BRACKE
 #x007c ; "bar")            ;U+007C VERTICAL LIN
 #x007d ; "braceright")     ;U+007D RIGHT CURLY BRACKE
 #x007e ; "asciitilde")     ;U+007E TILD
 #x00a0 ; "nobreakspace")   ;U+00A0 NO-BREAK SPAC
 #x00a1 ; "exclamdown")  ;U+00A1 INVERTED EXCLAMATION MAR
 #x00a2 ; "cent")           ;U+00A2 CENT SIG
 #x00a3 ; "sterling")       ;U+00A3 POUND SIG
 #x00a4 ; "currency")       ;U+00A4 CURRENCY SIG
 #x00a5 ; "yen")            ;U+00A5 YEN SIG
 #x00a6 ; "brokenbar")      ;U+00A6 BROKEN BA
 #x00a7 ; "section")        ;U+00A7 SECTION SIG
 #x00a8 ; "diaeresis")      ;U+00A8 DIAERESI
 #x00a9 ; "copyright")      ;U+00A9 COPYRIGHT SIG
 #x00aa ; "ordfeminine") ;U+00AA FEMININE ORDINAL INDICATO
 #x00ab ; "guillemotleft") ;U+00AB LEFT-POINTING DOUBLE ANGLE QUOTATION MAR
 #x00ac ; "notsign")        ;U+00AC NOT SIG
 #x00ad ; "hyphen")         ;U+00AD SOFT HYPHE
 #x00ae ; "registered")     ;U+00AE REGISTERED SIG
 #x00af ; "macron")         ;U+00AF MACRO
 #x00b0 ; "degree")         ;U+00B0 DEGREE SIG
 #x00b1 ; "plusminus")      ;U+00B1 PLUS-MINUS SIG
 #x00b2 ; "twosuperior")    ;U+00B2 SUPERSCRIPT TW
 #x00b3 ; "threesuperior")  ;U+00B3 SUPERSCRIPT THRE
 #x00b4 ; "acute")          ;U+00B4 ACUTE ACCEN
 #x00b5 ; "mu")             ;U+00B5 MICRO SIG
 #x00b6 ; "paragraph")      ;U+00B6 PILCROW SIG
 #x00b7 ; "periodcentered") ;U+00B7 MIDDLE DO
 #x00b8 ; "cedilla")        ;U+00B8 CEDILL
 #x00b9 ; "onesuperior")    ;U+00B9 SUPERSCRIPT ON
 #x00ba ; "masculine") ;U+00BA MASCULINE ORDINAL INDICATO
 #x00bb ; "guillemotright") ;U+00BB RIGHT-POINTING DOUBLE ANGLE QUOTATION MAR
 #x00bc ; "onequarter") ;U+00BC VULGAR FRACTION ONE QUARTE
 #x00bd ; "onehalf")      ;U+00BD VULGAR FRACTION ONE HAL
 #x00be ; "threequarters") ;U+00BE VULGAR FRACTION THREE QUARTER
 #x00bf ; "questiondown")   ;U+00BF INVERTED QUESTION MAR
 #x00c0 ; "Agrave") ;U+00C0 LATIN CAPITAL LETTER A WITH GRAV
 #x00c1 ; "Aacute") ;U+00C1 LATIN CAPITAL LETTER A WITH ACUT
 #x00c2 ; "Acircumflex") ;U+00C2 LATIN CAPITAL LETTER A WITH CIRCUMFLE
 #x00c3 ; "Atilde") ;U+00C3 LATIN CAPITAL LETTER A WITH TILD
 #x00c4 ; "Adiaeresis") ;U+00C4 LATIN CAPITAL LETTER A WITH DIAERESI
 #x00c5 ; "Aring") ;U+00C5 LATIN CAPITAL LETTER A WITH RING ABOV
 #x00c6 ; "AE")            ;U+00C6 LATIN CAPITAL LETTER A
 #x00c7 ; "Ccedilla") ;U+00C7 LATIN CAPITAL LETTER C WITH CEDILL
 #x00c8 ; "Egrave") ;U+00C8 LATIN CAPITAL LETTER E WITH GRAV
 #x00c9 ; "Eacute") ;U+00C9 LATIN CAPITAL LETTER E WITH ACUT
 #x00ca ; "Ecircumflex") ;U+00CA LATIN CAPITAL LETTER E WITH CIRCUMFLE
 #x00cb ; "Ediaeresis") ;U+00CB LATIN CAPITAL LETTER E WITH DIAERESI
 #x00cc ; "Igrave") ;U+00CC LATIN CAPITAL LETTER I WITH GRAV
 #x00cd ; "Iacute") ;U+00CD LATIN CAPITAL LETTER I WITH ACUT
 #x00ce ; "Icircumflex") ;U+00CE LATIN CAPITAL LETTER I WITH CIRCUMFLE
 #x00cf ; "Idiaeresis") ;U+00CF LATIN CAPITAL LETTER I WITH DIAERESI
 #x00d0 ; "ETH")          ;U+00D0 LATIN CAPITAL LETTER ET
 #x00d0 ; "Eth")            ;deprecate
 #x00d1 ; "Ntilde") ;U+00D1 LATIN CAPITAL LETTER N WITH TILD
 #x00d2 ; "Ograve") ;U+00D2 LATIN CAPITAL LETTER O WITH GRAV
 #x00d3 ; "Oacute") ;U+00D3 LATIN CAPITAL LETTER O WITH ACUT
 #x00d4 ; "Ocircumflex") ;U+00D4 LATIN CAPITAL LETTER O WITH CIRCUMFLE
 #x00d5 ; "Otilde") ;U+00D5 LATIN CAPITAL LETTER O WITH TILD
 #x00d6 ; "Odiaeresis") ;U+00D6 LATIN CAPITAL LETTER O WITH DIAERESI
 #x00d7 ; "multiply")       ;U+00D7 MULTIPLICATION SIG
 #x00d8 ; "Oslash") ;U+00D8 LATIN CAPITAL LETTER O WITH STROK
 #x00d8 ; "Ooblique") ;U+00D8 LATIN CAPITAL LETTER O WITH STROK
 #x00d9 ; "Ugrave") ;U+00D9 LATIN CAPITAL LETTER U WITH GRAV
 #x00da ; "Uacute") ;U+00DA LATIN CAPITAL LETTER U WITH ACUT
 #x00db ; "Ucircumflex") ;U+00DB LATIN CAPITAL LETTER U WITH CIRCUMFLE
 #x00dc ; "Udiaeresis") ;U+00DC LATIN CAPITAL LETTER U WITH DIAERESI
 #x00dd ; "Yacute") ;U+00DD LATIN CAPITAL LETTER Y WITH ACUT
 #x00de ; "THORN")      ;U+00DE LATIN CAPITAL LETTER THOR
 #x00de ; "Thorn")          ;deprecate
 #x00df ; "ssharp")     ;U+00DF LATIN SMALL LETTER SHARP 
 #x00e0 ; "agrave") ;U+00E0 LATIN SMALL LETTER A WITH GRAV
 #x00e1 ; "aacute") ;U+00E1 LATIN SMALL LETTER A WITH ACUT
 #x00e2 ; "acircumflex") ;U+00E2 LATIN SMALL LETTER A WITH CIRCUMFLE
 #x00e3 ; "atilde") ;U+00E3 LATIN SMALL LETTER A WITH TILD
 #x00e4 ; "adiaeresis") ;U+00E4 LATIN SMALL LETTER A WITH DIAERESI
 #x00e5 ; "aring") ;U+00E5 LATIN SMALL LETTER A WITH RING ABOV
 #x00e6 ; "ae")             ;U+00E6 LATIN SMALL LETTER A
 #x00e7 ; "ccedilla") ;U+00E7 LATIN SMALL LETTER C WITH CEDILL
 #x00e8 ; "egrave") ;U+00E8 LATIN SMALL LETTER E WITH GRAV
 #x00e9 ; "eacute") ;U+00E9 LATIN SMALL LETTER E WITH ACUT
 #x00ea ; "ecircumflex") ;U+00EA LATIN SMALL LETTER E WITH CIRCUMFLE
 #x00eb ; "ediaeresis") ;U+00EB LATIN SMALL LETTER E WITH DIAERESI
 #x00ec ; "igrave") ;U+00EC LATIN SMALL LETTER I WITH GRAV
 #x00ed ; "iacute") ;U+00ED LATIN SMALL LETTER I WITH ACUT
 #x00ee ; "icircumflex") ;U+00EE LATIN SMALL LETTER I WITH CIRCUMFLE
 #x00ef ; "idiaeresis") ;U+00EF LATIN SMALL LETTER I WITH DIAERESI
 #x00f0 ; "eth")            ;U+00F0 LATIN SMALL LETTER ET
 #x00f1 ; "ntilde") ;U+00F1 LATIN SMALL LETTER N WITH TILD
 #x00f2 ; "ograve") ;U+00F2 LATIN SMALL LETTER O WITH GRAV
 #x00f3 ; "oacute") ;U+00F3 LATIN SMALL LETTER O WITH ACUT
 #x00f4 ; "ocircumflex") ;U+00F4 LATIN SMALL LETTER O WITH CIRCUMFLE
 #x00f5 ; "otilde") ;U+00F5 LATIN SMALL LETTER O WITH TILD
 #x00f6 ; "odiaeresis") ;U+00F6 LATIN SMALL LETTER O WITH DIAERESI
 #x00f7 ; "division")       ;U+00F7 DIVISION SIG
 #x00f8 ; "oslash") ;U+00F8 LATIN SMALL LETTER O WITH STROK
 #x00f8 ; "ooblique") ;U+00F8 LATIN SMALL LETTER O WITH STROK
 #x00f9 ; "ugrave") ;U+00F9 LATIN SMALL LETTER U WITH GRAV
 #x00fa ; "uacute") ;U+00FA LATIN SMALL LETTER U WITH ACUT
 #x00fb ; "ucircumflex") ;U+00FB LATIN SMALL LETTER U WITH CIRCUMFLE
 #x00fc ; "udiaeresis") ;U+00FC LATIN SMALL LETTER U WITH DIAERESI
 #x00fd ; "yacute") ;U+00FD LATIN SMALL LETTER Y WITH ACUT
 #x00fe ; "thorn")        ;U+00FE LATIN SMALL LETTER THOR
 #x00ff ; "ydiaeresis") ;U+00FF LATIN SMALL LETTER Y WITH DIAERESI
 #x01a1 ; "Aogonek") ;U+0104 LATIN CAPITAL LETTER A WITH OGONE
 #x01a2 ; "breve")          ;U+02D8 BREV
 #x01a3 ; "Lstroke") ;U+0141 LATIN CAPITAL LETTER L WITH STROK
 #x01a5 ; "Lcaron") ;U+013D LATIN CAPITAL LETTER L WITH CARO
 #x01a6 ; "Sacute") ;U+015A LATIN CAPITAL LETTER S WITH ACUT
 #x01a9 ; "Scaron") ;U+0160 LATIN CAPITAL LETTER S WITH CARO
 #x01aa ; "Scedilla") ;U+015E LATIN CAPITAL LETTER S WITH CEDILL
 #x01ab ; "Tcaron") ;U+0164 LATIN CAPITAL LETTER T WITH CARO
 #x01ac ; "Zacute") ;U+0179 LATIN CAPITAL LETTER Z WITH ACUT
 #x01ae ; "Zcaron") ;U+017D LATIN CAPITAL LETTER Z WITH CARO
 #x01af ; "Zabovedot") ;U+017B LATIN CAPITAL LETTER Z WITH DOT ABOV
 #x01b1 ; "aogonek") ;U+0105 LATIN SMALL LETTER A WITH OGONE
 #x01b2 ; "ogonek")         ;U+02DB OGONE
 #x01b3 ; "lstroke") ;U+0142 LATIN SMALL LETTER L WITH STROK
 #x01b5 ; "lcaron") ;U+013E LATIN SMALL LETTER L WITH CARO
 #x01b6 ; "sacute") ;U+015B LATIN SMALL LETTER S WITH ACUT
 #x01b7 ; "caron")          ;U+02C7 CARO
 #x01b9 ; "scaron") ;U+0161 LATIN SMALL LETTER S WITH CARO
 #x01ba ; "scedilla") ;U+015F LATIN SMALL LETTER S WITH CEDILL
 #x01bb ; "tcaron") ;U+0165 LATIN SMALL LETTER T WITH CARO
 #x01bc ; "zacute") ;U+017A LATIN SMALL LETTER Z WITH ACUT
 #x01bd ; "doubleacute")    ;U+02DD DOUBLE ACUTE ACCEN
 #x01be ; "zcaron") ;U+017E LATIN SMALL LETTER Z WITH CARO
 #x01bf ; "zabovedot") ;U+017C LATIN SMALL LETTER Z WITH DOT ABOV
 #x01c0 ; "Racute") ;U+0154 LATIN CAPITAL LETTER R WITH ACUT
 #x01c3 ; "Abreve") ;U+0102 LATIN CAPITAL LETTER A WITH BREV
 #x01c5 ; "Lacute") ;U+0139 LATIN CAPITAL LETTER L WITH ACUT
 #x01c6 ; "Cacute") ;U+0106 LATIN CAPITAL LETTER C WITH ACUT
 #x01c8 ; "Ccaron") ;U+010C LATIN CAPITAL LETTER C WITH CARO
 #x01ca ; "Eogonek") ;U+0118 LATIN CAPITAL LETTER E WITH OGONE
 #x01cc ; "Ecaron") ;U+011A LATIN CAPITAL LETTER E WITH CARO
 #x01cf ; "Dcaron") ;U+010E LATIN CAPITAL LETTER D WITH CARO
 #x01d0 ; "Dstroke") ;U+0110 LATIN CAPITAL LETTER D WITH STROK
 #x01d1 ; "Nacute") ;U+0143 LATIN CAPITAL LETTER N WITH ACUT
 #x01d2 ; "Ncaron") ;U+0147 LATIN CAPITAL LETTER N WITH CARO
 #x01d5 ; "Odoubleacute") ;U+0150 LATIN CAPITAL LETTER O WITH DOUBLE ACUT
 #x01d8 ; "Rcaron") ;U+0158 LATIN CAPITAL LETTER R WITH CARO
 #x01d9 ; "Uring") ;U+016E LATIN CAPITAL LETTER U WITH RING ABOV
 #x01db ; "Udoubleacute") ;U+0170 LATIN CAPITAL LETTER U WITH DOUBLE ACUT
 #x01de ; "Tcedilla") ;U+0162 LATIN CAPITAL LETTER T WITH CEDILL
 #x01e0 ; "racute") ;U+0155 LATIN SMALL LETTER R WITH ACUT
 #x01e3 ; "abreve") ;U+0103 LATIN SMALL LETTER A WITH BREV
 #x01e5 ; "lacute") ;U+013A LATIN SMALL LETTER L WITH ACUT
 #x01e6 ; "cacute") ;U+0107 LATIN SMALL LETTER C WITH ACUT
 #x01e8 ; "ccaron") ;U+010D LATIN SMALL LETTER C WITH CARO
 #x01ea ; "eogonek") ;U+0119 LATIN SMALL LETTER E WITH OGONE
 #x01ec ; "ecaron") ;U+011B LATIN SMALL LETTER E WITH CARO
 #x01ef ; "dcaron") ;U+010F LATIN SMALL LETTER D WITH CARO
 #x01f0 ; "dstroke") ;U+0111 LATIN SMALL LETTER D WITH STROK
 #x01f1 ; "nacute") ;U+0144 LATIN SMALL LETTER N WITH ACUT
 #x01f2 ; "ncaron") ;U+0148 LATIN SMALL LETTER N WITH CARO
 #x01f5 ; "odoubleacute") ;U+0151 LATIN SMALL LETTER O WITH DOUBLE ACUT
 #x01fb ; "udoubleacute") ;U+0171 LATIN SMALL LETTER U WITH DOUBLE ACUT
 #x01f8 ; "rcaron") ;U+0159 LATIN SMALL LETTER R WITH CARO
 #x01f9 ; "uring") ;U+016F LATIN SMALL LETTER U WITH RING ABOV
 #x01fe ; "tcedilla") ;U+0163 LATIN SMALL LETTER T WITH CEDILL
 #x01ff ; "abovedot")       ;U+02D9 DOT ABOV
 #x02a1 ; "Hstroke") ;U+0126 LATIN CAPITAL LETTER H WITH STROK
 #x02a6 ; "Hcircumflex") ;U+0124 LATIN CAPITAL LETTER H WITH CIRCUMFLE
 #x02a9 ; "Iabovedot") ;U+0130 LATIN CAPITAL LETTER I WITH DOT ABOV
 #x02ab ; "Gbreve") ;U+011E LATIN CAPITAL LETTER G WITH BREV
 #x02ac ; "Jcircumflex") ;U+0134 LATIN CAPITAL LETTER J WITH CIRCUMFLE
 #x02b1 ; "hstroke") ;U+0127 LATIN SMALL LETTER H WITH STROK
 #x02b6 ; "hcircumflex") ;U+0125 LATIN SMALL LETTER H WITH CIRCUMFLE
 #x02b9 ; "idotless") ;U+0131 LATIN SMALL LETTER DOTLESS 
 #x02bb ; "gbreve") ;U+011F LATIN SMALL LETTER G WITH BREV
 #x02bc ; "jcircumflex") ;U+0135 LATIN SMALL LETTER J WITH CIRCUMFLE
 #x02c5 ; "Cabovedot") ;U+010A LATIN CAPITAL LETTER C WITH DOT ABOV
 #x02c6 ; "Ccircumflex") ;U+0108 LATIN CAPITAL LETTER C WITH CIRCUMFLE
 #x02d5 ; "Gabovedot") ;U+0120 LATIN CAPITAL LETTER G WITH DOT ABOV
 #x02d8 ; "Gcircumflex") ;U+011C LATIN CAPITAL LETTER G WITH CIRCUMFLE
 #x02dd ; "Ubreve") ;U+016C LATIN CAPITAL LETTER U WITH BREV
 #x02de ; "Scircumflex") ;U+015C LATIN CAPITAL LETTER S WITH CIRCUMFLE
 #x02e5 ; "cabovedot") ;U+010B LATIN SMALL LETTER C WITH DOT ABOV
 #x02e6 ; "ccircumflex") ;U+0109 LATIN SMALL LETTER C WITH CIRCUMFLE
 #x02f5 ; "gabovedot") ;U+0121 LATIN SMALL LETTER G WITH DOT ABOV
 #x02f8 ; "gcircumflex") ;U+011D LATIN SMALL LETTER G WITH CIRCUMFLE
 #x02fd ; "ubreve") ;U+016D LATIN SMALL LETTER U WITH BREV
 #x02fe ; "scircumflex") ;U+015D LATIN SMALL LETTER S WITH CIRCUMFLE
 #x03a2 ; "kra")            ;U+0138 LATIN SMALL LETTER KR
 #x03a2 ; "kappa")          ;deprecate
 #x03a3 ; "Rcedilla") ;U+0156 LATIN CAPITAL LETTER R WITH CEDILL
 #x03a5 ; "Itilde") ;U+0128 LATIN CAPITAL LETTER I WITH TILD
 #x03a6 ; "Lcedilla") ;U+013B LATIN CAPITAL LETTER L WITH CEDILL
 #x03aa ; "Emacron") ;U+0112 LATIN CAPITAL LETTER E WITH MACRO
 #x03ab ; "Gcedilla") ;U+0122 LATIN CAPITAL LETTER G WITH CEDILL
 #x03ac ; "Tslash") ;U+0166 LATIN CAPITAL LETTER T WITH STROK
 #x03b3 ; "rcedilla") ;U+0157 LATIN SMALL LETTER R WITH CEDILL
 #x03b5 ; "itilde") ;U+0129 LATIN SMALL LETTER I WITH TILD
 #x03b6 ; "lcedilla") ;U+013C LATIN SMALL LETTER L WITH CEDILL
 #x03ba ; "emacron") ;U+0113 LATIN SMALL LETTER E WITH MACRO
 #x03bb ; "gcedilla") ;U+0123 LATIN SMALL LETTER G WITH CEDILL
 #x03bc ; "tslash") ;U+0167 LATIN SMALL LETTER T WITH STROK
 #x03bd ; "ENG")          ;U+014A LATIN CAPITAL LETTER EN
 #x03bf ; "eng")            ;U+014B LATIN SMALL LETTER EN
 #x03c0 ; "Amacron") ;U+0100 LATIN CAPITAL LETTER A WITH MACRO
 #x03c7 ; "Iogonek") ;U+012E LATIN CAPITAL LETTER I WITH OGONE
 #x03cc ; "Eabovedot") ;U+0116 LATIN CAPITAL LETTER E WITH DOT ABOV
 #x03cf ; "Imacron") ;U+012A LATIN CAPITAL LETTER I WITH MACRO
 #x03d1 ; "Ncedilla") ;U+0145 LATIN CAPITAL LETTER N WITH CEDILL
 #x03d2 ; "Omacron") ;U+014C LATIN CAPITAL LETTER O WITH MACRO
 #x03d3 ; "Kcedilla") ;U+0136 LATIN CAPITAL LETTER K WITH CEDILL
 #x03d9 ; "Uogonek") ;U+0172 LATIN CAPITAL LETTER U WITH OGONE
 #x03dd ; "Utilde") ;U+0168 LATIN CAPITAL LETTER U WITH TILD
 #x03de ; "Umacron") ;U+016A LATIN CAPITAL LETTER U WITH MACRO
 #x03e0 ; "amacron") ;U+0101 LATIN SMALL LETTER A WITH MACRO
 #x03e7 ; "iogonek") ;U+012F LATIN SMALL LETTER I WITH OGONE
 #x03ec ; "eabovedot") ;U+0117 LATIN SMALL LETTER E WITH DOT ABOV
 #x03ef ; "imacron") ;U+012B LATIN SMALL LETTER I WITH MACRO
 #x03f1 ; "ncedilla") ;U+0146 LATIN SMALL LETTER N WITH CEDILL
 #x03f2 ; "omacron") ;U+014D LATIN SMALL LETTER O WITH MACRO
 #x03f3 ; "kcedilla") ;U+0137 LATIN SMALL LETTER K WITH CEDILL
 #x03f9 ; "uogonek") ;U+0173 LATIN SMALL LETTER U WITH OGONE
 #x03fd ; "utilde") ;U+0169 LATIN SMALL LETTER U WITH TILD
 #x03fe ; "umacron") ;U+016B LATIN SMALL LETTER U WITH MACRO
 #x1001e02 ; "Babovedot") ;U+1E02 LATIN CAPITAL LETTER B WITH DOT ABOV
 #x1001e03 ; "babovedot") ;U+1E03 LATIN SMALL LETTER B WITH DOT ABOV
 #x1001e0a ; "Dabovedot") ;U+1E0A LATIN CAPITAL LETTER D WITH DOT ABOV
 #x1001e80 ; "Wgrave") ;U+1E80 LATIN CAPITAL LETTER W WITH GRAV
 #x1001e82 ; "Wacute") ;U+1E82 LATIN CAPITAL LETTER W WITH ACUT
 #x1001e0b ; "dabovedot") ;U+1E0B LATIN SMALL LETTER D WITH DOT ABOV
 #x1001ef2 ; "Ygrave") ;U+1EF2 LATIN CAPITAL LETTER Y WITH GRAV
 #x1001e1e ; "Fabovedot") ;U+1E1E LATIN CAPITAL LETTER F WITH DOT ABOV
 #x1001e1f ; "fabovedot") ;U+1E1F LATIN SMALL LETTER F WITH DOT ABOV
 #x1001e40 ; "Mabovedot") ;U+1E40 LATIN CAPITAL LETTER M WITH DOT ABOV
 #x1001e41 ; "mabovedot") ;U+1E41 LATIN SMALL LETTER M WITH DOT ABOV
 #x1001e56 ; "Pabovedot") ;U+1E56 LATIN CAPITAL LETTER P WITH DOT ABOV
 #x1001e81 ; "wgrave") ;U+1E81 LATIN SMALL LETTER W WITH GRAV
 #x1001e57 ; "pabovedot") ;U+1E57 LATIN SMALL LETTER P WITH DOT ABOV
 #x1001e83 ; "wacute") ;U+1E83 LATIN SMALL LETTER W WITH ACUT
 #x1001e60 ; "Sabovedot") ;U+1E60 LATIN CAPITAL LETTER S WITH DOT ABOV
 #x1001ef3 ; "ygrave") ;U+1EF3 LATIN SMALL LETTER Y WITH GRAV
 #x1001e84 ; "Wdiaeresis") ;U+1E84 LATIN CAPITAL LETTER W WITH DIAERESI
 #x1001e85 ; "wdiaeresis") ;U+1E85 LATIN SMALL LETTER W WITH DIAERESI
 #x1001e61 ; "sabovedot") ;U+1E61 LATIN SMALL LETTER S WITH DOT ABOV
 #x1000174 ; "Wcircumflex") ;U+0174 LATIN CAPITAL LETTER W WITH CIRCUMFLE
 #x1001e6a ; "Tabovedot") ;U+1E6A LATIN CAPITAL LETTER T WITH DOT ABOV
 #x1000176 ; "Ycircumflex") ;U+0176 LATIN CAPITAL LETTER Y WITH CIRCUMFLE
 #x1000175 ; "wcircumflex") ;U+0175 LATIN SMALL LETTER W WITH CIRCUMFLE
 #x1001e6b ; "tabovedot") ;U+1E6B LATIN SMALL LETTER T WITH DOT ABOV
 #x1000177 ; "ycircumflex") ;U+0177 LATIN SMALL LETTER Y WITH CIRCUMFLE
 #x13bc ; "OE")          ;U+0152 LATIN CAPITAL LIGATURE O
 #x13bd ; "oe")            ;U+0153 LATIN SMALL LIGATURE O
 #x13be ; "Ydiaeresis") ;U+0178 LATIN CAPITAL LETTER Y WITH DIAERESI
 #x047e ; "overline")       ;U+203E OVERLIN
 #x04a1 ; "kana_fullstop")  ;U+3002 IDEOGRAPHIC FULL STO
 #x04a2 ; "kana_openingbracket") ;U+300C LEFT CORNER BRACKE
 #x04a3 ; "kana_closingbracket") ;U+300D RIGHT CORNER BRACKE
 #x04a4 ; "kana_comma")     ;U+3001 IDEOGRAPHIC COMM
 #x04a5 ; "kana_conjunctive") ;U+30FB KATAKANA MIDDLE DO
 #x04a5 ; "kana_middledot") ;deprecate
 #x04a6 ; "kana_WO")        ;U+30F2 KATAKANA LETTER W
 #x04a7 ; "kana_a")        ;U+30A1 KATAKANA LETTER SMALL 
 #x04a8 ; "kana_i")        ;U+30A3 KATAKANA LETTER SMALL 
 #x04a9 ; "kana_u")        ;U+30A5 KATAKANA LETTER SMALL 
 #x04aa ; "kana_e")        ;U+30A7 KATAKANA LETTER SMALL 
 #x04ab ; "kana_o")        ;U+30A9 KATAKANA LETTER SMALL 
 #x04ac ; "kana_ya")      ;U+30E3 KATAKANA LETTER SMALL Y
 #x04ad ; "kana_yu")      ;U+30E5 KATAKANA LETTER SMALL Y
 #x04ae ; "kana_yo")      ;U+30E7 KATAKANA LETTER SMALL Y
 #x04af ; "kana_tsu")     ;U+30C3 KATAKANA LETTER SMALL T
 #x04af ; "kana_tu")        ;deprecate
 #x04b0 ; "prolongedsound") ;U+30FC KATAKANA-HIRAGANA PROLONGED SOUND MAR
 #x04b1 ; "kana_A")         ;U+30A2 KATAKANA LETTER 
 #x04b2 ; "kana_I")         ;U+30A4 KATAKANA LETTER 
 #x04b3 ; "kana_U")         ;U+30A6 KATAKANA LETTER 
 #x04b4 ; "kana_E")         ;U+30A8 KATAKANA LETTER 
 #x04b5 ; "kana_O")         ;U+30AA KATAKANA LETTER 
 #x04b6 ; "kana_KA")        ;U+30AB KATAKANA LETTER K
 #x04b7 ; "kana_KI")        ;U+30AD KATAKANA LETTER K
 #x04b8 ; "kana_KU")        ;U+30AF KATAKANA LETTER K
 #x04b9 ; "kana_KE")        ;U+30B1 KATAKANA LETTER K
 #x04ba ; "kana_KO")        ;U+30B3 KATAKANA LETTER K
 #x04bb ; "kana_SA")        ;U+30B5 KATAKANA LETTER S
 #x04bc ; "kana_SHI")       ;U+30B7 KATAKANA LETTER S
 #x04bd ; "kana_SU")        ;U+30B9 KATAKANA LETTER S
 #x04be ; "kana_SE")        ;U+30BB KATAKANA LETTER S
 #x04bf ; "kana_SO")        ;U+30BD KATAKANA LETTER S
 #x04c0 ; "kana_TA")        ;U+30BF KATAKANA LETTER T
 #x04c1 ; "kana_CHI")       ;U+30C1 KATAKANA LETTER T
 #x04c1 ; "kana_TI")        ;deprecate
 #x04c2 ; "kana_TSU")       ;U+30C4 KATAKANA LETTER T
 #x04c2 ; "kana_TU")        ;deprecate
 #x04c3 ; "kana_TE")        ;U+30C6 KATAKANA LETTER T
 #x04c4 ; "kana_TO")        ;U+30C8 KATAKANA LETTER T
 #x04c5 ; "kana_NA")        ;U+30CA KATAKANA LETTER N
 #x04c6 ; "kana_NI")        ;U+30CB KATAKANA LETTER N
 #x04c7 ; "kana_NU")        ;U+30CC KATAKANA LETTER N
 #x04c8 ; "kana_NE")        ;U+30CD KATAKANA LETTER N
 #x04c9 ; "kana_NO")        ;U+30CE KATAKANA LETTER N
 #x04ca ; "kana_HA")        ;U+30CF KATAKANA LETTER H
 #x04cb ; "kana_HI")        ;U+30D2 KATAKANA LETTER H
 #x04cc ; "kana_FU")        ;U+30D5 KATAKANA LETTER H
 #x04cc ; "kana_HU")        ;deprecate
 #x04cd ; "kana_HE")        ;U+30D8 KATAKANA LETTER H
 #x04ce ; "kana_HO")        ;U+30DB KATAKANA LETTER H
 #x04cf ; "kana_MA")        ;U+30DE KATAKANA LETTER M
 #x04d0 ; "kana_MI")        ;U+30DF KATAKANA LETTER M
 #x04d1 ; "kana_MU")        ;U+30E0 KATAKANA LETTER M
 #x04d2 ; "kana_ME")        ;U+30E1 KATAKANA LETTER M
 #x04d3 ; "kana_MO")        ;U+30E2 KATAKANA LETTER M
 #x04d4 ; "kana_YA")        ;U+30E4 KATAKANA LETTER Y
 #x04d5 ; "kana_YU")        ;U+30E6 KATAKANA LETTER Y
 #x04d6 ; "kana_YO")        ;U+30E8 KATAKANA LETTER Y
 #x04d7 ; "kana_RA")        ;U+30E9 KATAKANA LETTER R
 #x04d8 ; "kana_RI")        ;U+30EA KATAKANA LETTER R
 #x04d9 ; "kana_RU")        ;U+30EB KATAKANA LETTER R
 #x04da ; "kana_RE")        ;U+30EC KATAKANA LETTER R
 #x04db ; "kana_RO")        ;U+30ED KATAKANA LETTER R
 #x04dc ; "kana_WA")        ;U+30EF KATAKANA LETTER W
 #x04dd ; "kana_N")         ;U+30F3 KATAKANA LETTER 
 #x04de ; "voicedsound") ;U+309B KATAKANA-HIRAGANA VOICED SOUND MAR
 #x04df ; "semivoicedsound") ;U+309C KATAKANA-HIRAGANA SEMI-VOICED SOUND MAR
 #xff7e ; "kana_switch")    ;Alias for mode_switc
 #x10006f0 ; "Farsi_0") ;U+06F0 EXTENDED ARABIC-INDIC DIGIT ZER
 #x10006f1 ; "Farsi_1") ;U+06F1 EXTENDED ARABIC-INDIC DIGIT ON
 #x10006f2 ; "Farsi_2") ;U+06F2 EXTENDED ARABIC-INDIC DIGIT TW
 #x10006f3 ; "Farsi_3") ;U+06F3 EXTENDED ARABIC-INDIC DIGIT THRE
 #x10006f4 ; "Farsi_4") ;U+06F4 EXTENDED ARABIC-INDIC DIGIT FOU
 #x10006f5 ; "Farsi_5") ;U+06F5 EXTENDED ARABIC-INDIC DIGIT FIV
 #x10006f6 ; "Farsi_6") ;U+06F6 EXTENDED ARABIC-INDIC DIGIT SI
 #x10006f7 ; "Farsi_7") ;U+06F7 EXTENDED ARABIC-INDIC DIGIT SEVE
 #x10006f8 ; "Farsi_8") ;U+06F8 EXTENDED ARABIC-INDIC DIGIT EIGH
 #x10006f9 ; "Farsi_9") ;U+06F9 EXTENDED ARABIC-INDIC DIGIT NIN
 #x100066a ; "Arabic_percent") ;U+066A ARABIC PERCENT SIG
 #x1000670 ; "Arabic_superscript_alef") ;U+0670 ARABIC LETTER SUPERSCRIPT ALE
 #x1000679 ; "Arabic_tteh") ;U+0679 ARABIC LETTER TTE
 #x100067e ; "Arabic_peh")  ;U+067E ARABIC LETTER PE
 #x1000686 ; "Arabic_tcheh") ;U+0686 ARABIC LETTER TCHE
 #x1000688 ; "Arabic_ddal") ;U+0688 ARABIC LETTER DDA
 #x1000691 ; "Arabic_rreh") ;U+0691 ARABIC LETTER RRE
 #x05ac ; "Arabic_comma")   ;U+060C ARABIC COMM
 #x10006d4 ; "Arabic_fullstop") ;U+06D4 ARABIC FULL STO
 #x1000660 ; "Arabic_0")   ;U+0660 ARABIC-INDIC DIGIT ZER
 #x1000661 ; "Arabic_1")    ;U+0661 ARABIC-INDIC DIGIT ON
 #x1000662 ; "Arabic_2")    ;U+0662 ARABIC-INDIC DIGIT TW
 #x1000663 ; "Arabic_3")  ;U+0663 ARABIC-INDIC DIGIT THRE
 #x1000664 ; "Arabic_4")   ;U+0664 ARABIC-INDIC DIGIT FOU
 #x1000665 ; "Arabic_5")   ;U+0665 ARABIC-INDIC DIGIT FIV
 #x1000666 ; "Arabic_6")    ;U+0666 ARABIC-INDIC DIGIT SI
 #x1000667 ; "Arabic_7")  ;U+0667 ARABIC-INDIC DIGIT SEVE
 #x1000668 ; "Arabic_8")  ;U+0668 ARABIC-INDIC DIGIT EIGH
 #x1000669 ; "Arabic_9")   ;U+0669 ARABIC-INDIC DIGIT NIN
 #x05bb ; "Arabic_semicolon") ;U+061B ARABIC SEMICOLO
 #x05bf ; "Arabic_question_mark") ;U+061F ARABIC QUESTION MAR
 #x05c1 ; "Arabic_hamza")   ;U+0621 ARABIC LETTER HAMZ
 #x05c2 ; "Arabic_maddaonalef") ;U+0622 ARABIC LETTER ALEF WITH MADDA ABOV
 #x05c3 ; "Arabic_hamzaonalef") ;U+0623 ARABIC LETTER ALEF WITH HAMZA ABOV
 #x05c4 ; "Arabic_hamzaonwaw") ;U+0624 ARABIC LETTER WAW WITH HAMZA ABOV
 #x05c5 ; "Arabic_hamzaunderalef") ;U+0625 ARABIC LETTER ALEF WITH HAMZA BELO
 #x05c6 ; "Arabic_hamzaonyeh") ;U+0626 ARABIC LETTER YEH WITH HAMZA ABOV
 #x05c7 ; "Arabic_alef")    ;U+0627 ARABIC LETTER ALE
 #x05c8 ; "Arabic_beh")     ;U+0628 ARABIC LETTER BE
 #x05c9 ; "Arabic_tehmarbuta") ;U+0629 ARABIC LETTER TEH MARBUT
 #x05ca ; "Arabic_teh")     ;U+062A ARABIC LETTER TE
 #x05cb ; "Arabic_theh")    ;U+062B ARABIC LETTER THE
 #x05cc ; "Arabic_jeem")    ;U+062C ARABIC LETTER JEE
 #x05cd ; "Arabic_hah")     ;U+062D ARABIC LETTER HA
 #x05ce ; "Arabic_khah")    ;U+062E ARABIC LETTER KHA
 #x05cf ; "Arabic_dal")     ;U+062F ARABIC LETTER DA
 #x05d0 ; "Arabic_thal")    ;U+0630 ARABIC LETTER THA
 #x05d1 ; "Arabic_ra")      ;U+0631 ARABIC LETTER RE
 #x05d2 ; "Arabic_zain")    ;U+0632 ARABIC LETTER ZAI
 #x05d3 ; "Arabic_seen")    ;U+0633 ARABIC LETTER SEE
 #x05d4 ; "Arabic_sheen")   ;U+0634 ARABIC LETTER SHEE
 #x05d5 ; "Arabic_sad")     ;U+0635 ARABIC LETTER SA
 #x05d6 ; "Arabic_dad")     ;U+0636 ARABIC LETTER DA
 #x05d7 ; "Arabic_tah")     ;U+0637 ARABIC LETTER TA
 #x05d8 ; "Arabic_zah")     ;U+0638 ARABIC LETTER ZA
 #x05d9 ; "Arabic_ain")     ;U+0639 ARABIC LETTER AI
 #x05da ; "Arabic_ghain")   ;U+063A ARABIC LETTER GHAI
 #x05e0 ; "Arabic_tatweel") ;U+0640 ARABIC TATWEE
 #x05e1 ; "Arabic_feh")     ;U+0641 ARABIC LETTER FE
 #x05e2 ; "Arabic_qaf")     ;U+0642 ARABIC LETTER QA
 #x05e3 ; "Arabic_kaf")     ;U+0643 ARABIC LETTER KA
 #x05e4 ; "Arabic_lam")     ;U+0644 ARABIC LETTER LA
 #x05e5 ; "Arabic_meem")    ;U+0645 ARABIC LETTER MEE
 #x05e6 ; "Arabic_noon")    ;U+0646 ARABIC LETTER NOO
 #x05e7 ; "Arabic_ha")      ;U+0647 ARABIC LETTER HE
 #x05e7 ; "Arabic_heh")     ;deprecate
 #x05e8 ; "Arabic_waw")     ;U+0648 ARABIC LETTER WA
 #x05e9 ; "Arabic_alefmaksura") ;U+0649 ARABIC LETTER ALEF MAKSUR
 #x05ea ; "Arabic_yeh")     ;U+064A ARABIC LETTER YE
 #x05eb ; "Arabic_fathatan") ;U+064B ARABIC FATHATA
 #x05ec ; "Arabic_dammatan") ;U+064C ARABIC DAMMATA
 #x05ed ; "Arabic_kasratan") ;U+064D ARABIC KASRATA
 #x05ee ; "Arabic_fatha")   ;U+064E ARABIC FATH
 #x05ef ; "Arabic_damma")   ;U+064F ARABIC DAMM
 #x05f0 ; "Arabic_kasra")   ;U+0650 ARABIC KASR
 #x05f1 ; "Arabic_shadda")  ;U+0651 ARABIC SHADD
 #x05f2 ; "Arabic_sukun")   ;U+0652 ARABIC SUKU
 #x1000653 ; "Arabic_madda_above") ;U+0653 ARABIC MADDAH ABOV
 #x1000654 ; "Arabic_hamza_above") ;U+0654 ARABIC HAMZA ABOV
 #x1000655 ; "Arabic_hamza_below") ;U+0655 ARABIC HAMZA BELO
 #x1000698 ; "Arabic_jeh")  ;U+0698 ARABIC LETTER JE
 #x10006a4 ; "Arabic_veh")  ;U+06A4 ARABIC LETTER VE
 #x10006a9 ; "Arabic_keheh") ;U+06A9 ARABIC LETTER KEHE
 #x10006af ; "Arabic_gaf")  ;U+06AF ARABIC LETTER GA
 #x10006ba ; "Arabic_noon_ghunna") ;U+06BA ARABIC LETTER NOON GHUNN
 #x10006be ; "Arabic_heh_doachashmee") ;U+06BE ARABIC LETTER HEH DOACHASHME
 #x10006cc ; "Farsi_yeh")  ;U+06CC ARABIC LETTER FARSI YE
 #x10006cc ; "Arabic_farsi_yeh") ;U+06CC ARABIC LETTER FARSI YE
 #x10006d2 ; "Arabic_yeh_baree") ;U+06D2 ARABIC LETTER YEH BARRE
 #x10006c1 ; "Arabic_heh_goal") ;U+06C1 ARABIC LETTER HEH GOA
 #xff7e ; "Arabic_switch")  ;Alias for mode_switc
 #x1000492 ; "Cyrillic_GHE_bar") ;U+0492 CYRILLIC CAPITAL LETTER GHE WITH STROK
 #x1000493 ; "Cyrillic_ghe_bar") ;U+0493 CYRILLIC SMALL LETTER GHE WITH STROK
 #x1000496 ; "Cyrillic_ZHE_descender") ;U+0496 CYRILLIC CAPITAL LETTER ZHE WITH DESCENDE
 #x1000497 ; "Cyrillic_zhe_descender") ;U+0497 CYRILLIC SMALL LETTER ZHE WITH DESCENDE
 #x100049a ; "Cyrillic_KA_descender") ;U+049A CYRILLIC CAPITAL LETTER KA WITH DESCENDE
 #x100049b ; "Cyrillic_ka_descender") ;U+049B CYRILLIC SMALL LETTER KA WITH DESCENDE
 #x100049c ; "Cyrillic_KA_vertstroke") ;U+049C CYRILLIC CAPITAL LETTER KA WITH VERTICAL STROK
 #x100049d ; "Cyrillic_ka_vertstroke") ;U+049D CYRILLIC SMALL LETTER KA WITH VERTICAL STROK
 #x10004a2 ; "Cyrillic_EN_descender") ;U+04A2 CYRILLIC CAPITAL LETTER EN WITH DESCENDE
 #x10004a3 ; "Cyrillic_en_descender") ;U+04A3 CYRILLIC SMALL LETTER EN WITH DESCENDE
 #x10004ae ; "Cyrillic_U_straight") ;U+04AE CYRILLIC CAPITAL LETTER STRAIGHT 
 #x10004af ; "Cyrillic_u_straight") ;U+04AF CYRILLIC SMALL LETTER STRAIGHT 
 #x10004b0 ; "Cyrillic_U_straight_bar") ;U+04B0 CYRILLIC CAPITAL LETTER STRAIGHT U WITH STROK
 #x10004b1 ; "Cyrillic_u_straight_bar") ;U+04B1 CYRILLIC SMALL LETTER STRAIGHT U WITH STROK
 #x10004b2 ; "Cyrillic_HA_descender") ;U+04B2 CYRILLIC CAPITAL LETTER HA WITH DESCENDE
 #x10004b3 ; "Cyrillic_ha_descender") ;U+04B3 CYRILLIC SMALL LETTER HA WITH DESCENDE
 #x10004b6 ; "Cyrillic_CHE_descender") ;U+04B6 CYRILLIC CAPITAL LETTER CHE WITH DESCENDE
 #x10004b7 ; "Cyrillic_che_descender") ;U+04B7 CYRILLIC SMALL LETTER CHE WITH DESCENDE
 #x10004b8 ; "Cyrillic_CHE_vertstroke") ;U+04B8 CYRILLIC CAPITAL LETTER CHE WITH VERTICAL STROK
 #x10004b9 ; "Cyrillic_che_vertstroke") ;U+04B9 CYRILLIC SMALL LETTER CHE WITH VERTICAL STROK
 #x10004ba ; "Cyrillic_SHHA") ;U+04BA CYRILLIC CAPITAL LETTER SHH
 #x10004bb ; "Cyrillic_shha") ;U+04BB CYRILLIC SMALL LETTER SHH
 #x10004d8 ; "Cyrillic_SCHWA") ;U+04D8 CYRILLIC CAPITAL LETTER SCHW
 #x10004d9 ; "Cyrillic_schwa") ;U+04D9 CYRILLIC SMALL LETTER SCHW
 #x10004e2 ; "Cyrillic_I_macron") ;U+04E2 CYRILLIC CAPITAL LETTER I WITH MACRO
 #x10004e3 ; "Cyrillic_i_macron") ;U+04E3 CYRILLIC SMALL LETTER I WITH MACRO
 #x10004e8 ; "Cyrillic_O_bar") ;U+04E8 CYRILLIC CAPITAL LETTER BARRED 
 #x10004e9 ; "Cyrillic_o_bar") ;U+04E9 CYRILLIC SMALL LETTER BARRED 
 #x10004ee ; "Cyrillic_U_macron") ;U+04EE CYRILLIC CAPITAL LETTER U WITH MACRO
 #x10004ef ; "Cyrillic_u_macron") ;U+04EF CYRILLIC SMALL LETTER U WITH MACRO
 #x06a1 ; "Serbian_dje") ;U+0452 CYRILLIC SMALL LETTER DJ
 #x06a2 ; "Macedonia_gje") ;U+0453 CYRILLIC SMALL LETTER GJ
 #x06a3 ; "Cyrillic_io")  ;U+0451 CYRILLIC SMALL LETTER I
 #x06a4 ; "Ukrainian_ie") ;U+0454 CYRILLIC SMALL LETTER UKRAINIAN I
 #x06a4 ; "Ukranian_je")    ;deprecate
 #x06a5 ; "Macedonia_dse") ;U+0455 CYRILLIC SMALL LETTER DZ
 #x06a6 ; "Ukrainian_i") ;U+0456 CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN 
 #x06a6 ; "Ukranian_i")     ;deprecate
 #x06a7 ; "Ukrainian_yi") ;U+0457 CYRILLIC SMALL LETTER Y
 #x06a7 ; "Ukranian_yi")    ;deprecate
 #x06a8 ; "Cyrillic_je")  ;U+0458 CYRILLIC SMALL LETTER J
 #x06a8 ; "Serbian_je")     ;deprecate
 #x06a9 ; "Cyrillic_lje") ;U+0459 CYRILLIC SMALL LETTER LJ
 #x06a9 ; "Serbian_lje")    ;deprecate
 #x06aa ; "Cyrillic_nje") ;U+045A CYRILLIC SMALL LETTER NJ
 #x06aa ; "Serbian_nje")    ;deprecate
 #x06ab ; "Serbian_tshe") ;U+045B CYRILLIC SMALL LETTER TSH
 #x06ac ; "Macedonia_kje") ;U+045C CYRILLIC SMALL LETTER KJ
 #x06ad ; "Ukrainian_ghe_with_upturn") ;U+0491 CYRILLIC SMALL LETTER GHE WITH UPTUR
 #x06ae ; "Byelorussian_shortu") ;U+045E CYRILLIC SMALL LETTER SHORT 
 #x06af ; "Cyrillic_dzhe") ;U+045F CYRILLIC SMALL LETTER DZH
 #x06af ; "Serbian_dze")    ;deprecate
 #x06b0 ; "numerosign")     ;U+2116 NUMERO SIG
 #x06b1 ; "Serbian_DJE") ;U+0402 CYRILLIC CAPITAL LETTER DJ
 #x06b2 ; "Macedonia_GJE") ;U+0403 CYRILLIC CAPITAL LETTER GJ
 #x06b3 ; "Cyrillic_IO") ;U+0401 CYRILLIC CAPITAL LETTER I
 #x06b4 ; "Ukrainian_IE") ;U+0404 CYRILLIC CAPITAL LETTER UKRAINIAN I
 #x06b4 ; "Ukranian_JE")    ;deprecate
 #x06b5 ; "Macedonia_DSE") ;U+0405 CYRILLIC CAPITAL LETTER DZ
 #x06b6 ; "Ukrainian_I") ;U+0406 CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN 
 #x06b6 ; "Ukranian_I")     ;deprecate
 #x06b7 ; "Ukrainian_YI") ;U+0407 CYRILLIC CAPITAL LETTER Y
 #x06b7 ; "Ukranian_YI")    ;deprecate
 #x06b8 ; "Cyrillic_JE") ;U+0408 CYRILLIC CAPITAL LETTER J
 #x06b8 ; "Serbian_JE")     ;deprecate
 #x06b9 ; "Cyrillic_LJE") ;U+0409 CYRILLIC CAPITAL LETTER LJ
 #x06b9 ; "Serbian_LJE")    ;deprecate
 #x06ba ; "Cyrillic_NJE") ;U+040A CYRILLIC CAPITAL LETTER NJ
 #x06ba ; "Serbian_NJE")    ;deprecate
 #x06bb ; "Serbian_TSHE") ;U+040B CYRILLIC CAPITAL LETTER TSH
 #x06bc ; "Macedonia_KJE") ;U+040C CYRILLIC CAPITAL LETTER KJ
 #x06bd ; "Ukrainian_GHE_WITH_UPTURN") ;U+0490 CYRILLIC CAPITAL LETTER GHE WITH UPTUR
 #x06be ; "Byelorussian_SHORTU") ;U+040E CYRILLIC CAPITAL LETTER SHORT 
 #x06bf ; "Cyrillic_DZHE") ;U+040F CYRILLIC CAPITAL LETTER DZH
 #x06bf ; "Serbian_DZE")    ;deprecate
 #x06c0 ; "Cyrillic_yu")  ;U+044E CYRILLIC SMALL LETTER Y
 #x06c1 ; "Cyrillic_a")    ;U+0430 CYRILLIC SMALL LETTER 
 #x06c2 ; "Cyrillic_be")  ;U+0431 CYRILLIC SMALL LETTER B
 #x06c3 ; "Cyrillic_tse") ;U+0446 CYRILLIC SMALL LETTER TS
 #x06c4 ; "Cyrillic_de")  ;U+0434 CYRILLIC SMALL LETTER D
 #x06c5 ; "Cyrillic_ie")  ;U+0435 CYRILLIC SMALL LETTER I
 #x06c6 ; "Cyrillic_ef")  ;U+0444 CYRILLIC SMALL LETTER E
 #x06c7 ; "Cyrillic_ghe") ;U+0433 CYRILLIC SMALL LETTER GH
 #x06c8 ; "Cyrillic_ha")  ;U+0445 CYRILLIC SMALL LETTER H
 #x06c9 ; "Cyrillic_i")    ;U+0438 CYRILLIC SMALL LETTER 
 #x06ca ; "Cyrillic_shorti") ;U+0439 CYRILLIC SMALL LETTER SHORT 
 #x06cb ; "Cyrillic_ka")  ;U+043A CYRILLIC SMALL LETTER K
 #x06cc ; "Cyrillic_el")  ;U+043B CYRILLIC SMALL LETTER E
 #x06cd ; "Cyrillic_em")  ;U+043C CYRILLIC SMALL LETTER E
 #x06ce ; "Cyrillic_en")  ;U+043D CYRILLIC SMALL LETTER E
 #x06cf ; "Cyrillic_o")    ;U+043E CYRILLIC SMALL LETTER 
 #x06d0 ; "Cyrillic_pe")  ;U+043F CYRILLIC SMALL LETTER P
 #x06d1 ; "Cyrillic_ya")  ;U+044F CYRILLIC SMALL LETTER Y
 #x06d2 ; "Cyrillic_er")  ;U+0440 CYRILLIC SMALL LETTER E
 #x06d3 ; "Cyrillic_es")  ;U+0441 CYRILLIC SMALL LETTER E
 #x06d4 ; "Cyrillic_te")  ;U+0442 CYRILLIC SMALL LETTER T
 #x06d5 ; "Cyrillic_u")    ;U+0443 CYRILLIC SMALL LETTER 
 #x06d6 ; "Cyrillic_zhe") ;U+0436 CYRILLIC SMALL LETTER ZH
 #x06d7 ; "Cyrillic_ve")  ;U+0432 CYRILLIC SMALL LETTER V
 #x06d8 ; "Cyrillic_softsign") ;U+044C CYRILLIC SMALL LETTER SOFT SIG
 #x06d9 ; "Cyrillic_yeru") ;U+044B CYRILLIC SMALL LETTER YER
 #x06da ; "Cyrillic_ze")  ;U+0437 CYRILLIC SMALL LETTER Z
 #x06db ; "Cyrillic_sha") ;U+0448 CYRILLIC SMALL LETTER SH
 #x06dc ; "Cyrillic_e")    ;U+044D CYRILLIC SMALL LETTER 
 #x06dd ; "Cyrillic_shcha") ;U+0449 CYRILLIC SMALL LETTER SHCH
 #x06de ; "Cyrillic_che") ;U+0447 CYRILLIC SMALL LETTER CH
 #x06df ; "Cyrillic_hardsign") ;U+044A CYRILLIC SMALL LETTER HARD SIG
 #x06e0 ; "Cyrillic_YU") ;U+042E CYRILLIC CAPITAL LETTER Y
 #x06e1 ; "Cyrillic_A")  ;U+0410 CYRILLIC CAPITAL LETTER 
 #x06e2 ; "Cyrillic_BE") ;U+0411 CYRILLIC CAPITAL LETTER B
 #x06e3 ; "Cyrillic_TSE") ;U+0426 CYRILLIC CAPITAL LETTER TS
 #x06e4 ; "Cyrillic_DE") ;U+0414 CYRILLIC CAPITAL LETTER D
 #x06e5 ; "Cyrillic_IE") ;U+0415 CYRILLIC CAPITAL LETTER I
 #x06e6 ; "Cyrillic_EF") ;U+0424 CYRILLIC CAPITAL LETTER E
 #x06e7 ; "Cyrillic_GHE") ;U+0413 CYRILLIC CAPITAL LETTER GH
 #x06e8 ; "Cyrillic_HA") ;U+0425 CYRILLIC CAPITAL LETTER H
 #x06e9 ; "Cyrillic_I")  ;U+0418 CYRILLIC CAPITAL LETTER 
 #x06ea ; "Cyrillic_SHORTI") ;U+0419 CYRILLIC CAPITAL LETTER SHORT 
 #x06eb ; "Cyrillic_KA") ;U+041A CYRILLIC CAPITAL LETTER K
 #x06ec ; "Cyrillic_EL") ;U+041B CYRILLIC CAPITAL LETTER E
 #x06ed ; "Cyrillic_EM") ;U+041C CYRILLIC CAPITAL LETTER E
 #x06ee ; "Cyrillic_EN") ;U+041D CYRILLIC CAPITAL LETTER E
 #x06ef ; "Cyrillic_O")  ;U+041E CYRILLIC CAPITAL LETTER 
 #x06f0 ; "Cyrillic_PE") ;U+041F CYRILLIC CAPITAL LETTER P
 #x06f1 ; "Cyrillic_YA") ;U+042F CYRILLIC CAPITAL LETTER Y
 #x06f2 ; "Cyrillic_ER") ;U+0420 CYRILLIC CAPITAL LETTER E
 #x06f3 ; "Cyrillic_ES") ;U+0421 CYRILLIC CAPITAL LETTER E
 #x06f4 ; "Cyrillic_TE") ;U+0422 CYRILLIC CAPITAL LETTER T
 #x06f5 ; "Cyrillic_U")  ;U+0423 CYRILLIC CAPITAL LETTER 
 #x06f6 ; "Cyrillic_ZHE") ;U+0416 CYRILLIC CAPITAL LETTER ZH
 #x06f7 ; "Cyrillic_VE") ;U+0412 CYRILLIC CAPITAL LETTER V
 #x06f8 ; "Cyrillic_SOFTSIGN") ;U+042C CYRILLIC CAPITAL LETTER SOFT SIG
 #x06f9 ; "Cyrillic_YERU") ;U+042B CYRILLIC CAPITAL LETTER YER
 #x06fa ; "Cyrillic_ZE") ;U+0417 CYRILLIC CAPITAL LETTER Z
 #x06fb ; "Cyrillic_SHA") ;U+0428 CYRILLIC CAPITAL LETTER SH
 #x06fc ; "Cyrillic_E")  ;U+042D CYRILLIC CAPITAL LETTER 
 #x06fd ; "Cyrillic_SHCHA") ;U+0429 CYRILLIC CAPITAL LETTER SHCH
 #x06fe ; "Cyrillic_CHE") ;U+0427 CYRILLIC CAPITAL LETTER CH
 #x06ff ; "Cyrillic_HARDSIGN") ;U+042A CYRILLIC CAPITAL LETTER HARD SIG
 #x07a1 ; "Greek_ALPHAaccent") ;U+0386 GREEK CAPITAL LETTER ALPHA WITH TONO
 #x07a2 ; "Greek_EPSILONaccent") ;U+0388 GREEK CAPITAL LETTER EPSILON WITH TONO
 #x07a3 ; "Greek_ETAaccent") ;U+0389 GREEK CAPITAL LETTER ETA WITH TONO
 #x07a4 ; "Greek_IOTAaccent") ;U+038A GREEK CAPITAL LETTER IOTA WITH TONO
 #x07a5 ; "Greek_IOTAdieresis") ;U+03AA GREEK CAPITAL LETTER IOTA WITH DIALYTIK
 #x07a5 ; "Greek_IOTAdiaeresis") ;old typ
 #x07a7 ; "Greek_OMICRONaccent") ;U+038C GREEK CAPITAL LETTER OMICRON WITH TONO
 #x07a8 ; "Greek_UPSILONaccent") ;U+038E GREEK CAPITAL LETTER UPSILON WITH TONO
 #x07a9 ; "Greek_UPSILONdieresis") ;U+03AB GREEK CAPITAL LETTER UPSILON WITH DIALYTIK
 #x07ab ; "Greek_OMEGAaccent") ;U+038F GREEK CAPITAL LETTER OMEGA WITH TONO
 #x07ae ; "Greek_accentdieresis") ;U+0385 GREEK DIALYTIKA TONO
 #x07af ; "Greek_horizbar") ;U+2015 HORIZONTAL BA
 #x07b1 ; "Greek_alphaaccent") ;U+03AC GREEK SMALL LETTER ALPHA WITH TONO
 #x07b2 ; "Greek_epsilonaccent") ;U+03AD GREEK SMALL LETTER EPSILON WITH TONO
 #x07b3 ; "Greek_etaaccent") ;U+03AE GREEK SMALL LETTER ETA WITH TONO
 #x07b4 ; "Greek_iotaaccent") ;U+03AF GREEK SMALL LETTER IOTA WITH TONO
 #x07b5 ; "Greek_iotadieresis") ;U+03CA GREEK SMALL LETTER IOTA WITH DIALYTIK
 #x07b6 ; "Greek_iotaaccentdieresis") ;U+0390 GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONO
 #x07b7 ; "Greek_omicronaccent") ;U+03CC GREEK SMALL LETTER OMICRON WITH TONO
 #x07b8 ; "Greek_upsilonaccent") ;U+03CD GREEK SMALL LETTER UPSILON WITH TONO
 #x07b9 ; "Greek_upsilondieresis") ;U+03CB GREEK SMALL LETTER UPSILON WITH DIALYTIK
 #x07ba ; "Greek_upsilonaccentdieresis") ;U+03B0 GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONO
 #x07bb ; "Greek_omegaaccent") ;U+03CE GREEK SMALL LETTER OMEGA WITH TONO
 #x07c1 ; "Greek_ALPHA") ;U+0391 GREEK CAPITAL LETTER ALPH
 #x07c2 ; "Greek_BETA")  ;U+0392 GREEK CAPITAL LETTER BET
 #x07c3 ; "Greek_GAMMA") ;U+0393 GREEK CAPITAL LETTER GAMM
 #x07c4 ; "Greek_DELTA") ;U+0394 GREEK CAPITAL LETTER DELT
 #x07c5 ; "Greek_EPSILON") ;U+0395 GREEK CAPITAL LETTER EPSILO
 #x07c6 ; "Greek_ZETA")  ;U+0396 GREEK CAPITAL LETTER ZET
 #x07c7 ; "Greek_ETA")    ;U+0397 GREEK CAPITAL LETTER ET
 #x07c8 ; "Greek_THETA") ;U+0398 GREEK CAPITAL LETTER THET
 #x07c9 ; "Greek_IOTA")  ;U+0399 GREEK CAPITAL LETTER IOT
 #x07ca ; "Greek_KAPPA") ;U+039A GREEK CAPITAL LETTER KAPP
 #x07cb ; "Greek_LAMDA") ;U+039B GREEK CAPITAL LETTER LAMD
 #x07cb ; "Greek_LAMBDA") ;U+039B GREEK CAPITAL LETTER LAMD
 #x07cc ; "Greek_MU")      ;U+039C GREEK CAPITAL LETTER M
 #x07cd ; "Greek_NU")      ;U+039D GREEK CAPITAL LETTER N
 #x07ce ; "Greek_XI")      ;U+039E GREEK CAPITAL LETTER X
 #x07cf ; "Greek_OMICRON") ;U+039F GREEK CAPITAL LETTER OMICRO
 #x07d0 ; "Greek_PI")      ;U+03A0 GREEK CAPITAL LETTER P
 #x07d1 ; "Greek_RHO")    ;U+03A1 GREEK CAPITAL LETTER RH
 #x07d2 ; "Greek_SIGMA") ;U+03A3 GREEK CAPITAL LETTER SIGM
 #x07d4 ; "Greek_TAU")    ;U+03A4 GREEK CAPITAL LETTER TA
 #x07d5 ; "Greek_UPSILON") ;U+03A5 GREEK CAPITAL LETTER UPSILO
 #x07d6 ; "Greek_PHI")    ;U+03A6 GREEK CAPITAL LETTER PH
 #x07d7 ; "Greek_CHI")    ;U+03A7 GREEK CAPITAL LETTER CH
 #x07d8 ; "Greek_PSI")    ;U+03A8 GREEK CAPITAL LETTER PS
 #x07d9 ; "Greek_OMEGA") ;U+03A9 GREEK CAPITAL LETTER OMEG
 #x07e1 ; "Greek_alpha")  ;U+03B1 GREEK SMALL LETTER ALPH
 #x07e2 ; "Greek_beta")    ;U+03B2 GREEK SMALL LETTER BET
 #x07e3 ; "Greek_gamma")  ;U+03B3 GREEK SMALL LETTER GAMM
 #x07e4 ; "Greek_delta")  ;U+03B4 GREEK SMALL LETTER DELT
 #x07e5 ; "Greek_epsilon") ;U+03B5 GREEK SMALL LETTER EPSILO
 #x07e6 ; "Greek_zeta")    ;U+03B6 GREEK SMALL LETTER ZET
 #x07e7 ; "Greek_eta")      ;U+03B7 GREEK SMALL LETTER ET
 #x07e8 ; "Greek_theta")  ;U+03B8 GREEK SMALL LETTER THET
 #x07e9 ; "Greek_iota")    ;U+03B9 GREEK SMALL LETTER IOT
 #x07ea ; "Greek_kappa")  ;U+03BA GREEK SMALL LETTER KAPP
 #x07eb ; "Greek_lamda")  ;U+03BB GREEK SMALL LETTER LAMD
 #x07eb ; "Greek_lambda") ;U+03BB GREEK SMALL LETTER LAMD
 #x07ec ; "Greek_mu")       ;U+03BC GREEK SMALL LETTER M
 #x07ed ; "Greek_nu")       ;U+03BD GREEK SMALL LETTER N
 #x07ee ; "Greek_xi")       ;U+03BE GREEK SMALL LETTER X
 #x07ef ; "Greek_omicron") ;U+03BF GREEK SMALL LETTER OMICRO
 #x07f0 ; "Greek_pi")       ;U+03C0 GREEK SMALL LETTER P
 #x07f1 ; "Greek_rho")      ;U+03C1 GREEK SMALL LETTER RH
 #x07f2 ; "Greek_sigma")  ;U+03C3 GREEK SMALL LETTER SIGM
 #x07f3 ; "Greek_finalsmallsigma") ;U+03C2 GREEK SMALL LETTER FINAL SIGM
 #x07f4 ; "Greek_tau")      ;U+03C4 GREEK SMALL LETTER TA
 #x07f5 ; "Greek_upsilon") ;U+03C5 GREEK SMALL LETTER UPSILO
 #x07f6 ; "Greek_phi")      ;U+03C6 GREEK SMALL LETTER PH
 #x07f7 ; "Greek_chi")      ;U+03C7 GREEK SMALL LETTER CH
 #x07f8 ; "Greek_psi")      ;U+03C8 GREEK SMALL LETTER PS
 #x07f9 ; "Greek_omega")  ;U+03C9 GREEK SMALL LETTER OMEG
 #xff7e ; "Greek_switch")   ;Alias for mode_switc
 #x08a1 ; "leftradical")    ;U+23B7 RADICAL SYMBOL BOTTO
 #x08a2 ; "topleftradical") ;(U+250C BOX DRAWINGS LIGHT DOWN AND RIGHT
 #x08a3 ; "horizconnector") ;(U+2500 BOX DRAWINGS LIGHT HORIZONTAL
 #x08a4 ; "topintegral")    ;U+2320 TOP HALF INTEGRA
 #x08a5 ; "botintegral")    ;U+2321 BOTTOM HALF INTEGRA
 #x08a6 ; "vertconnector") ;(U+2502 BOX DRAWINGS LIGHT VERTICAL
 #x08a7 ; "topleftsqbracket") ;U+23A1 LEFT SQUARE BRACKET UPPER CORNE
 #x08a8 ; "botleftsqbracket") ;U+23A3 LEFT SQUARE BRACKET LOWER CORNE
 #x08a9 ; "toprightsqbracket") ;U+23A4 RIGHT SQUARE BRACKET UPPER CORNE
 #x08aa ; "botrightsqbracket") ;U+23A6 RIGHT SQUARE BRACKET LOWER CORNE
 #x08ab ; "topleftparens") ;U+239B LEFT PARENTHESIS UPPER HOO
 #x08ac ; "botleftparens") ;U+239D LEFT PARENTHESIS LOWER HOO
 #x08ad ; "toprightparens") ;U+239E RIGHT PARENTHESIS UPPER HOO
 #x08ae ; "botrightparens") ;U+23A0 RIGHT PARENTHESIS LOWER HOO
 #x08af ; "leftmiddlecurlybrace") ;U+23A8 LEFT CURLY BRACKET MIDDLE PIEC
 #x08b0 ; "rightmiddlecurlybrace") ;U+23AC RIGHT CURLY BRACKET MIDDLE PIEC
 #x08b1 ; "topleftsummation"
 #x08b2 ; "botleftsummation"
 #x08b3 ; "topvertsummationconnector"
 #x08b4 ; "botvertsummationconnector"
 #x08b5 ; "toprightsummation"
 #x08b6 ; "botrightsummation"
 #x08b7 ; "rightmiddlesummation"
 #x08bc ; "lessthanequal")  ;U+2264 LESS-THAN OR EQUAL T
 #x08bd ; "notequal")       ;U+2260 NOT EQUAL T
 #x08be ; "greaterthanequal") ;U+2265 GREATER-THAN OR EQUAL T
 #x08bf ; "integral")       ;U+222B INTEGRA
 #x08c0 ; "therefore")      ;U+2234 THEREFOR
 #x08c1 ; "variation")      ;U+221D PROPORTIONAL T
 #x08c2 ; "infinity")       ;U+221E INFINIT
 #x08c5 ; "nabla")          ;U+2207 NABL
 #x08c8 ; "approximate")    ;U+223C TILDE OPERATO
 #x08c9 ; "similarequal")  ;U+2243 ASYMPTOTICALLY EQUAL T
 #x08cd ; "ifonlyif")      ;U+21D4 LEFT RIGHT DOUBLE ARRO
 #x08ce ; "implies")       ;U+21D2 RIGHTWARDS DOUBLE ARRO
 #x08cf ; "identical")      ;U+2261 IDENTICAL T
 #x08d6 ; "radical")        ;U+221A SQUARE ROO
 #x08da ; "includedin")     ;U+2282 SUBSET O
 #x08db ; "includes")       ;U+2283 SUPERSET O
 #x08dc ; "intersection")   ;U+2229 INTERSECTIO
 #x08dd ; "union")          ;U+222A UNIO
 #x08de ; "logicaland")     ;U+2227 LOGICAL AN
 #x08df ; "logicalor")      ;U+2228 LOGICAL O
 #x08ef ; "partialderivative") ;U+2202 PARTIAL DIFFERENTIA
 #x08f6 ; "function") ;U+0192 LATIN SMALL LETTER F WITH HOO
 #x08fb ; "leftarrow")      ;U+2190 LEFTWARDS ARRO
 #x08fc ; "uparrow")        ;U+2191 UPWARDS ARRO
 #x08fd ; "rightarrow")     ;U+2192 RIGHTWARDS ARRO
 #x08fe ; "downarrow")      ;U+2193 DOWNWARDS ARRO
 #x09df ; "blank"
 #x09e0 ; "soliddiamond")   ;U+25C6 BLACK DIAMON
 #x09e1 ; "checkerboard")   ;U+2592 MEDIUM SHAD
 #x09e2 ; "ht")   ;U+2409 SYMBOL FOR HORIZONTAL TABULATIO
 #x09e3 ; "ff")             ;U+240C SYMBOL FOR FORM FEE
 #x09e4 ; "cr")         ;U+240D SYMBOL FOR CARRIAGE RETUR
 #x09e5 ; "lf")             ;U+240A SYMBOL FOR LINE FEE
 #x09e8 ; "nl")             ;U+2424 SYMBOL FOR NEWLIN
 #x09e9 ; "vt")     ;U+240B SYMBOL FOR VERTICAL TABULATIO
 #x09ea ; "lowrightcorner") ;U+2518 BOX DRAWINGS LIGHT UP AND LEF
 #x09eb ; "uprightcorner") ;U+2510 BOX DRAWINGS LIGHT DOWN AND LEF
 #x09ec ; "upleftcorner") ;U+250C BOX DRAWINGS LIGHT DOWN AND RIGH
 #x09ed ; "lowleftcorner") ;U+2514 BOX DRAWINGS LIGHT UP AND RIGH
 #x09ee ; "crossinglines") ;U+253C BOX DRAWINGS LIGHT VERTICAL AND HORIZONTA
 #x09ef ; "horizlinescan1") ;U+23BA HORIZONTAL SCAN LINE-
 #x09f0 ; "horizlinescan3") ;U+23BB HORIZONTAL SCAN LINE-
 #x09f1 ; "horizlinescan5") ;U+2500 BOX DRAWINGS LIGHT HORIZONTA
 #x09f2 ; "horizlinescan7") ;U+23BC HORIZONTAL SCAN LINE-
 #x09f3 ; "horizlinescan9") ;U+23BD HORIZONTAL SCAN LINE-
 #x09f4 ; "leftt") ;U+251C BOX DRAWINGS LIGHT VERTICAL AND RIGH
 #x09f5 ; "rightt") ;U+2524 BOX DRAWINGS LIGHT VERTICAL AND LEF
 #x09f6 ; "bott") ;U+2534 BOX DRAWINGS LIGHT UP AND HORIZONTA
 #x09f7 ; "topt") ;U+252C BOX DRAWINGS LIGHT DOWN AND HORIZONTA
 #x09f8 ; "vertbar")   ;U+2502 BOX DRAWINGS LIGHT VERTICA
 #x0aa1 ; "emspace")        ;U+2003 EM SPAC
 #x0aa2 ; "enspace")        ;U+2002 EN SPAC
 #x0aa3 ; "em3space")       ;U+2004 THREE-PER-EM SPAC
 #x0aa4 ; "em4space")       ;U+2005 FOUR-PER-EM SPAC
 #x0aa5 ; "digitspace")     ;U+2007 FIGURE SPAC
 #x0aa6 ; "punctspace")     ;U+2008 PUNCTUATION SPAC
 #x0aa7 ; "thinspace")      ;U+2009 THIN SPAC
 #x0aa8 ; "hairspace")      ;U+200A HAIR SPAC
 #x0aa9 ; "emdash")         ;U+2014 EM DAS
 #x0aaa ; "endash")         ;U+2013 EN DAS
 #x0aac ; "signifblank")    ;(U+2423 OPEN BOX
 #x0aae ; "ellipsis")       ;U+2026 HORIZONTAL ELLIPSI
 #x0aaf ; "doubbaselinedot") ;U+2025 TWO DOT LEADE
 #x0ab0 ; "onethird")    ;U+2153 VULGAR FRACTION ONE THIR
 #x0ab1 ; "twothirds")  ;U+2154 VULGAR FRACTION TWO THIRD
 #x0ab2 ; "onefifth")    ;U+2155 VULGAR FRACTION ONE FIFT
 #x0ab3 ; "twofifths")  ;U+2156 VULGAR FRACTION TWO FIFTH
 #x0ab4 ; "threefifths") ;U+2157 VULGAR FRACTION THREE FIFTH
 #x0ab5 ; "fourfifths") ;U+2158 VULGAR FRACTION FOUR FIFTH
 #x0ab6 ; "onesixth")    ;U+2159 VULGAR FRACTION ONE SIXT
 #x0ab7 ; "fivesixths") ;U+215A VULGAR FRACTION FIVE SIXTH
 #x0ab8 ; "careof")         ;U+2105 CARE O
 #x0abb ; "figdash")        ;U+2012 FIGURE DAS
 #x0abc ; "leftanglebracket") ;(U+27E8 MATHEMATICAL LEFT ANGLE BRACKET
 #x0abd ; "decimalpoint")   ;(U+002E FULL STOP
 #x0abe ; "rightanglebracket") ;(U+27E9 MATHEMATICAL RIGHT ANGLE BRACKET
 #x0abf ; "marker"
 #x0ac3 ; "oneeighth")  ;U+215B VULGAR FRACTION ONE EIGHT
 #x0ac4 ; "threeeighths") ;U+215C VULGAR FRACTION THREE EIGHTH
 #x0ac5 ; "fiveeighths") ;U+215D VULGAR FRACTION FIVE EIGHTH
 #x0ac6 ; "seveneighths") ;U+215E VULGAR FRACTION SEVEN EIGHTH
 #x0ac9 ; "trademark")      ;U+2122 TRADE MARK SIG
 #x0aca ; "signaturemark")  ;(U+2613 SALTIRE
 #x0acb ; "trademarkincircle"
 #x0acc ; "leftopentriangle") ;(U+25C1 WHITE LEFT-POINTING TRIANGLE
 #x0acd ; "rightopentriangle") ;(U+25B7 WHITE RIGHT-POINTING TRIANGLE
 #x0ace ; "emopencircle")   ;(U+25CB WHITE CIRCLE
 #x0acf ; "emopenrectangle") ;(U+25AF WHITE VERTICAL RECTANGLE
 #x0ad0 ; "leftsinglequotemark") ;U+2018 LEFT SINGLE QUOTATION MAR
 #x0ad1 ; "rightsinglequotemark") ;U+2019 RIGHT SINGLE QUOTATION MAR
 #x0ad2 ; "leftdoublequotemark") ;U+201C LEFT DOUBLE QUOTATION MAR
 #x0ad3 ; "rightdoublequotemark") ;U+201D RIGHT DOUBLE QUOTATION MAR
 #x0ad4 ; "prescription")   ;U+211E PRESCRIPTION TAK
 #x0ad6 ; "minutes")        ;U+2032 PRIM
 #x0ad7 ; "seconds")        ;U+2033 DOUBLE PRIM
 #x0ad9 ; "latincross")     ;U+271D LATIN CROS
 #x0ada ; "hexagram"
 #x0adb ; "filledrectbullet") ;(U+25AC BLACK RECTANGLE
 #x0adc ; "filledlefttribullet") ;(U+25C0 BLACK LEFT-POINTING TRIANGLE
 #x0add ; "filledrighttribullet") ;(U+25B6 BLACK RIGHT-POINTING TRIANGLE
 #x0ade ; "emfilledcircle") ;(U+25CF BLACK CIRCLE
 #x0adf ; "emfilledrect") ;(U+25AE BLACK VERTICAL RECTANGLE
 #x0ae0 ; "enopencircbullet") ;(U+25E6 WHITE BULLET
 #x0ae1 ; "enopensquarebullet") ;(U+25AB WHITE SMALL SQUARE
 #x0ae2 ; "openrectbullet") ;(U+25AD WHITE RECTANGLE
 #x0ae3 ; "opentribulletup") ;(U+25B3 WHITE UP-POINTING TRIANGLE
 #x0ae4 ; "opentribulletdown") ;(U+25BD WHITE DOWN-POINTING TRIANGLE
 #x0ae5 ; "openstar")       ;(U+2606 WHITE STAR
 #x0ae6 ; "enfilledcircbullet") ;(U+2022 BULLET
 #x0ae7 ; "enfilledsqbullet") ;(U+25AA BLACK SMALL SQUARE
 #x0ae8 ; "filledtribulletup") ;(U+25B2 BLACK UP-POINTING TRIANGLE
 #x0ae9 ; "filledtribulletdown") ;(U+25BC BLACK DOWN-POINTING TRIANGLE
 #x0aea ; "leftpointer") ;(U+261C WHITE LEFT POINTING INDEX
 #x0aeb ; "rightpointer") ;(U+261E WHITE RIGHT POINTING INDEX
 #x0aec ; "club")           ;U+2663 BLACK CLUB SUI
 #x0aed ; "diamond")        ;U+2666 BLACK DIAMOND SUI
 #x0aee ; "heart")          ;U+2665 BLACK HEART SUI
 #x0af0 ; "maltesecross")   ;U+2720 MALTESE CROS
 #x0af1 ; "dagger")         ;U+2020 DAGGE
 #x0af2 ; "doubledagger")   ;U+2021 DOUBLE DAGGE
 #x0af3 ; "checkmark")      ;U+2713 CHECK MAR
 #x0af4 ; "ballotcross")    ;U+2717 BALLOT 
 #x0af5 ; "musicalsharp")   ;U+266F MUSIC SHARP SIG
 #x0af6 ; "musicalflat")    ;U+266D MUSIC FLAT SIG
 #x0af7 ; "malesymbol")     ;U+2642 MALE SIG
 #x0af8 ; "femalesymbol")   ;U+2640 FEMALE SIG
 #x0af9 ; "telephone")      ;U+260E BLACK TELEPHON
 #x0afa ; "telephonerecorder") ;U+2315 TELEPHONE RECORDE
 #x0afb ; "phonographcopyright") ;U+2117 SOUND RECORDING COPYRIGH
 #x0afc ; "caret")          ;U+2038 CARE
 #x0afd ; "singlelowquotemark") ;U+201A SINGLE LOW-9 QUOTATION MAR
 #x0afe ; "doublelowquotemark") ;U+201E DOUBLE LOW-9 QUOTATION MAR
 #x0aff ; "cursor"
 #x0ba3 ; "leftcaret")      ;(U+003C LESS-THAN SIGN
 #x0ba6 ; "rightcaret")     ;(U+003E GREATER-THAN SIGN
 #x0ba8 ; "downcaret")      ;(U+2228 LOGICAL OR
 #x0ba9 ; "upcaret")        ;(U+2227 LOGICAL AND
 #x0bc0 ; "overbar")        ;(U+00AF MACRON
 #x0bc2 ; "downtack")       ;U+22A5 UP TAC
 #x0bc3 ; "upshoe")         ;(U+2229 INTERSECTION
 #x0bc4 ; "downstile")      ;U+230A LEFT FLOO
 #x0bc6 ; "underbar")       ;(U+005F LOW LINE
 #x0bca ; "jot")            ;U+2218 RING OPERATO
 #x0bcc ; "quad")       ;U+2395 APL FUNCTIONAL SYMBOL QUA
 #x0bce ; "uptack")         ;U+22A4 DOWN TAC
 #x0bcf ; "circle")         ;U+25CB WHITE CIRCL
 #x0bd3 ; "upstile")        ;U+2308 LEFT CEILIN
 #x0bd6 ; "downshoe")       ;(U+222A UNION
 #x0bd8 ; "rightshoe")      ;(U+2283 SUPERSET OF
 #x0bda ; "leftshoe")       ;(U+2282 SUBSET OF
 #x0bdc ; "lefttack")       ;U+22A2 RIGHT TAC
 #x0bfc ; "righttack")      ;U+22A3 LEFT TAC
 #x0cdf ; "hebrew_doublelowline") ;U+2017 DOUBLE LOW LIN
 #x0ce0 ; "hebrew_aleph")   ;U+05D0 HEBREW LETTER ALE
 #x0ce1 ; "hebrew_bet")     ;U+05D1 HEBREW LETTER BE
 #x0ce1 ; "hebrew_beth")    ;deprecate
 #x0ce2 ; "hebrew_gimel")   ;U+05D2 HEBREW LETTER GIME
 #x0ce2 ; "hebrew_gimmel")  ;deprecate
 #x0ce3 ; "hebrew_dalet")   ;U+05D3 HEBREW LETTER DALE
 #x0ce3 ; "hebrew_daleth")  ;deprecate
 #x0ce4 ; "hebrew_he")      ;U+05D4 HEBREW LETTER H
 #x0ce5 ; "hebrew_waw")     ;U+05D5 HEBREW LETTER VA
 #x0ce6 ; "hebrew_zain")    ;U+05D6 HEBREW LETTER ZAYI
 #x0ce6 ; "hebrew_zayin")   ;deprecate
 #x0ce7 ; "hebrew_chet")    ;U+05D7 HEBREW LETTER HE
 #x0ce7 ; "hebrew_het")     ;deprecate
 #x0ce8 ; "hebrew_tet")     ;U+05D8 HEBREW LETTER TE
 #x0ce8 ; "hebrew_teth")    ;deprecate
 #x0ce9 ; "hebrew_yod")     ;U+05D9 HEBREW LETTER YO
 #x0cea ; "hebrew_finalkaph") ;U+05DA HEBREW LETTER FINAL KA
 #x0ceb ; "hebrew_kaph")    ;U+05DB HEBREW LETTER KA
 #x0cec ; "hebrew_lamed")   ;U+05DC HEBREW LETTER LAME
 #x0ced ; "hebrew_finalmem") ;U+05DD HEBREW LETTER FINAL ME
 #x0cee ; "hebrew_mem")     ;U+05DE HEBREW LETTER ME
 #x0cef ; "hebrew_finalnun") ;U+05DF HEBREW LETTER FINAL NU
 #x0cf0 ; "hebrew_nun")     ;U+05E0 HEBREW LETTER NU
 #x0cf1 ; "hebrew_samech")  ;U+05E1 HEBREW LETTER SAMEK
 #x0cf1 ; "hebrew_samekh")  ;deprecate
 #x0cf2 ; "hebrew_ayin")    ;U+05E2 HEBREW LETTER AYI
 #x0cf3 ; "hebrew_finalpe") ;U+05E3 HEBREW LETTER FINAL P
 #x0cf4 ; "hebrew_pe")      ;U+05E4 HEBREW LETTER P
 #x0cf5 ; "hebrew_finalzade") ;U+05E5 HEBREW LETTER FINAL TSAD
 #x0cf5 ; "hebrew_finalzadi") ;deprecate
 #x0cf6 ; "hebrew_zade")    ;U+05E6 HEBREW LETTER TSAD
 #x0cf6 ; "hebrew_zadi")    ;deprecate
 #x0cf7 ; "hebrew_qoph")    ;U+05E7 HEBREW LETTER QO
 #x0cf7 ; "hebrew_kuf")     ;deprecate
 #x0cf8 ; "hebrew_resh")    ;U+05E8 HEBREW LETTER RES
 #x0cf9 ; "hebrew_shin")    ;U+05E9 HEBREW LETTER SHI
 #x0cfa ; "hebrew_taw")     ;U+05EA HEBREW LETTER TA
 #x0cfa ; "hebrew_taf")     ;deprecate
 #xff7e ; "Hebrew_switch")  ;Alias for mode_switc
 #x0da1 ; "Thai_kokai")     ;U+0E01 THAI CHARACTER KO KA
 #x0da2 ; "Thai_khokhai")  ;U+0E02 THAI CHARACTER KHO KHA
 #x0da3 ; "Thai_khokhuat") ;U+0E03 THAI CHARACTER KHO KHUA
 #x0da4 ; "Thai_khokhwai") ;U+0E04 THAI CHARACTER KHO KHWA
 #x0da5 ; "Thai_khokhon")  ;U+0E05 THAI CHARACTER KHO KHO
 #x0da6 ; "Thai_khorakhang") ;U+0E06 THAI CHARACTER KHO RAKHAN
 #x0da7 ; "Thai_ngongu")    ;U+0E07 THAI CHARACTER NGO NG
 #x0da8 ; "Thai_chochan")  ;U+0E08 THAI CHARACTER CHO CHA
 #x0da9 ; "Thai_choching") ;U+0E09 THAI CHARACTER CHO CHIN
 #x0daa ; "Thai_chochang") ;U+0E0A THAI CHARACTER CHO CHAN
 #x0dab ; "Thai_soso")      ;U+0E0B THAI CHARACTER SO S
 #x0dac ; "Thai_chochoe")  ;U+0E0C THAI CHARACTER CHO CHO
 #x0dad ; "Thai_yoying")    ;U+0E0D THAI CHARACTER YO YIN
 #x0dae ; "Thai_dochada")  ;U+0E0E THAI CHARACTER DO CHAD
 #x0daf ; "Thai_topatak")  ;U+0E0F THAI CHARACTER TO PATA
 #x0db0 ; "Thai_thothan")  ;U+0E10 THAI CHARACTER THO THA
 #x0db1 ; "Thai_thonangmontho") ;U+0E11 THAI CHARACTER THO NANGMONTH
 #x0db2 ; "Thai_thophuthao") ;U+0E12 THAI CHARACTER THO PHUTHA
 #x0db3 ; "Thai_nonen")     ;U+0E13 THAI CHARACTER NO NE
 #x0db4 ; "Thai_dodek")     ;U+0E14 THAI CHARACTER DO DE
 #x0db5 ; "Thai_totao")     ;U+0E15 THAI CHARACTER TO TA
 #x0db6 ; "Thai_thothung") ;U+0E16 THAI CHARACTER THO THUN
 #x0db7 ; "Thai_thothahan") ;U+0E17 THAI CHARACTER THO THAHA
 #x0db8 ; "Thai_thothong") ;U+0E18 THAI CHARACTER THO THON
 #x0db9 ; "Thai_nonu")      ;U+0E19 THAI CHARACTER NO N
 #x0dba ; "Thai_bobaimai") ;U+0E1A THAI CHARACTER BO BAIMA
 #x0dbb ; "Thai_popla")     ;U+0E1B THAI CHARACTER PO PL
 #x0dbc ; "Thai_phophung") ;U+0E1C THAI CHARACTER PHO PHUN
 #x0dbd ; "Thai_fofa")      ;U+0E1D THAI CHARACTER FO F
 #x0dbe ; "Thai_phophan")  ;U+0E1E THAI CHARACTER PHO PHA
 #x0dbf ; "Thai_fofan")     ;U+0E1F THAI CHARACTER FO FA
 #x0dc0 ; "Thai_phosamphao") ;U+0E20 THAI CHARACTER PHO SAMPHA
 #x0dc1 ; "Thai_moma")      ;U+0E21 THAI CHARACTER MO M
 #x0dc2 ; "Thai_yoyak")     ;U+0E22 THAI CHARACTER YO YA
 #x0dc3 ; "Thai_rorua")     ;U+0E23 THAI CHARACTER RO RU
 #x0dc4 ; "Thai_ru")        ;U+0E24 THAI CHARACTER R
 #x0dc5 ; "Thai_loling")    ;U+0E25 THAI CHARACTER LO LIN
 #x0dc6 ; "Thai_lu")        ;U+0E26 THAI CHARACTER L
 #x0dc7 ; "Thai_wowaen")    ;U+0E27 THAI CHARACTER WO WAE
 #x0dc8 ; "Thai_sosala")    ;U+0E28 THAI CHARACTER SO SAL
 #x0dc9 ; "Thai_sorusi")    ;U+0E29 THAI CHARACTER SO RUS
 #x0dca ; "Thai_sosua")     ;U+0E2A THAI CHARACTER SO SU
 #x0dcb ; "Thai_hohip")     ;U+0E2B THAI CHARACTER HO HI
 #x0dcc ; "Thai_lochula")  ;U+0E2C THAI CHARACTER LO CHUL
 #x0dcd ; "Thai_oang")      ;U+0E2D THAI CHARACTER O AN
 #x0dce ; "Thai_honokhuk") ;U+0E2E THAI CHARACTER HO NOKHU
 #x0dcf ; "Thai_paiyannoi") ;U+0E2F THAI CHARACTER PAIYANNO
 #x0dd0 ; "Thai_saraa")     ;U+0E30 THAI CHARACTER SARA 
 #x0dd1 ; "Thai_maihanakat") ;U+0E31 THAI CHARACTER MAI HAN-AKA
 #x0dd2 ; "Thai_saraaa")    ;U+0E32 THAI CHARACTER SARA A
 #x0dd3 ; "Thai_saraam")    ;U+0E33 THAI CHARACTER SARA A
 #x0dd4 ; "Thai_sarai")     ;U+0E34 THAI CHARACTER SARA 
 #x0dd5 ; "Thai_saraii")    ;U+0E35 THAI CHARACTER SARA I
 #x0dd6 ; "Thai_saraue")    ;U+0E36 THAI CHARACTER SARA U
 #x0dd7 ; "Thai_sarauee")  ;U+0E37 THAI CHARACTER SARA UE
 #x0dd8 ; "Thai_sarau")     ;U+0E38 THAI CHARACTER SARA 
 #x0dd9 ; "Thai_sarauu")    ;U+0E39 THAI CHARACTER SARA U
 #x0dda ; "Thai_phinthu")   ;U+0E3A THAI CHARACTER PHINTH
 #x0dde ; "Thai_maihanakat_maitho"
 #x0ddf ; "Thai_baht")   ;U+0E3F THAI CURRENCY SYMBOL BAH
 #x0de0 ; "Thai_sarae")     ;U+0E40 THAI CHARACTER SARA 
 #x0de1 ; "Thai_saraae")    ;U+0E41 THAI CHARACTER SARA A
 #x0de2 ; "Thai_sarao")     ;U+0E42 THAI CHARACTER SARA 
 #x0de3 ; "Thai_saraaimaimuan") ;U+0E43 THAI CHARACTER SARA AI MAIMUA
 #x0de4 ; "Thai_saraaimaimalai") ;U+0E44 THAI CHARACTER SARA AI MAIMALA
 #x0de5 ; "Thai_lakkhangyao") ;U+0E45 THAI CHARACTER LAKKHANGYA
 #x0de6 ; "Thai_maiyamok") ;U+0E46 THAI CHARACTER MAIYAMO
 #x0de7 ; "Thai_maitaikhu") ;U+0E47 THAI CHARACTER MAITAIKH
 #x0de8 ; "Thai_maiek")     ;U+0E48 THAI CHARACTER MAI E
 #x0de9 ; "Thai_maitho")    ;U+0E49 THAI CHARACTER MAI TH
 #x0dea ; "Thai_maitri")    ;U+0E4A THAI CHARACTER MAI TR
 #x0deb ; "Thai_maichattawa") ;U+0E4B THAI CHARACTER MAI CHATTAW
 #x0dec ; "Thai_thanthakhat") ;U+0E4C THAI CHARACTER THANTHAKHA
 #x0ded ; "Thai_nikhahit") ;U+0E4D THAI CHARACTER NIKHAHI
 #x0df0 ; "Thai_leksun")    ;U+0E50 THAI DIGIT ZER
 #x0df1 ; "Thai_leknung")   ;U+0E51 THAI DIGIT ON
 #x0df2 ; "Thai_leksong")   ;U+0E52 THAI DIGIT TW
 #x0df3 ; "Thai_leksam")    ;U+0E53 THAI DIGIT THRE
 #x0df4 ; "Thai_leksi")     ;U+0E54 THAI DIGIT FOU
 #x0df5 ; "Thai_lekha")     ;U+0E55 THAI DIGIT FIV
 #x0df6 ; "Thai_lekhok")    ;U+0E56 THAI DIGIT SI
 #x0df7 ; "Thai_lekchet")   ;U+0E57 THAI DIGIT SEVE
 #x0df8 ; "Thai_lekpaet")   ;U+0E58 THAI DIGIT EIGH
 #x0df9 ; "Thai_lekkao")    ;U+0E59 THAI DIGIT NIN
 #xff31 ; "Hangul")         ;Hangul start/stop(toggle
 #xff32 ; "Hangul_Start")   ;Hangul star
 #xff33 ; "Hangul_End")     ;Hangul end, English star
 #xff34 ; "Hangul_Hanja")  ;Start Hangul->Hanja Conversio
 #xff35 ; "Hangul_Jamo")    ;Hangul Jamo mod
 #xff36 ; "Hangul_Romaja")  ;Hangul Romaja mod
 #xff37 ; "Hangul_Codeinput") ;Hangul code input mod
 #xff38 ; "Hangul_Jeonja")  ;Jeonja mod
 #xff39 ; "Hangul_Banja")   ;Banja mod
 #xff3a ; "Hangul_PreHanja") ;Pre Hanja conversio
 #xff3b ; "Hangul_PostHanja") ;Post Hanja conversio
 #xff3c ; "Hangul_SingleCandidate") ;Single candidat
 #xff3d ; "Hangul_MultipleCandidate") ;Multiple candidat
 #xff3e ; "Hangul_PreviousCandidate") ;Previous candidat
 #xff3f ; "Hangul_Special") ;Special symbol
 #xff7e ; "Hangul_switch")  ;Alias for mode_switc
 #x0ea1 ; "Hangul_Kiyeog"
 #x0ea2 ; "Hangul_SsangKiyeog"
 #x0ea3 ; "Hangul_KiyeogSios"
 #x0ea4 ; "Hangul_Nieun"
 #x0ea5 ; "Hangul_NieunJieuj"
 #x0ea6 ; "Hangul_NieunHieuh"
 #x0ea7 ; "Hangul_Dikeud"
 #x0ea8 ; "Hangul_SsangDikeud"
 #x0ea9 ; "Hangul_Rieul"
 #x0eaa ; "Hangul_RieulKiyeog"
 #x0eab ; "Hangul_RieulMieum"
 #x0eac ; "Hangul_RieulPieub"
 #x0ead ; "Hangul_RieulSios"
 #x0eae ; "Hangul_RieulTieut"
 #x0eaf ; "Hangul_RieulPhieuf"
 #x0eb0 ; "Hangul_RieulHieuh"
 #x0eb1 ; "Hangul_Mieum"
 #x0eb2 ; "Hangul_Pieub"
 #x0eb3 ; "Hangul_SsangPieub"
 #x0eb4 ; "Hangul_PieubSios"
 #x0eb5 ; "Hangul_Sios"
 #x0eb6 ; "Hangul_SsangSios"
 #x0eb7 ; "Hangul_Ieung"
 #x0eb8 ; "Hangul_Jieuj"
 #x0eb9 ; "Hangul_SsangJieuj"
 #x0eba ; "Hangul_Cieuc"
 #x0ebb ; "Hangul_Khieuq"
 #x0ebc ; "Hangul_Tieut"
 #x0ebd ; "Hangul_Phieuf"
 #x0ebe ; "Hangul_Hieuh"
 #x0ebf ; "Hangul_A"
 #x0ec0 ; "Hangul_AE"
 #x0ec1 ; "Hangul_YA"
 #x0ec2 ; "Hangul_YAE"
 #x0ec3 ; "Hangul_EO"
 #x0ec4 ; "Hangul_E"
 #x0ec5 ; "Hangul_YEO"
 #x0ec6 ; "Hangul_YE"
 #x0ec7 ; "Hangul_O"
 #x0ec8 ; "Hangul_WA"
 #x0ec9 ; "Hangul_WAE"
 #x0eca ; "Hangul_OE"
 #x0ecb ; "Hangul_YO"
 #x0ecc ; "Hangul_U"
 #x0ecd ; "Hangul_WEO"
 #x0ece ; "Hangul_WE"
 #x0ecf ; "Hangul_WI"
 #x0ed0 ; "Hangul_YU"
 #x0ed1 ; "Hangul_EU"
 #x0ed2 ; "Hangul_YI"
 #x0ed3 ; "Hangul_I"
 #x0ed4 ; "Hangul_J_Kiyeog"
 #x0ed5 ; "Hangul_J_SsangKiyeog"
 #x0ed6 ; "Hangul_J_KiyeogSios"
 #x0ed7 ; "Hangul_J_Nieun"
 #x0ed8 ; "Hangul_J_NieunJieuj"
 #x0ed9 ; "Hangul_J_NieunHieuh"
 #x0eda ; "Hangul_J_Dikeud"
 #x0edb ; "Hangul_J_Rieul"
 #x0edc ; "Hangul_J_RieulKiyeog"
 #x0edd ; "Hangul_J_RieulMieum"
 #x0ede ; "Hangul_J_RieulPieub"
 #x0edf ; "Hangul_J_RieulSios"
 #x0ee0 ; "Hangul_J_RieulTieut"
 #x0ee1 ; "Hangul_J_RieulPhieuf"
 #x0ee2 ; "Hangul_J_RieulHieuh"
 #x0ee3 ; "Hangul_J_Mieum"
 #x0ee4 ; "Hangul_J_Pieub"
 #x0ee5 ; "Hangul_J_PieubSios"
 #x0ee6 ; "Hangul_J_Sios"
 #x0ee7 ; "Hangul_J_SsangSios"
 #x0ee8 ; "Hangul_J_Ieung"
 #x0ee9 ; "Hangul_J_Jieuj"
 #x0eea ; "Hangul_J_Cieuc"
 #x0eeb ; "Hangul_J_Khieuq"
 #x0eec ; "Hangul_J_Tieut"
 #x0eed ; "Hangul_J_Phieuf"
 #x0eee ; "Hangul_J_Hieuh"
 #x0eef ; "Hangul_RieulYeorinHieuh"
 #x0ef0 ; "Hangul_SunkyeongeumMieum"
 #x0ef1 ; "Hangul_SunkyeongeumPieub"
 #x0ef2 ; "Hangul_PanSios"
 #x0ef3 ; "Hangul_KkogjiDalrinIeung"
 #x0ef4 ; "Hangul_SunkyeongeumPhieuf"
 #x0ef5 ; "Hangul_YeorinHieuh"
 #x0ef6 ; "Hangul_AraeA"
 #x0ef7 ; "Hangul_AraeAE"
 #x0ef8 ; "Hangul_J_PanSios"
 #x0ef9 ; "Hangul_J_KkogjiDalrinIeung"
 #x0efa ; "Hangul_J_YeorinHieuh"
 #x0eff ; "Korean_Won")     ;(U+20A9 WON SIGN
 #x1000587 ; "Armenian_ligature_ew") ;U+0587 ARMENIAN SMALL LIGATURE ECH YIW
 #x1000589 ; "Armenian_full_stop") ;U+0589 ARMENIAN FULL STO
 #x1000589 ; "Armenian_verjaket") ;U+0589 ARMENIAN FULL STO
 #x100055d ; "Armenian_separation_mark") ;U+055D ARMENIAN COMM
 #x100055d ; "Armenian_but") ;U+055D ARMENIAN COMM
 #x100058a ; "Armenian_hyphen") ;U+058A ARMENIAN HYPHE
 #x100058a ; "Armenian_yentamna") ;U+058A ARMENIAN HYPHE
 #x100055c ; "Armenian_exclam") ;U+055C ARMENIAN EXCLAMATION MAR
 #x100055c ; "Armenian_amanak") ;U+055C ARMENIAN EXCLAMATION MAR
 #x100055b ; "Armenian_accent") ;U+055B ARMENIAN EMPHASIS MAR
 #x100055b ; "Armenian_shesht") ;U+055B ARMENIAN EMPHASIS MAR
 #x100055e ; "Armenian_question") ;U+055E ARMENIAN QUESTION MAR
 #x100055e ; "Armenian_paruyk") ;U+055E ARMENIAN QUESTION MAR
 #x1000531 ; "Armenian_AYB") ;U+0531 ARMENIAN CAPITAL LETTER AY
 #x1000561 ; "Armenian_ayb") ;U+0561 ARMENIAN SMALL LETTER AY
 #x1000532 ; "Armenian_BEN") ;U+0532 ARMENIAN CAPITAL LETTER BE
 #x1000562 ; "Armenian_ben") ;U+0562 ARMENIAN SMALL LETTER BE
 #x1000533 ; "Armenian_GIM") ;U+0533 ARMENIAN CAPITAL LETTER GI
 #x1000563 ; "Armenian_gim") ;U+0563 ARMENIAN SMALL LETTER GI
 #x1000534 ; "Armenian_DA") ;U+0534 ARMENIAN CAPITAL LETTER D
 #x1000564 ; "Armenian_da") ;U+0564 ARMENIAN SMALL LETTER D
 #x1000535 ; "Armenian_YECH") ;U+0535 ARMENIAN CAPITAL LETTER EC
 #x1000565 ; "Armenian_yech") ;U+0565 ARMENIAN SMALL LETTER EC
 #x1000536 ; "Armenian_ZA") ;U+0536 ARMENIAN CAPITAL LETTER Z
 #x1000566 ; "Armenian_za") ;U+0566 ARMENIAN SMALL LETTER Z
 #x1000537 ; "Armenian_E") ;U+0537 ARMENIAN CAPITAL LETTER E
 #x1000567 ; "Armenian_e") ;U+0567 ARMENIAN SMALL LETTER E
 #x1000538 ; "Armenian_AT") ;U+0538 ARMENIAN CAPITAL LETTER E
 #x1000568 ; "Armenian_at") ;U+0568 ARMENIAN SMALL LETTER E
 #x1000539 ; "Armenian_TO") ;U+0539 ARMENIAN CAPITAL LETTER T
 #x1000569 ; "Armenian_to") ;U+0569 ARMENIAN SMALL LETTER T
 #x100053a ; "Armenian_ZHE") ;U+053A ARMENIAN CAPITAL LETTER ZH
 #x100056a ; "Armenian_zhe") ;U+056A ARMENIAN SMALL LETTER ZH
 #x100053b ; "Armenian_INI") ;U+053B ARMENIAN CAPITAL LETTER IN
 #x100056b ; "Armenian_ini") ;U+056B ARMENIAN SMALL LETTER IN
 #x100053c ; "Armenian_LYUN") ;U+053C ARMENIAN CAPITAL LETTER LIW
 #x100056c ; "Armenian_lyun") ;U+056C ARMENIAN SMALL LETTER LIW
 #x100053d ; "Armenian_KHE") ;U+053D ARMENIAN CAPITAL LETTER XE
 #x100056d ; "Armenian_khe") ;U+056D ARMENIAN SMALL LETTER XE
 #x100053e ; "Armenian_TSA") ;U+053E ARMENIAN CAPITAL LETTER C
 #x100056e ; "Armenian_tsa") ;U+056E ARMENIAN SMALL LETTER C
 #x100053f ; "Armenian_KEN") ;U+053F ARMENIAN CAPITAL LETTER KE
 #x100056f ; "Armenian_ken") ;U+056F ARMENIAN SMALL LETTER KE
 #x1000540 ; "Armenian_HO") ;U+0540 ARMENIAN CAPITAL LETTER H
 #x1000570 ; "Armenian_ho") ;U+0570 ARMENIAN SMALL LETTER H
 #x1000541 ; "Armenian_DZA") ;U+0541 ARMENIAN CAPITAL LETTER J
 #x1000571 ; "Armenian_dza") ;U+0571 ARMENIAN SMALL LETTER J
 #x1000542 ; "Armenian_GHAT") ;U+0542 ARMENIAN CAPITAL LETTER GHA
 #x1000572 ; "Armenian_ghat") ;U+0572 ARMENIAN SMALL LETTER GHA
 #x1000543 ; "Armenian_TCHE") ;U+0543 ARMENIAN CAPITAL LETTER CHE
 #x1000573 ; "Armenian_tche") ;U+0573 ARMENIAN SMALL LETTER CHE
 #x1000544 ; "Armenian_MEN") ;U+0544 ARMENIAN CAPITAL LETTER ME
 #x1000574 ; "Armenian_men") ;U+0574 ARMENIAN SMALL LETTER ME
 #x1000545 ; "Armenian_HI") ;U+0545 ARMENIAN CAPITAL LETTER Y
 #x1000575 ; "Armenian_hi") ;U+0575 ARMENIAN SMALL LETTER Y
 #x1000546 ; "Armenian_NU") ;U+0546 ARMENIAN CAPITAL LETTER NO
 #x1000576 ; "Armenian_nu") ;U+0576 ARMENIAN SMALL LETTER NO
 #x1000547 ; "Armenian_SHA") ;U+0547 ARMENIAN CAPITAL LETTER SH
 #x1000577 ; "Armenian_sha") ;U+0577 ARMENIAN SMALL LETTER SH
 #x1000548 ; "Armenian_VO") ;U+0548 ARMENIAN CAPITAL LETTER V
 #x1000578 ; "Armenian_vo") ;U+0578 ARMENIAN SMALL LETTER V
 #x1000549 ; "Armenian_CHA") ;U+0549 ARMENIAN CAPITAL LETTER CH
 #x1000579 ; "Armenian_cha") ;U+0579 ARMENIAN SMALL LETTER CH
 #x100054a ; "Armenian_PE") ;U+054A ARMENIAN CAPITAL LETTER PE
 #x100057a ; "Armenian_pe") ;U+057A ARMENIAN SMALL LETTER PE
 #x100054b ; "Armenian_JE") ;U+054B ARMENIAN CAPITAL LETTER JHE
 #x100057b ; "Armenian_je") ;U+057B ARMENIAN SMALL LETTER JHE
 #x100054c ; "Armenian_RA") ;U+054C ARMENIAN CAPITAL LETTER R
 #x100057c ; "Armenian_ra") ;U+057C ARMENIAN SMALL LETTER R
 #x100054d ; "Armenian_SE") ;U+054D ARMENIAN CAPITAL LETTER SE
 #x100057d ; "Armenian_se") ;U+057D ARMENIAN SMALL LETTER SE
 #x100054e ; "Armenian_VEV") ;U+054E ARMENIAN CAPITAL LETTER VE
 #x100057e ; "Armenian_vev") ;U+057E ARMENIAN SMALL LETTER VE
 #x100054f ; "Armenian_TYUN") ;U+054F ARMENIAN CAPITAL LETTER TIW
 #x100057f ; "Armenian_tyun") ;U+057F ARMENIAN SMALL LETTER TIW
 #x1000550 ; "Armenian_RE") ;U+0550 ARMENIAN CAPITAL LETTER RE
 #x1000580 ; "Armenian_re") ;U+0580 ARMENIAN SMALL LETTER RE
 #x1000551 ; "Armenian_TSO") ;U+0551 ARMENIAN CAPITAL LETTER C
 #x1000581 ; "Armenian_tso") ;U+0581 ARMENIAN SMALL LETTER C
 #x1000552 ; "Armenian_VYUN") ;U+0552 ARMENIAN CAPITAL LETTER YIW
 #x1000582 ; "Armenian_vyun") ;U+0582 ARMENIAN SMALL LETTER YIW
 #x1000553 ; "Armenian_PYUR") ;U+0553 ARMENIAN CAPITAL LETTER PIW
 #x1000583 ; "Armenian_pyur") ;U+0583 ARMENIAN SMALL LETTER PIW
 #x1000554 ; "Armenian_KE") ;U+0554 ARMENIAN CAPITAL LETTER KE
 #x1000584 ; "Armenian_ke") ;U+0584 ARMENIAN SMALL LETTER KE
 #x1000555 ; "Armenian_O") ;U+0555 ARMENIAN CAPITAL LETTER O
 #x1000585 ; "Armenian_o") ;U+0585 ARMENIAN SMALL LETTER O
 #x1000556 ; "Armenian_FE") ;U+0556 ARMENIAN CAPITAL LETTER FE
 #x1000586 ; "Armenian_fe") ;U+0586 ARMENIAN SMALL LETTER FE
 #x100055a ; "Armenian_apostrophe") ;U+055A ARMENIAN APOSTROPH
 #x10010d0 ; "Georgian_an") ;U+10D0 GEORGIAN LETTER A
 #x10010d1 ; "Georgian_ban") ;U+10D1 GEORGIAN LETTER BA
 #x10010d2 ; "Georgian_gan") ;U+10D2 GEORGIAN LETTER GA
 #x10010d3 ; "Georgian_don") ;U+10D3 GEORGIAN LETTER DO
 #x10010d4 ; "Georgian_en") ;U+10D4 GEORGIAN LETTER E
 #x10010d5 ; "Georgian_vin") ;U+10D5 GEORGIAN LETTER VI
 #x10010d6 ; "Georgian_zen") ;U+10D6 GEORGIAN LETTER ZE
 #x10010d7 ; "Georgian_tan") ;U+10D7 GEORGIAN LETTER TA
 #x10010d8 ; "Georgian_in") ;U+10D8 GEORGIAN LETTER I
 #x10010d9 ; "Georgian_kan") ;U+10D9 GEORGIAN LETTER KA
 #x10010da ; "Georgian_las") ;U+10DA GEORGIAN LETTER LA
 #x10010db ; "Georgian_man") ;U+10DB GEORGIAN LETTER MA
 #x10010dc ; "Georgian_nar") ;U+10DC GEORGIAN LETTER NA
 #x10010dd ; "Georgian_on") ;U+10DD GEORGIAN LETTER O
 #x10010de ; "Georgian_par") ;U+10DE GEORGIAN LETTER PA
 #x10010df ; "Georgian_zhar") ;U+10DF GEORGIAN LETTER ZHA
 #x10010e0 ; "Georgian_rae") ;U+10E0 GEORGIAN LETTER RA
 #x10010e1 ; "Georgian_san") ;U+10E1 GEORGIAN LETTER SA
 #x10010e2 ; "Georgian_tar") ;U+10E2 GEORGIAN LETTER TA
 #x10010e3 ; "Georgian_un") ;U+10E3 GEORGIAN LETTER U
 #x10010e4 ; "Georgian_phar") ;U+10E4 GEORGIAN LETTER PHA
 #x10010e5 ; "Georgian_khar") ;U+10E5 GEORGIAN LETTER KHA
 #x10010e6 ; "Georgian_ghan") ;U+10E6 GEORGIAN LETTER GHA
 #x10010e7 ; "Georgian_qar") ;U+10E7 GEORGIAN LETTER QA
 #x10010e8 ; "Georgian_shin") ;U+10E8 GEORGIAN LETTER SHI
 #x10010e9 ; "Georgian_chin") ;U+10E9 GEORGIAN LETTER CHI
 #x10010ea ; "Georgian_can") ;U+10EA GEORGIAN LETTER CA
 #x10010eb ; "Georgian_jil") ;U+10EB GEORGIAN LETTER JI
 #x10010ec ; "Georgian_cil") ;U+10EC GEORGIAN LETTER CI
 #x10010ed ; "Georgian_char") ;U+10ED GEORGIAN LETTER CHA
 #x10010ee ; "Georgian_xan") ;U+10EE GEORGIAN LETTER XA
 #x10010ef ; "Georgian_jhan") ;U+10EF GEORGIAN LETTER JHA
 #x10010f0 ; "Georgian_hae") ;U+10F0 GEORGIAN LETTER HA
 #x10010f1 ; "Georgian_he") ;U+10F1 GEORGIAN LETTER H
 #x10010f2 ; "Georgian_hie") ;U+10F2 GEORGIAN LETTER HI
 #x10010f3 ; "Georgian_we") ;U+10F3 GEORGIAN LETTER W
 #x10010f4 ; "Georgian_har") ;U+10F4 GEORGIAN LETTER HA
 #x10010f5 ; "Georgian_hoe") ;U+10F5 GEORGIAN LETTER HO
 #x10010f6 ; "Georgian_fi") ;U+10F6 GEORGIAN LETTER F
 #x1001e8a ; "Xabovedot") ;U+1E8A LATIN CAPITAL LETTER X WITH DOT ABOV
 #x100012c ; "Ibreve") ;U+012C LATIN CAPITAL LETTER I WITH BREV
 #x10001b5 ; "Zstroke") ;U+01B5 LATIN CAPITAL LETTER Z WITH STROK
 #x10001e6 ; "Gcaron") ;U+01E6 LATIN CAPITAL LETTER G WITH CARO
 #x10001d1 ; "Ocaron") ;U+01D2 LATIN CAPITAL LETTER O WITH CARO
 #x100019f ; "Obarred") ;U+019F LATIN CAPITAL LETTER O WITH MIDDLE TILD
 #x1001e8b ; "xabovedot") ;U+1E8B LATIN SMALL LETTER X WITH DOT ABOV
 #x100012d ; "ibreve") ;U+012D LATIN SMALL LETTER I WITH BREV
 #x10001b6 ; "zstroke") ;U+01B6 LATIN SMALL LETTER Z WITH STROK
 #x10001e7 ; "gcaron") ;U+01E7 LATIN SMALL LETTER G WITH CARO
 #x10001d2 ; "ocaron") ;U+01D2 LATIN SMALL LETTER O WITH CARO
 #x1000275 ; "obarred") ;U+0275 LATIN SMALL LETTER BARRED 
 #x100018f ; "SCHWA")   ;U+018F LATIN CAPITAL LETTER SCHW
 #x1000259 ; "schwa")     ;U+0259 LATIN SMALL LETTER SCHW
 #x1001e36 ; "Lbelowdot") ;U+1E36 LATIN CAPITAL LETTER L WITH DOT BELO
 #x1001e37 ; "lbelowdot") ;U+1E37 LATIN SMALL LETTER L WITH DOT BELO
 #x1001ea0 ; "Abelowdot") ;U+1EA0 LATIN CAPITAL LETTER A WITH DOT BELO
 #x1001ea1 ; "abelowdot") ;U+1EA1 LATIN SMALL LETTER A WITH DOT BELO
 #x1001ea2 ; "Ahook") ;U+1EA2 LATIN CAPITAL LETTER A WITH HOOK ABOV
 #x1001ea3 ; "ahook") ;U+1EA3 LATIN SMALL LETTER A WITH HOOK ABOV
 #x1001ea4 ; "Acircumflexacute") ;U+1EA4 LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND ACUT
 #x1001ea5 ; "acircumflexacute") ;U+1EA5 LATIN SMALL LETTER A WITH CIRCUMFLEX AND ACUT
 #x1001ea6 ; "Acircumflexgrave") ;U+1EA6 LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND GRAV
 #x1001ea7 ; "acircumflexgrave") ;U+1EA7 LATIN SMALL LETTER A WITH CIRCUMFLEX AND GRAV
 #x1001ea8 ; "Acircumflexhook") ;U+1EA8 LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND HOOK ABOV
 #x1001ea9 ; "acircumflexhook") ;U+1EA9 LATIN SMALL LETTER A WITH CIRCUMFLEX AND HOOK ABOV
 #x1001eaa ; "Acircumflextilde") ;U+1EAA LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND TILD
 #x1001eab ; "acircumflextilde") ;U+1EAB LATIN SMALL LETTER A WITH CIRCUMFLEX AND TILD
 #x1001eac ; "Acircumflexbelowdot") ;U+1EAC LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND DOT BELO
 #x1001ead ; "acircumflexbelowdot") ;U+1EAD LATIN SMALL LETTER A WITH CIRCUMFLEX AND DOT BELO
 #x1001eae ; "Abreveacute") ;U+1EAE LATIN CAPITAL LETTER A WITH BREVE AND ACUT
 #x1001eaf ; "abreveacute") ;U+1EAF LATIN SMALL LETTER A WITH BREVE AND ACUT
 #x1001eb0 ; "Abrevegrave") ;U+1EB0 LATIN CAPITAL LETTER A WITH BREVE AND GRAV
 #x1001eb1 ; "abrevegrave") ;U+1EB1 LATIN SMALL LETTER A WITH BREVE AND GRAV
 #x1001eb2 ; "Abrevehook") ;U+1EB2 LATIN CAPITAL LETTER A WITH BREVE AND HOOK ABOV
 #x1001eb3 ; "abrevehook") ;U+1EB3 LATIN SMALL LETTER A WITH BREVE AND HOOK ABOV
 #x1001eb4 ; "Abrevetilde") ;U+1EB4 LATIN CAPITAL LETTER A WITH BREVE AND TILD
 #x1001eb5 ; "abrevetilde") ;U+1EB5 LATIN SMALL LETTER A WITH BREVE AND TILD
 #x1001eb6 ; "Abrevebelowdot") ;U+1EB6 LATIN CAPITAL LETTER A WITH BREVE AND DOT BELO
 #x1001eb7 ; "abrevebelowdot") ;U+1EB7 LATIN SMALL LETTER A WITH BREVE AND DOT BELO
 #x1001eb8 ; "Ebelowdot") ;U+1EB8 LATIN CAPITAL LETTER E WITH DOT BELO
 #x1001eb9 ; "ebelowdot") ;U+1EB9 LATIN SMALL LETTER E WITH DOT BELO
 #x1001eba ; "Ehook") ;U+1EBA LATIN CAPITAL LETTER E WITH HOOK ABOV
 #x1001ebb ; "ehook") ;U+1EBB LATIN SMALL LETTER E WITH HOOK ABOV
 #x1001ebc ; "Etilde") ;U+1EBC LATIN CAPITAL LETTER E WITH TILD
 #x1001ebd ; "etilde") ;U+1EBD LATIN SMALL LETTER E WITH TILD
 #x1001ebe ; "Ecircumflexacute") ;U+1EBE LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND ACUT
 #x1001ebf ; "ecircumflexacute") ;U+1EBF LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUT
 #x1001ec0 ; "Ecircumflexgrave") ;U+1EC0 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND GRAV
 #x1001ec1 ; "ecircumflexgrave") ;U+1EC1 LATIN SMALL LETTER E WITH CIRCUMFLEX AND GRAV
 #x1001ec2 ; "Ecircumflexhook") ;U+1EC2 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND HOOK ABOV
 #x1001ec3 ; "ecircumflexhook") ;U+1EC3 LATIN SMALL LETTER E WITH CIRCUMFLEX AND HOOK ABOV
 #x1001ec4 ; "Ecircumflextilde") ;U+1EC4 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND TILD
 #x1001ec5 ; "ecircumflextilde") ;U+1EC5 LATIN SMALL LETTER E WITH CIRCUMFLEX AND TILD
 #x1001ec6 ; "Ecircumflexbelowdot") ;U+1EC6 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND DOT BELO
 #x1001ec7 ; "ecircumflexbelowdot") ;U+1EC7 LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELO
 #x1001ec8 ; "Ihook") ;U+1EC8 LATIN CAPITAL LETTER I WITH HOOK ABOV
 #x1001ec9 ; "ihook") ;U+1EC9 LATIN SMALL LETTER I WITH HOOK ABOV
 #x1001eca ; "Ibelowdot") ;U+1ECA LATIN CAPITAL LETTER I WITH DOT BELO
 #x1001ecb ; "ibelowdot") ;U+1ECB LATIN SMALL LETTER I WITH DOT BELO
 #x1001ecc ; "Obelowdot") ;U+1ECC LATIN CAPITAL LETTER O WITH DOT BELO
 #x1001ecd ; "obelowdot") ;U+1ECD LATIN SMALL LETTER O WITH DOT BELO
 #x1001ece ; "Ohook") ;U+1ECE LATIN CAPITAL LETTER O WITH HOOK ABOV
 #x1001ecf ; "ohook") ;U+1ECF LATIN SMALL LETTER O WITH HOOK ABOV
 #x1001ed0 ; "Ocircumflexacute") ;U+1ED0 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND ACUT
 #x1001ed1 ; "ocircumflexacute") ;U+1ED1 LATIN SMALL LETTER O WITH CIRCUMFLEX AND ACUT
 #x1001ed2 ; "Ocircumflexgrave") ;U+1ED2 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND GRAV
 #x1001ed3 ; "ocircumflexgrave") ;U+1ED3 LATIN SMALL LETTER O WITH CIRCUMFLEX AND GRAV
 #x1001ed4 ; "Ocircumflexhook") ;U+1ED4 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND HOOK ABOV
 #x1001ed5 ; "ocircumflexhook") ;U+1ED5 LATIN SMALL LETTER O WITH CIRCUMFLEX AND HOOK ABOV
 #x1001ed6 ; "Ocircumflextilde") ;U+1ED6 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND TILD
 #x1001ed7 ; "ocircumflextilde") ;U+1ED7 LATIN SMALL LETTER O WITH CIRCUMFLEX AND TILD
 #x1001ed8 ; "Ocircumflexbelowdot") ;U+1ED8 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND DOT BELO
 #x1001ed9 ; "ocircumflexbelowdot") ;U+1ED9 LATIN SMALL LETTER O WITH CIRCUMFLEX AND DOT BELO
 #x1001eda ; "Ohornacute") ;U+1EDA LATIN CAPITAL LETTER O WITH HORN AND ACUT
 #x1001edb ; "ohornacute") ;U+1EDB LATIN SMALL LETTER O WITH HORN AND ACUT
 #x1001edc ; "Ohorngrave") ;U+1EDC LATIN CAPITAL LETTER O WITH HORN AND GRAV
 #x1001edd ; "ohorngrave") ;U+1EDD LATIN SMALL LETTER O WITH HORN AND GRAV
 #x1001ede ; "Ohornhook") ;U+1EDE LATIN CAPITAL LETTER O WITH HORN AND HOOK ABOV
 #x1001edf ; "ohornhook") ;U+1EDF LATIN SMALL LETTER O WITH HORN AND HOOK ABOV
 #x1001ee0 ; "Ohorntilde") ;U+1EE0 LATIN CAPITAL LETTER O WITH HORN AND TILD
 #x1001ee1 ; "ohorntilde") ;U+1EE1 LATIN SMALL LETTER O WITH HORN AND TILD
 #x1001ee2 ; "Ohornbelowdot") ;U+1EE2 LATIN CAPITAL LETTER O WITH HORN AND DOT BELO
 #x1001ee3 ; "ohornbelowdot") ;U+1EE3 LATIN SMALL LETTER O WITH HORN AND DOT BELO
 #x1001ee4 ; "Ubelowdot") ;U+1EE4 LATIN CAPITAL LETTER U WITH DOT BELO
 #x1001ee5 ; "ubelowdot") ;U+1EE5 LATIN SMALL LETTER U WITH DOT BELO
 #x1001ee6 ; "Uhook") ;U+1EE6 LATIN CAPITAL LETTER U WITH HOOK ABOV
 #x1001ee7 ; "uhook") ;U+1EE7 LATIN SMALL LETTER U WITH HOOK ABOV
 #x1001ee8 ; "Uhornacute") ;U+1EE8 LATIN CAPITAL LETTER U WITH HORN AND ACUT
 #x1001ee9 ; "uhornacute") ;U+1EE9 LATIN SMALL LETTER U WITH HORN AND ACUT
 #x1001eea ; "Uhorngrave") ;U+1EEA LATIN CAPITAL LETTER U WITH HORN AND GRAV
 #x1001eeb ; "uhorngrave") ;U+1EEB LATIN SMALL LETTER U WITH HORN AND GRAV
 #x1001eec ; "Uhornhook") ;U+1EEC LATIN CAPITAL LETTER U WITH HORN AND HOOK ABOV
 #x1001eed ; "uhornhook") ;U+1EED LATIN SMALL LETTER U WITH HORN AND HOOK ABOV
 #x1001eee ; "Uhorntilde") ;U+1EEE LATIN CAPITAL LETTER U WITH HORN AND TILD
 #x1001eef ; "uhorntilde") ;U+1EEF LATIN SMALL LETTER U WITH HORN AND TILD
 #x1001ef0 ; "Uhornbelowdot") ;U+1EF0 LATIN CAPITAL LETTER U WITH HORN AND DOT BELO
 #x1001ef1 ; "uhornbelowdot") ;U+1EF1 LATIN SMALL LETTER U WITH HORN AND DOT BELO
 #x1001ef4 ; "Ybelowdot") ;U+1EF4 LATIN CAPITAL LETTER Y WITH DOT BELO
 #x1001ef5 ; "ybelowdot") ;U+1EF5 LATIN SMALL LETTER Y WITH DOT BELO
 #x1001ef6 ; "Yhook") ;U+1EF6 LATIN CAPITAL LETTER Y WITH HOOK ABOV
 #x1001ef7 ; "yhook") ;U+1EF7 LATIN SMALL LETTER Y WITH HOOK ABOV
 #x1001ef8 ; "Ytilde") ;U+1EF8 LATIN CAPITAL LETTER Y WITH TILD
 #x1001ef9 ; "ytilde") ;U+1EF9 LATIN SMALL LETTER Y WITH TILD
 #x10001a0 ; "Ohorn") ;U+01A0 LATIN CAPITAL LETTER O WITH HOR
 #x10001a1 ; "ohorn") ;U+01A1 LATIN SMALL LETTER O WITH HOR
 #x10001af ; "Uhorn") ;U+01AF LATIN CAPITAL LETTER U WITH HOR
 #x10001b0 ; "uhorn") ;U+01B0 LATIN SMALL LETTER U WITH HOR
 #x10020a0 ; "EcuSign")     ;U+20A0 EURO-CURRENCY SIG
 #x10020a1 ; "ColonSign")   ;U+20A1 COLON SIG
 #x10020a2 ; "CruzeiroSign") ;U+20A2 CRUZEIRO SIG
 #x10020a3 ; "FFrancSign")  ;U+20A3 FRENCH FRANC SIG
 #x10020a4 ; "LiraSign")    ;U+20A4 LIRA SIG
 #x10020a5 ; "MillSign")    ;U+20A5 MILL SIG
 #x10020a6 ; "NairaSign")   ;U+20A6 NAIRA SIG
 #x10020a7 ; "PesetaSign")  ;U+20A7 PESETA SIG
 #x10020a8 ; "RupeeSign")   ;U+20A8 RUPEE SIG
 #x10020a9 ; "WonSign")     ;U+20A9 WON SIG
 #x10020aa ; "NewSheqelSign") ;U+20AA NEW SHEQEL SIG
 #x10020ab ; "DongSign")    ;U+20AB DONG SIG
 #x20ac ; "EuroSign")       ;U+20AC EURO SIG
 #x1002070 ; "zerosuperior") ;U+2070 SUPERSCRIPT ZER
 #x1002074 ; "foursuperior") ;U+2074 SUPERSCRIPT FOU
 #x1002075 ; "fivesuperior") ;U+2075 SUPERSCRIPT FIV
 #x1002076 ; "sixsuperior") ;U+2076 SUPERSCRIPT SI
 #x1002077 ; "sevensuperior") ;U+2077 SUPERSCRIPT SEVE
 #x1002078 ; "eightsuperior") ;U+2078 SUPERSCRIPT EIGH
 #x1002079 ; "ninesuperior") ;U+2079 SUPERSCRIPT NIN
 #x1002080 ; "zerosubscript") ;U+2080 SUBSCRIPT ZER
 #x1002081 ; "onesubscript") ;U+2081 SUBSCRIPT ON
 #x1002082 ; "twosubscript") ;U+2082 SUBSCRIPT TW
 #x1002083 ; "threesubscript") ;U+2083 SUBSCRIPT THRE
 #x1002084 ; "foursubscript") ;U+2084 SUBSCRIPT FOU
 #x1002085 ; "fivesubscript") ;U+2085 SUBSCRIPT FIV
 #x1002086 ; "sixsubscript") ;U+2086 SUBSCRIPT SI
 #x1002087 ; "sevensubscript") ;U+2087 SUBSCRIPT SEVE
 #x1002088 ; "eightsubscript") ;U+2088 SUBSCRIPT EIGH
 #x1002089 ; "ninesubscript") ;U+2089 SUBSCRIPT NIN
 #x1002202 ; "partdifferential") ;U+2202 PARTIAL DIFFERENTIA
 #x1002205 ; "emptyset")    ;U+2205 NULL SE
 #x1002208 ; "elementof")   ;U+2208 ELEMENT O
 #x1002209 ; "notelementof") ;U+2209 NOT AN ELEMENT O
 #x100220B ; "containsas")  ;U+220B CONTAINS AS MEMBE
 #x100221A ; "squareroot")  ;U+221A SQUARE ROO
 #x100221B ; "cuberoot")    ;U+221B CUBE ROO
 #x100221C ; "fourthroot")  ;U+221C FOURTH ROO
 #x100222C ; "dintegral")   ;U+222C DOUBLE INTEGRA
 #x100222D ; "tintegral")   ;U+222D TRIPLE INTEGRA
 #x1002235 ; "because")     ;U+2235 BECAUS
 #x1002248 ; "approxeq")    ;U+2245 ALMOST EQUAL T
 #x1002247 ; "notapproxeq") ;U+2247 NOT ALMOST EQUAL T
 #x1002262 ; "notidentical") ;U+2262 NOT IDENTICAL T
 #x1002263 ; "stricteq")    ;U+2263 STRICTLY EQUIVALENT T
 ;; extended ; keysym
 #x100000A8 ; "hpmute_acute"
 #x100000A9 ; "hpmute_grave"
 #x100000AA ; "hpmute_asciicircum"
 #x100000AB ; "hpmute_diaeresis"
 #x100000AC ; "hpmute_asciitilde"
 #x100000AF ; "hplira"
 #x100000BE ; "hpguilder"
 #x100000EE ; "hpYdiaeresis"
 #x100000EE ; "hpIO"
 #x100000F6 ; "hplongminus"
 #x100000FC ; "hpblock"
 #x1000FF00 ; "apLineDel"
 #x1000FF01 ; "apCharDel"
 #x1000FF02 ; "apCopy"
 #x1000FF03 ; "apCut"
 #x1000FF04 ; "apPaste"
 #x1000FF05 ; "apMove"
 #x1000FF06 ; "apGrow"
 #x1000FF07 ; "apCmd"
 #x1000FF08 ; "apShell"
 #x1000FF09 ; "apLeftBar"
 #x1000FF0A ; "apRightBar"
 #x1000FF0B ; "apLeftBox"
 #x1000FF0C ; "apRightBox"
 #x1000FF0D ; "apUpBox"
 #x1000FF0E ; "apDownBox"
 #x1000FF0F ; "apPop"
 #x1000FF10 ; "apRead"
 #x1000FF11 ; "apEdit"
 #x1000FF12 ; "apSave"
 #x1000FF13 ; "apExit"
 #x1000FF14 ; "apRepeat"
 #x1000FF48 ; "hpModelock1"
 #x1000FF49 ; "hpModelock2"
 #x1000FF6C ; "hpReset"
 #x1000FF6D ; "hpSystem"
 #x1000FF6E ; "hpUser"
 #x1000FF6F ; "hpClearLine"
 #x1000FF70 ; "hpInsertLine"
 #x1000FF71 ; "hpDeleteLine"
 #x1000FF72 ; "hpInsertChar"
 #x1000FF73 ; "hpDeleteChar"
 #x1000FF74 ; "hpBackTab"
 #x1000FF75 ; "hpKP_BackTab"
 #x1000FFA8 ; "apKP_parenleft"
 #x1000FFA9 ; "apKP_parenright"
 #x10004001 ; "I2ND_FUNC_L"
 #x10004002 ; "I2ND_FUNC_R"
 #x10004003 ; "IREMOVE"
 #x10004004 ; "IREPEAT"
 #x10004101 ; "IA1"
 #x10004102 ; "IA2"
 #x10004103 ; "IA3"
 #x10004104 ; "IA4"
 #x10004105 ; "IA5"
 #x10004106 ; "IA6"
 #x10004107 ; "IA7"
 #x10004108 ; "IA8"
 #x10004109 ; "IA9"
 #x1000410A ; "IA10"
 #x1000410B ; "IA11"
 #x1000410C ; "IA12"
 #x1000410D ; "IA13"
 #x1000410E ; "IA14"
 #x1000410F ; "IA15"
 #x10004201 ; "IB1"
 #x10004202 ; "IB2"
 #x10004203 ; "IB3"
 #x10004204 ; "IB4"
 #x10004205 ; "IB5"
 #x10004206 ; "IB6"
 #x10004207 ; "IB7"
 #x10004208 ; "IB8"
 #x10004209 ; "IB9"
 #x1000420A ; "IB10"
 #x1000420B ; "IB11"
 #x1000420C ; "IB12"
 #x1000420D ; "IB13"
 #x1000420E ; "IB14"
 #x1000420F ; "IB15"
 #x10004210 ; "IB16"
 #x1000FF00 ; "DRemove"
 #x1000FEB0 ; "Dring_accent"
 #x1000FE5E ; "Dcircumflex_accent"
 #x1000FE2C ; "Dcedilla_accent"
 #x1000FE27 ; "Dacute_accent"
 #x1000FE60 ; "Dgrave_accent"
 #x1000FE7E ; "Dtilde"
 #x1000FE22 ; "Ddiaeresis"
 #x1004FF02 ; "osfCopy"
 #x1004FF03 ; "osfCut"
 #x1004FF04 ; "osfPaste"
 #x1004FF07 ; "osfBackTab"
 #x1004FF08 ; "osfBackSpace"
 #x1004FF0B ; "osfClear"
 #x1004FF1B ; "osfEscape"
 #x1004FF31 ; "osfAddMode"
 #x1004FF32 ; "osfPrimaryPaste"
 #x1004FF33 ; "osfQuickPaste"
 #x1004FF40 ; "osfPageLeft"
 #x1004FF41 ; "osfPageUp"
 #x1004FF42 ; "osfPageDown"
 #x1004FF43 ; "osfPageRight"
 #x1004FF44 ; "osfActivate"
 #x1004FF45 ; "osfMenuBar"
 #x1004FF51 ; "osfLeft"
 #x1004FF52 ; "osfUp"
 #x1004FF53 ; "osfRight"
 #x1004FF54 ; "osfDown"
 #x1004FF55 ; "osfPrior"
 #x1004FF56 ; "osfNext"
 #x1004FF57 ; "osfEndLine"
 #x1004FF58 ; "osfBeginLine"
 #x1004FF59 ; "osfEndData"
 #x1004FF5A ; "osfBeginData"
 #x1004FF5B ; "osfPrevMenu"
 #x1004FF5C ; "osfNextMenu"
 #x1004FF5D ; "osfPrevField"
 #x1004FF5E ; "osfNextField"
 #x1004FF60 ; "osfSelect"
 #x1004FF63 ; "osfInsert"
 #x1004FF65 ; "osfUndo"
 #x1004FF67 ; "osfMenu"
 #x1004FF69 ; "osfCancel"
 #x1004FF6A ; "osfHelp"
 #x1004FF71 ; "osfSelectAll"
 #x1004FF72 ; "osfDeselectAll"
 #x1004FF73 ; "osfReselect"
 #x1004FF74 ; "osfExtend"
 #x1004FF78 ; "osfRestore"
 #x1004FF7E ; "osfSwitchDirection"
 #x1004FFF5 ; "osfPriorMinor"
 #x1004FFF6 ; "osfNextMinor"
 #x1004FFF7 ; "osfRightLine"
 #x1004FFF8 ; "osfLeftLine"
 #x1004FFFF ; "osfDelete"
 #x1005FF00 ; "SunFA_Grave"
 #x1005FF01 ; "SunFA_Circum"
 #x1005FF02 ; "SunFA_Tilde"
 #x1005FF03 ; "SunFA_Acute"
 #x1005FF04 ; "SunFA_Diaeresis"
 #x1005FF05 ; "SunFA_Cedilla"
 #x1005FF10 ; "SunF36"
 #x1005FF11 ; "SunF37"
 #x1005FF60 ; "SunSys_Req"
 #x1005FF70 ; "SunProps"
 #x1005FF71 ; "SunFront"
 #x1005FF72 ; "SunCopy"
 #x1005FF73 ; "SunOpen"
 #x1005FF74 ; "SunPaste"
 #x1005FF75 ; "SunCut"
 #x1005FF76 ; "SunPowerSwitch"
 #x1005FF77 ; "SunAudioLowerVolume"
 #x1005FF78 ; "SunAudioMute"
 #x1005FF79 ; "SunAudioRaiseVolume"
 #x1005FF7A ; "SunVideoDegauss"
 #x1005FF7B ; "SunVideoLowerBrightness"
 #x1005FF7C ; "SunVideoRaiseBrightness"
 #x1005FF7D ; "SunPowerSwitchShift"
 #xFF20 ; "SunCompose"
 #xFF55 ; "SunPageUp"
 #xFF56 ; "SunPageDown"
 #xFF61 ; "SunPrint_Screen"
 #xFF65 ; "SunUndo"
 #xFF66 ; "SunAgain"
 #xFF68 ; "SunFind"
 #xFF69 ; "SunStop"
 #xFF7E ; "SunAltGraph"
 #x1006FF00 ; "WYSetup"
 #x1006FF00 ; "ncdSetup"
 #x10070001 ; "XeroxPointerButton1"
 #x10070002 ; "XeroxPointerButton2"
 #x10070003 ; "XeroxPointerButton3"
 #x10070004 ; "XeroxPointerButton4"
 #x10070005 ; "XeroxPointerButton5"
 #x1008FF01 ; "XF86ModeLock"
 #x1008FF02 ; "XF86MonBrightnessUp"
 #x1008FF03 ; "XF86MonBrightnessDown"
 #x1008FF04 ; "XF86KbdLightOnOff"
 #x1008FF05 ; "XF86KbdBrightnessUp"
 #x1008FF06 ; "XF86KbdBrightnessDown"
 #x1008FF10 ; "XF86Standby"
 #x1008FF11 ; "XF86AudioLowerVolume"
 #x1008FF12 ; "XF86AudioMute"
 #x1008FF13 ; "XF86AudioRaiseVolume"
 #x1008FF14 ; "XF86AudioPlay"
 #x1008FF15 ; "XF86AudioStop"
 #x1008FF16 ; "XF86AudioPrev"
 #x1008FF17 ; "XF86AudioNext"
 #x1008FF18 ; "XF86HomePage"
 #x1008FF19 ; "XF86Mail"
 #x1008FF1A ; "XF86Start"
 #x1008FF1B ; "XF86Search"
 #x1008FF1C ; "XF86AudioRecord"
 #x1008FF1D ; "XF86Calculator"
 #x1008FF1E ; "XF86Memo"
 #x1008FF1F ; "XF86ToDoList"
 #x1008FF20 ; "XF86Calendar"
 #x1008FF21 ; "XF86PowerDown"
 #x1008FF22 ; "XF86ContrastAdjust"
 #x1008FF23 ; "XF86RockerUp"
 #x1008FF24 ; "XF86RockerDown"
 #x1008FF25 ; "XF86RockerEnter"
 #x1008FF26 ; "XF86Back"
 #x1008FF27 ; "XF86Forward"
 #x1008FF28 ; "XF86Stop"
 #x1008FF29 ; "XF86Refresh"
 #x1008FF2A ; "XF86PowerOff"
 #x1008FF2B ; "XF86WakeUp"
 #x1008FF2C ; "XF86Eject"
 #x1008FF2D ; "XF86ScreenSaver"
 #x1008FF2E ; "XF86WWW"
 #x1008FF2F ; "XF86Sleep"
 #x1008FF30 ; "XF86Favorites"
 #x1008FF31 ; "XF86AudioPause"
 #x1008FF32 ; "XF86AudioMedia"
 #x1008FF33 ; "XF86MyComputer"
 #x1008FF34 ; "XF86VendorHome"
 #x1008FF35 ; "XF86LightBulb"
 #x1008FF36 ; "XF86Shop"
 #x1008FF37 ; "XF86History"
 #x1008FF38 ; "XF86OpenURL"
 #x1008FF39 ; "XF86AddFavorite"
 #x1008FF3A ; "XF86HotLinks"
 #x1008FF3B ; "XF86BrightnessAdjust"
 #x1008FF3C ; "XF86Finance"
 #x1008FF3D ; "XF86Community"
 #x1008FF3E ; "XF86AudioRewind"
 #x1008FF3F ; "XF86BackForward"
 #x1008FF40 ; "XF86Launch0"
 #x1008FF41 ; "XF86Launch1"
 #x1008FF42 ; "XF86Launch2"
 #x1008FF43 ; "XF86Launch3"
 #x1008FF44 ; "XF86Launch4"
 #x1008FF45 ; "XF86Launch5"
 #x1008FF46 ; "XF86Launch6"
 #x1008FF47 ; "XF86Launch7"
 #x1008FF48 ; "XF86Launch8"
 #x1008FF49 ; "XF86Launch9"
 #x1008FF4A ; "XF86LaunchA"
 #x1008FF4B ; "XF86LaunchB"
 #x1008FF4C ; "XF86LaunchC"
 #x1008FF4D ; "XF86LaunchD"
 #x1008FF4E ; "XF86LaunchE"
 #x1008FF4F ; "XF86LaunchF"
 #x1008FF50 ; "XF86ApplicationLeft"
 #x1008FF51 ; "XF86ApplicationRight"
 #x1008FF52 ; "XF86Book"
 #x1008FF53 ; "XF86CD"
 #x1008FF54 ; "XF86Calculater"
 #x1008FF55 ; "XF86Clear"
 #x1008FF56 ; "XF86Close"
 #x1008FF57 ; "XF86Copy"
 #x1008FF58 ; "XF86Cut"
 #x1008FF59 ; "XF86Display"
 #x1008FF5A ; "XF86DOS"
 #x1008FF5B ; "XF86Documents"
 #x1008FF5C ; "XF86Excel"
 #x1008FF5D ; "XF86Explorer"
 #x1008FF5E ; "XF86Game"
 #x1008FF5F ; "XF86Go"
 #x1008FF60 ; "XF86iTouch"
 #x1008FF61 ; "XF86LogOff"
 #x1008FF62 ; "XF86Market"
 #x1008FF63 ; "XF86Meeting"
 #x1008FF65 ; "XF86MenuKB"
 #x1008FF66 ; "XF86MenuPB"
 #x1008FF67 ; "XF86MySites"
 #x1008FF68 ; "XF86New"
 #x1008FF69 ; "XF86News"
 #x1008FF6A ; "XF86OfficeHome"
 #x1008FF6B ; "XF86Open"
 #x1008FF6C ; "XF86Option"
 #x1008FF6D ; "XF86Paste"
 #x1008FF6E ; "XF86Phone"
 #x1008FF70 ; "XF86Q"
 #x1008FF72 ; "XF86Reply"
 #x1008FF73 ; "XF86Reload"
 #x1008FF74 ; "XF86RotateWindows"
 #x1008FF75 ; "XF86RotationPB"
 #x1008FF76 ; "XF86RotationKB"
 #x1008FF77 ; "XF86Save"
 #x1008FF78 ; "XF86ScrollUp"
 #x1008FF79 ; "XF86ScrollDown"
 #x1008FF7A ; "XF86ScrollClick"
 #x1008FF7B ; "XF86Send"
 #x1008FF7C ; "XF86Spell"
 #x1008FF7D ; "XF86SplitScreen"
 #x1008FF7E ; "XF86Support"
 #x1008FF7F ; "XF86TaskPane"
 #x1008FF80 ; "XF86Terminal"
 #x1008FF81 ; "XF86Tools"
 #x1008FF82 ; "XF86Travel"
 #x1008FF84 ; "XF86UserPB"
 #x1008FF85 ; "XF86User1KB"
 #x1008FF86 ; "XF86User2KB"
 #x1008FF87 ; "XF86Video"
 #x1008FF88 ; "XF86WheelButton"
 #x1008FF89 ; "XF86Word"
 #x1008FF8A ; "XF86Xfer"
 #x1008FF8B ; "XF86ZoomIn"
 #x1008FF8C ; "XF86ZoomOut"
 #x1008FF8D ; "XF86Away"
 #x1008FF8E ; "XF86Messenger"
 #x1008FF8F ; "XF86WebCam"
 #x1008FF90 ; "XF86MailForward"
 #x1008FF91 ; "XF86Pictures"
 #x1008FF92 ; "XF86Music"
 #x1008FF93 ; "XF86Battery"
 #x1008FF94 ; "XF86Bluetooth"
 #x1008FF95 ; "XF86WLAN"
 #x1008FF96 ; "XF86UWB"
 #x1008FF97 ; "XF86AudioForward"
 #x1008FF98 ; "XF86AudioRepeat"
 #x1008FF99 ; "XF86AudioRandomPlay"
 #x1008FF9A ; "XF86Subtitle"
 #x1008FF9B ; "XF86AudioCycleTrack"
 #x1008FF9C ; "XF86CycleAngle"
 #x1008FF9D ; "XF86FrameBack"
 #x1008FF9E ; "XF86FrameForward"
 #x1008FF9F ; "XF86Time"
 #x1008FFA0 ; "XF86Select"
 #x1008FFA1 ; "XF86View"
 #x1008FFA2 ; "XF86TopMenu"
 #x1008FFA3 ; "XF86Red"
 #x1008FFA4 ; "XF86Green"
 #x1008FFA5 ; "XF86Yellow"
 #x1008FFA6 ; "XF86Blue"
 #x1008FFA7 ; "XF86Suspend"
 #x1008FFA8 ; "XF86Hibernate"
 #x1008FFA9 ; "XF86TouchpadToggle"
 #x1008FFB0 ; "XF86TouchpadOn"
 #x1008FFB1 ; "XF86TouchpadOff"
 #x1008FFB2 ; "XF86AudioMicMute"
 #x1008FFB5 ; "XF86RFKill"
 #x1008FE01 ; "XF86_Switch_VT_1"
 #x1008FE02 ; "XF86_Switch_VT_2"
 #x1008FE03 ; "XF86_Switch_VT_3"
 #x1008FE04 ; "XF86_Switch_VT_4"
 #x1008FE05 ; "XF86_Switch_VT_5"
 #x1008FE06 ; "XF86_Switch_VT_6"
 #x1008FE07 ; "XF86_Switch_VT_7"
 #x1008FE08 ; "XF86_Switch_VT_8"
 #x1008FE09 ; "XF86_Switch_VT_9"
 #x1008FE0A ; "XF86_Switch_VT_10"
 #x1008FE0B ; "XF86_Switch_VT_11"
 #x1008FE0C ; "XF86_Switch_VT_12"
 #x1008FE20 ; "XF86_Ungrab"
 #x1008FE21 ; "XF86_ClearGrab"
 #x1008FE22 ; "XF86_Next_VMode"
 #x1008FE23 ; "XF86_Prev_VMode"
 #x100000A8 ; "usldead_acute"
 #x100000A9 ; "usldead_grave"
 #x100000AB ; "usldead_diaeresis"
 #x100000AA ; "usldead_asciicircum"
 #x100000AC ; "usldead_asciitilde"
 #x1000FE2C ; "usldead_cedilla"
 #x1000FEB0) ; "usldead_ring"
