"! ABAP Unit tests for the pure game logic. Run them with:
"!   npm test        (transpiles, then executes output/index.mjs)
CLASS ltcl_game DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS initialize_builds_five_ships FOR TESTING.
    METHODS hit_on_matching_position    FOR TESTING.
    METHODS miss_on_empty_water         FOR TESTING.
    METHODS ship_valid_when_full        FOR TESTING.
    METHODS scripted_input_replays      FOR TESTING.

    METHODS build_single_ship_fleet
      IMPORTING column         TYPE c
                row            TYPE i
      RETURNING VALUE(r_ships) TYPE zcl_game_controller=>tt_ships.

ENDCLASS.

CLASS ltcl_game IMPLEMENTATION.

  METHOD initialize_builds_five_ships.
    DATA(ships) = zcl_game_controller=>initialize_ships( ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ships )
      exp = 5
      msg = 'A fresh fleet should hold five ships' ).
    cl_abap_unit_assert=>assert_equals(
      act = ships[ 1 ]->size
      exp = 5
      msg = 'The Aircraft Carrier has size 5' ).
  ENDMETHOD.

  METHOD hit_on_matching_position.
    DATA(ships) = build_single_ship_fleet( column = 'B' row = 4 ).
    DATA(result) = zcl_game_controller=>check_is_hit(
      ships = ships
      shot  = NEW zcl_position( column = 'B' row = 4 ) ).
    cl_abap_unit_assert=>assert_true(
      act = result
      msg = 'Shot on the ship position must be a hit' ).
  ENDMETHOD.

  METHOD miss_on_empty_water.
    DATA(ships) = build_single_ship_fleet( column = 'B' row = 4 ).
    DATA(result) = zcl_game_controller=>check_is_hit(
      ships = ships
      shot  = NEW zcl_position( column = 'A' row = 1 ) ).
    cl_abap_unit_assert=>assert_false(
      act = result
      msg = 'Shot on empty water must be a miss' ).
  ENDMETHOD.

  METHOD ship_valid_when_full.
    DATA(ship) = NEW zcl_ship( name = 'Patrol Boat' size = 2 ).
    cl_abap_unit_assert=>assert_false(
      act = zcl_game_controller=>is_ship_valid( ship )
      msg = 'An empty ship is not yet valid' ).
    ship->add_position( NEW zcl_position( column = 'C' row = 5 ) ).
    ship->add_position( NEW zcl_position( column = 'C' row = 6 ) ).
    cl_abap_unit_assert=>assert_true(
      act = zcl_game_controller=>is_ship_valid( ship )
      msg = 'A fully positioned ship is valid' ).
  ENDMETHOD.

  METHOD scripted_input_replays.
    DATA(input) = NEW zcl_input_scripted( VALUE #( ( `B4` ) ( `H8` ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = input->zif_input~read_line( )
      exp = `B4` ).
    cl_abap_unit_assert=>assert_equals(
      act = input->zif_input~read_line( )
      exp = `H8` ).
  ENDMETHOD.

  METHOD build_single_ship_fleet.
    DATA(ship) = NEW zcl_ship( name = 'Test' size = 1 ).
    ship->add_position( NEW zcl_position( column = column row = row ) ).
    APPEND ship TO r_ships.
  ENDMETHOD.

ENDCLASS.
