"! Orchestrates the game.
"! Output goes to the console via WRITE; input is pulled from an injected
"! zif_input (interactively from the console, or a scripted double in tests).
CLASS zcl_battleship DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_input TYPE REF TO zif_input.

    "! Entry point: greet, place fleets, then run the shooting loop.
    METHODS start.

    "! Parses player input like "B4" into a position. Public so unit
    "! tests can pin the behaviour.
    METHODS parse_position
      IMPORTING input           TYPE string
      RETURNING VALUE(position) TYPE REF TO zcl_position.

  PRIVATE SECTION.
    DATA mo_input     TYPE REF TO zif_input.
    DATA mo_random    TYPE REF TO cl_abap_random_int.
    DATA mt_my_fleet  TYPE zcl_game_controller=>tt_ships.
    DATA mt_enemy     TYPE zcl_game_controller=>tt_ships.

    METHODS initialize_game.
    METHODS initialize_my_fleet.
    METHODS initialize_enemy_fleet.
    METHODS start_game.
    METHODS get_random_position
      RETURNING VALUE(position) TYPE REF TO zcl_position.
    METHODS print_welcome.
    METHODS print_battleship.
    METHODS print_hit_splash.

ENDCLASS.

CLASS zcl_battleship IMPLEMENTATION.

  METHOD constructor.
    mo_input = io_input.
    " Seed the generator from the current time so the computer's shots
    " differ on every run.
    GET TIME.
    mo_random = cl_abap_random_int=>create( seed = CONV i( sy-uzeit ) min = 0 max = 7 ).
  ENDMETHOD.

  METHOD start.
    WRITE / 'Starting...'.
    print_welcome( ).
    initialize_game( ).
    start_game( ).
  ENDMETHOD.

  METHOD initialize_game.
    initialize_my_fleet( ).
    initialize_enemy_fleet( ).
  ENDMETHOD.

  METHOD initialize_my_fleet.
    mt_my_fleet = zcl_game_controller=>initialize_ships( ).

    WRITE / |Please position your fleet (Game board size is from A to H and 1 to 8) :|.

    LOOP AT mt_my_fleet INTO DATA(ship).
      WRITE / ''.
      WRITE / |Please enter the positions for the { ship->name } (size: { ship->size })|.
      DO ship->size TIMES.
        WRITE / |Enter position { sy-index } of { ship->size } (i.e A3):|.
        DATA(input) = mo_input->read_line( ).
        ship->add_position( parse_position( input ) ).
      ENDDO.
    ENDLOOP.
  ENDMETHOD.

  METHOD initialize_enemy_fleet.
    mt_enemy = zcl_game_controller=>initialize_ships( ).

    " Aircraft Carrier - column B, rows 4..8
    mt_enemy[ 1 ]->add_position( NEW zcl_position( column = 'B' row = 4 ) ).
    mt_enemy[ 1 ]->add_position( NEW zcl_position( column = 'B' row = 5 ) ).
    mt_enemy[ 1 ]->add_position( NEW zcl_position( column = 'B' row = 6 ) ).
    mt_enemy[ 1 ]->add_position( NEW zcl_position( column = 'B' row = 7 ) ).
    mt_enemy[ 1 ]->add_position( NEW zcl_position( column = 'B' row = 8 ) ).

    " Battleship - column E, rows 6..9
    mt_enemy[ 2 ]->add_position( NEW zcl_position( column = 'E' row = 6 ) ).
    mt_enemy[ 2 ]->add_position( NEW zcl_position( column = 'E' row = 7 ) ).
    mt_enemy[ 2 ]->add_position( NEW zcl_position( column = 'E' row = 8 ) ).
    mt_enemy[ 2 ]->add_position( NEW zcl_position( column = 'E' row = 9 ) ).

    " Submarine - row 3, columns A..C
    mt_enemy[ 3 ]->add_position( NEW zcl_position( column = 'A' row = 3 ) ).
    mt_enemy[ 3 ]->add_position( NEW zcl_position( column = 'B' row = 3 ) ).
    mt_enemy[ 3 ]->add_position( NEW zcl_position( column = 'C' row = 3 ) ).

    " Destroyer - row 8, columns F..H
    mt_enemy[ 4 ]->add_position( NEW zcl_position( column = 'F' row = 8 ) ).
    mt_enemy[ 4 ]->add_position( NEW zcl_position( column = 'G' row = 8 ) ).
    mt_enemy[ 4 ]->add_position( NEW zcl_position( column = 'H' row = 8 ) ).

    " Patrol Boat - column C, rows 5..6
    mt_enemy[ 5 ]->add_position( NEW zcl_position( column = 'C' row = 5 ) ).
    mt_enemy[ 5 ]->add_position( NEW zcl_position( column = 'C' row = 6 ) ).
  ENDMETHOD.

  METHOD start_game.
    print_battleship( ).

    DO.
      WRITE / ''.
      WRITE / `Player, it's your turn`.
      WRITE / 'Enter coordinates for your shot :'.
      DATA(raw) = mo_input->read_line( ).
      DATA(player_shot) = parse_position( raw ).
      DATA(is_hit) = zcl_game_controller=>check_is_hit(
                       ships = mt_enemy
                       shot  = player_shot ).
      IF is_hit = abap_true.
        print_hit_splash( ).
      ENDIF.
      IF is_hit = abap_true.
        WRITE / 'Yeah ! Nice hit !'.
      ELSE.
        WRITE / 'Miss'.
      ENDIF.

      DATA(computer_shot) = get_random_position( ).
      is_hit = zcl_game_controller=>check_is_hit(
                 ships = mt_my_fleet
                 shot  = computer_shot ).
      WRITE / ''.
      IF is_hit = abap_true.
        WRITE / |Computer shot in { computer_shot->column }{ computer_shot->row } and has hit your ship !|.
      ELSE.
        WRITE / |Computer shot in { computer_shot->column }{ computer_shot->row } and miss|.
      ENDIF.
      IF is_hit = abap_true.
        print_hit_splash( ).
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD parse_position.
    DATA lv_letter TYPE c LENGTH 1.
    lv_letter = to_upper( substring( val = input off = 0 len = 1 ) ).
    DATA(number) = CONV i( substring( val = input off = 1 len = 1 ) ).
    position = NEW zcl_position( column = lv_letter row = number ).
  ENDMETHOD.

  METHOD get_random_position.
    " A random column A..H and a random row.
    DATA(letter) = zcl_game_controller=>letter_from_index( mo_random->get_next( ) + 1 ).
    DATA(number) = mo_random->get_next( ).
    position = NEW zcl_position( column = letter row = number ).
  ENDMETHOD.

  METHOD print_welcome.
    " The welcome banner, printed in magenta.
    WRITE: / zcl_color=>magenta( '                                     |__' ),
           / zcl_color=>magenta( '                                     |\/' ),
           / zcl_color=>magenta( '                                     ---' ),
           / zcl_color=>magenta( '                                     / | [' ),
           / zcl_color=>magenta( '                              !      | |||' ),
           / zcl_color=>magenta( '                            _/|     _/|-++''' ),
           / zcl_color=>magenta( '                        +  +--|    |--|--|_ |-' ),
           / zcl_color=>magenta( '                     { /|__|  |/\__|  |--- |||__/' ),
           / zcl_color=>magenta( '                    +---------------___[}-_===_.''____                 /\' ),
           / zcl_color=>magenta( '                ____`-'' ||___-{]_| _[}-  |     |_[___\==--            \/   _' ),
           / zcl_color=>magenta( ' __..._____--==/___]_|__|_____________________________[___\==--____,------'' .7' ),
           / zcl_color=>magenta( '|                        Welcome to Battleship                         BB-61/' ),
           / zcl_color=>magenta( ' \_________________________________________________________________________|' ).
  ENDMETHOD.

  METHOD print_battleship.
    WRITE: / '                  __',
           / '                 /  \',
           / '           .-.  |    |',
           / '   *    _.-''  \  \__/',
           / '    \.-''       \',
           / '   /          _/',
           / '  |      _  /',
           / '  |     /_\''',
           / '   \    \_/',
           / '    """"'.
  ENDMETHOD.

  METHOD print_hit_splash.
    WRITE: / '                \         .  ./',
           / '              \      .:";''.:.."   /',
           / '                  (M^^.^~~:.''").',
           / '            -   (/  .    . . \ \)  -',
           / '               ((| :. ~ ^  :. .|))',
           / '            -   (\- |  \ /  |  /)  -',
           / '                 -\  \     /  /-',
           / '                   \  \   /  /'.
  ENDMETHOD.

ENDCLASS.
