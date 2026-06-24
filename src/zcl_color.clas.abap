"! Wraps text in ANSI escape codes so it shows up coloured in a terminal.
"! This is the ABAP counterpart of the Node.js "cli-color" dependency.
"!
"! Note: in a real SAP GUI you would colour list output with
"! "WRITE ... COLOR n". On a plain console (where this game runs) colour
"! works via ANSI escape sequences instead, e.g. ESC[35m ... ESC[0m.
CLASS zcl_color DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    " Standard ANSI foreground colour codes
    CONSTANTS c_red     TYPE i VALUE 31.
    CONSTANTS c_green   TYPE i VALUE 32.
    CONSTANTS c_yellow  TYPE i VALUE 33.
    CONSTANTS c_blue    TYPE i VALUE 34.
    CONSTANTS c_magenta TYPE i VALUE 35.
    CONSTANTS c_cyan    TYPE i VALUE 36.

    "! Wraps text in the given ANSI colour code.
    CLASS-METHODS colorize
      IMPORTING text          TYPE string
                code          TYPE i
      RETURNING VALUE(result) TYPE string.

    " Convenience helpers, mirroring cli-color's cliColor.magenta( ... ) style
    CLASS-METHODS magenta IMPORTING text TYPE string RETURNING VALUE(result) TYPE string.
    CLASS-METHODS red     IMPORTING text TYPE string RETURNING VALUE(result) TYPE string.
    CLASS-METHODS green   IMPORTING text TYPE string RETURNING VALUE(result) TYPE string.
    CLASS-METHODS yellow  IMPORTING text TYPE string RETURNING VALUE(result) TYPE string.
    CLASS-METHODS cyan    IMPORTING text TYPE string RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    CLASS-DATA gv_esc TYPE string.

    CLASS-METHODS class_constructor.

ENDCLASS.

CLASS zcl_color IMPLEMENTATION.

  METHOD class_constructor.
    " The ESC control character (hex 1B) cannot be typed as a literal,
    " so we decode it from its byte value once.
    DATA lv_byte TYPE xstring.
    lv_byte = '1B'.
    gv_esc = cl_abap_conv_codepage=>create_in( )->convert( lv_byte ).
  ENDMETHOD.

  METHOD colorize.
    " ESC[<code>m  <text>  ESC[0m
    result = |{ gv_esc }[{ code }m{ text }{ gv_esc }[0m|.
  ENDMETHOD.

  METHOD magenta.
    result = colorize( text = text code = c_magenta ).
  ENDMETHOD.

  METHOD red.
    result = colorize( text = text code = c_red ).
  ENDMETHOD.

  METHOD green.
    result = colorize( text = text code = c_green ).
  ENDMETHOD.

  METHOD yellow.
    result = colorize( text = text code = c_yellow ).
  ENDMETHOD.

  METHOD cyan.
    result = colorize( text = text code = c_cyan ).
  ENDMETHOD.

ENDCLASS.
