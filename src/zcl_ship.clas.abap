"! A ship with a name, a size and the positions it occupies.
"! Mirrors GameController/ship.js (the cli-color "color" attribute is
"! dropped, it carried no game logic).
CLASS zcl_ship DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_positions TYPE STANDARD TABLE OF REF TO zcl_position WITH EMPTY KEY.

    DATA name      TYPE string READ-ONLY.
    DATA size      TYPE i READ-ONLY.
    DATA positions TYPE tt_positions READ-ONLY.

    METHODS constructor
      IMPORTING name TYPE string
                size TYPE i.

    METHODS add_position
      IMPORTING position TYPE REF TO zcl_position.

ENDCLASS.

CLASS zcl_ship IMPLEMENTATION.

  METHOD constructor.
    me->name = name.
    me->size = size.
  ENDMETHOD.

  METHOD add_position.
    APPEND position TO me->positions.
  ENDMETHOD.

ENDCLASS.
