"! Unit test for zcl_battleship->parse_position.
CLASS ltcl_parse_position DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS returns_position_for_valid_in FOR TESTING.
ENDCLASS.

CLASS ltcl_parse_position IMPLEMENTATION.

  METHOD returns_position_for_valid_in.
    " No input is read here, so an empty scripted input is enough.
    DATA(game) = NEW zcl_battleship( NEW zcl_input_scripted( VALUE #( ) ) ).

    DATA(actual) = game->parse_position( 'B3' ).

    cl_abap_unit_assert=>assert_equals(
      act = actual->column
      exp = 'B'
      msg = 'Column should be parsed as B' ).
    cl_abap_unit_assert=>assert_equals(
      act = actual->row
      exp = 3
      msg = 'Row should be parsed as 3' ).
  ENDMETHOD.

ENDCLASS.
