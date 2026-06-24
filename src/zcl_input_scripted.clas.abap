"! A scripted zif_input test double: hand it a list of lines and it
"! returns them one per read_line( ) call. Lets the game run headless in
"! ABAP unit tests, the same way the Node shim drives it interactively.
CLASS zcl_input_scripted DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_input.
    TYPES tt_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS constructor
      IMPORTING lines TYPE tt_lines.

  PRIVATE SECTION.
    DATA mt_lines TYPE tt_lines.
    DATA mv_index TYPE i.

ENDCLASS.

CLASS zcl_input_scripted IMPLEMENTATION.

  METHOD constructor.
    mt_lines = lines.
  ENDMETHOD.

  METHOD zif_input~read_line.
    mv_index = mv_index + 1.
    READ TABLE mt_lines INDEX mv_index INTO line.
  ENDMETHOD.

ENDCLASS.
