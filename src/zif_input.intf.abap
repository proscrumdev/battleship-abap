"! Abstraction for reading a line of input from the player.
"! The interactive console binding (Node readline) injects a JS
"! implementation of this interface; ABAP unit tests inject a scripted
"! test double. This is the seam that lets the same ABAP game logic run
"! both interactively and headless.
INTERFACE zif_input PUBLIC.
  METHODS read_line
    RETURNING VALUE(line) TYPE string.
ENDINTERFACE.
