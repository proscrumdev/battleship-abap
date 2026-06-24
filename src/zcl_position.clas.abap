"! A single board coordinate, e.g. column 'B', row 4.
"! Mirrors GameController/position.js.
CLASS zcl_position DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    DATA column TYPE c LENGTH 1 READ-ONLY.
    DATA row    TYPE i READ-ONLY.

    METHODS constructor
      IMPORTING column TYPE c
                row    TYPE i.

    "! @parameter result | e.g. "B4"
    METHODS to_string
      RETURNING VALUE(result) TYPE string.

ENDCLASS.

CLASS zcl_position IMPLEMENTATION.

  METHOD constructor.
    me->column = column.
    me->row    = row.
  ENDMETHOD.

  METHOD to_string.
    DATA lv_row TYPE string.
    lv_row = me->row.
    CONDENSE lv_row.
    result = me->column && lv_row.
  ENDMETHOD.

ENDCLASS.
