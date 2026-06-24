// Interactive console binding ("Node shim") for the ABAP Battleship game.
//
// The ABAP source contains NO stdin handling — ABAP has no native concept of
// reading from a keyboard. Instead the game pulls every line of input through
// the ZIF_INPUT interface. Here we provide a JavaScript implementation of that
// interface backed by Node's readline, and inject it into ZCL_BATTLESHIP.
// WRITE statements in ABAP already stream straight to stdout via the runtime's
// StandardOutConsole, so output needs no bridging.
//
// Run with:  npm start     (transpiles, then launches this file)

import readline from "node:readline";
import { initializeABAP } from "./output/init.mjs";
import { zcl_battleship } from "./output/zcl_battleship.clas.mjs";

const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: false });

// Bridge readline's event model to the synchronous-looking ABAP read_line():
// pending lines are buffered; an awaiting read_line() parks a resolver.
const pending = [];
let waiting = null;

rl.on("line", (line) => {
  if (waiting) {
    const resolve = waiting;
    waiting = null;
    resolve(line);
  } else {
    pending.push(line);
  }
});

// The game loops forever; EOF / Ctrl+C ends the process.
rl.on("close", () => process.exit(0));

const consoleInput = {
  getQualifiedName: () => "ZIF_INPUT",
  async zif_input$read_line() {
    if (pending.length > 0) {
      return pending.shift();
    }
    return new Promise((resolve) => {
      waiting = resolve;
    });
  },
};

await initializeABAP();
const game = await new zcl_battleship().constructor_({ io_input: consoleInput });
await game.start();
