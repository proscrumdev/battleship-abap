# Battleship ABAP

A simple game of Battleship, written in **ABAP**. The purpose of this repository
is to serve as an entry point into coding exercises, and it was especially
created for scrum.org's *Applying Professional Scrum for Software Development*
course (www.scrum.org/apssd). **The code in this repository is unfinished by
design** – and some of its bugs are intentional, to be discovered and discussed
during the training.

## No SAP system required

You do **not** need a SAP system, SAP GUI or any Docker image to run this. The
ABAP source is translated to JavaScript by the
[abaplint transpiler](https://github.com/abaplint/transpiler) and executed on
Node.js using the [`@abaplint/runtime`](https://www.npmjs.com/package/@abaplint/runtime)
(the [open-abap](https://open-abap.org/) ecosystem). The only prerequisite is
[Node.js](https://nodejs.org/) (version 18 or newer).

> The `.abap` files are real, abapGit-compatible ABAP. If you do have a SAP
> system, you can pull the same code in via abapGit and explore it in SE80 / ADT.
> For the training that is optional.

# Getting started

To edit and debug this project, you can use
[Visual Studio Code](https://code.visualstudio.com/) or any other suitable editor.
For ABAP syntax highlighting and on-the-fly error checking (just like ADT / SE80),
install the **abaplint** extension:

* abaplint – https://marketplace.visualstudio.com/items?itemName=larshp.vscode-abaplint

## Run locally

Install packages (first time only):

```bash
npm install
```

Run battleship:

```bash
npm start
```

`npm start` transpiles the ABAP to JavaScript and then launches the game. You
place your fleet and fire shots by typing coordinates such as `B4`. The game
loops forever (just like the original) – stop it with `Ctrl+C`.

## Execute tests

Run all ABAP Unit tests:

```bash
npm test
```

This transpiles the sources and runs every `FOR TESTING` method. A run that ends
with exit code `0` and no error messages means all tests passed:

```bash
npm test; echo "Exit code: $?"
```

# How it works

ABAP normally runs inside a SAP system, so two things need bridging to make it a
plain console app:

* **Output** – `WRITE` statements stream straight to the console (stdout).
* **Input** – ABAP has no native keyboard input. The game therefore reads every
  line through the [`zif_input`](src/zif_input.intf.abap) interface. The small
  Node shim [`start.mjs`](start.mjs) implements that interface using Node's
  `readline` and injects it into `ZCL_BATTLESHIP`. The unit tests inject
  [`zcl_input_scripted`](src/zcl_input_scripted.clas.abap) instead – the same
  seam, driven by a predefined list of lines.

This separation (I/O behind an interface, pure logic in its own classes) is what
makes the game both interactively playable and unit-testable. It is a good
talking point for the training.

## Project structure

| File | Role | Node.js counterpart |
|------|------|---------------------|
| [`src/zcl_position.clas.abap`](src/zcl_position.clas.abap) | A board coordinate | `GameController/position.js` |
| [`src/zcl_ship.clas.abap`](src/zcl_ship.clas.abap) | A ship and its positions | `GameController/ship.js` |
| [`src/zcl_game_controller.clas.abap`](src/zcl_game_controller.clas.abap) | Pure game logic + A–H letters | `gameController.js` + `letters.js` |
| [`src/zcl_battleship.clas.abap`](src/zcl_battleship.clas.abap) | Game flow & console output | `battleship.js` |
| [`src/zcl_color.clas.abap`](src/zcl_color.clas.abap) | ANSI colour helper | the `cli-color` dependency |
| [`src/zif_input.intf.abap`](src/zif_input.intf.abap) | Input abstraction | the `readline` calls |
| [`src/zcl_input_scripted.clas.abap`](src/zcl_input_scripted.clas.abap) | Test double for input | – |
| [`src/zcl_game_controller.clas.testclasses.abap`](src/zcl_game_controller.clas.testclasses.abap) | ABAP Unit tests | the Mocha tests |
| [`start.mjs`](start.mjs) | Node shim: keyboard ↔ `zif_input` | – |


Have fun – and remember, the code is unfinished on purpose.
