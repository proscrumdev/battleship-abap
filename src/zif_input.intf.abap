"! Abstraction for reading a line of input from the player.
"! The interactive console binding injects an implementation of this
"! interface; unit tests inject a scripted test double. This seam lets the
"! game logic run both interactively and headless.
INTERFACE zif_input PUBLIC.
  METHODS read_line
    RETURNING VALUE(line) TYPE string.
ENDINTERFACE.
