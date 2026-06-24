"! Pure game logic, no I/O. Mirrors GameController/gameController.js.
"! Also hosts the A..H letter mapping that letters.js provided.
CLASS zcl_game_controller DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_ships TYPE STANDARD TABLE OF REF TO zcl_ship WITH EMPTY KEY.

    "! Builds the standard fleet of five ships (no positions yet).
    CLASS-METHODS initialize_ships
      RETURNING VALUE(ships) TYPE tt_ships.

    "! True if any position of any ship equals the shot.
    CLASS-METHODS check_is_hit
      IMPORTING ships         TYPE tt_ships
                shot          TYPE REF TO zcl_position
      RETURNING VALUE(result) TYPE abap_bool
      RAISING   cx_parameter_invalid_range.

    "! True once a ship occupies as many positions as its size.
    CLASS-METHODS is_ship_valid
      IMPORTING ship          TYPE REF TO zcl_ship
      RETURNING VALUE(result) TYPE abap_bool.

    "! Column letter for a 1-based index, e.g. 2 -> 'B'. Replaces letters.js.
    CLASS-METHODS letter_from_index
      IMPORTING index         TYPE i
      RETURNING VALUE(letter) TYPE c.

ENDCLASS.

CLASS zcl_game_controller IMPLEMENTATION.

  METHOD initialize_ships.
    APPEND NEW zcl_ship( name = 'Aircraft Carrier' size = 5 ) TO ships.
    APPEND NEW zcl_ship( name = 'Battleship'       size = 4 ) TO ships.
    APPEND NEW zcl_ship( name = 'Submarine'        size = 3 ) TO ships.
    APPEND NEW zcl_ship( name = 'Destroyer'        size = 3 ) TO ships.
    APPEND NEW zcl_ship( name = 'Patrol Boat'      size = 2 ) TO ships.
  ENDMETHOD.

  METHOD check_is_hit.
    IF shot IS NOT BOUND.
      RAISE EXCEPTION TYPE cx_parameter_invalid_range
        EXPORTING parameter = 'shot'.
    ENDIF.

    result = abap_false.
    LOOP AT ships INTO DATA(ship).
      LOOP AT ship->positions INTO DATA(position).
        IF position->row = shot->row AND position->column = shot->column.
          result = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_ship_valid.
    result = boolc( lines( ship->positions ) = ship->size ).
  ENDMETHOD.

  METHOD letter_from_index.
    CONSTANTS lc_letters TYPE c LENGTH 8 VALUE 'ABCDEFGH'.
    DATA lv_offset TYPE i.
    IF index >= 1 AND index <= 8.
      lv_offset = index - 1.
      letter = lc_letters+lv_offset(1).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
