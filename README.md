# Battleship ABAP

A simple game of Battleship, written in ABAP. The purpose of this repository is to serve as an entry point into coding exercises and it was especially created for scrum.orgs Applying Professional Scrum for Software Development course (www.scrum.org/apssd). The code in this repository is unfinished by design.

You do **not** need a SAP system to run this. The ABAP source is translated to JavaScript by the [abaplint transpiler](https://github.com/abaplint/transpiler) and executed on Node.js using the [`@abaplint/runtime`](https://www.npmjs.com/package/@abaplint/runtime) (the [open-abap](https://open-abap.org/) ecosystem). The only prerequisite is [Node.js](https://nodejs.org/) (version 18 or newer). The `.abap` files are real, abapGit-compatible ABAP, so if you do have a SAP system you can also pull the same code in via abapGit and explore it in SE80 / ADT.

# Getting started

To edit and debug this project, you can use [Visual Studio Code](https://code.visualstudio.com/) or any other suitable editor.
You might want to install this extension to better support this project in VSCode:
* abaplint (ABAP language support) https://marketplace.visualstudio.com/items?itemName=larshp.vscode-abaplint

## Run locally

Install packages

```bash
npm install
```

Run battleship

```bash
npm start
```

Or alternatively:
```bash
npm run build
node start.mjs
```

## Execute tests

Execute all tests
```bash
npm test
```

Execute ABAP Unit tests only
```bash
npm run abapunit
```

Execute Cucumber-js tests only
```bash
npm run cucumber
```

## Docker

To run and test the project in a container, use these steps:

```bash
docker run -it -v ${PWD}:/battleship -w /battleship node bash
```

```bash
npm install
npm test
npm start
```

The first build downloads the open-abap runtime classes from GitHub, so the container needs internet access.

# How it works

ABAP normally runs inside a SAP system, so two things need bridging to make it a plain console app:

* **Output** – `WRITE` statements stream straight to the console (stdout).
* **Input** – ABAP has no native keyboard input. The game therefore reads every line through the [`zif_input`](src/zif_input.intf.abap) interface. The small Node shim [`start.mjs`](start.mjs) implements that interface using Node's `readline` and injects it into `ZCL_BATTLESHIP`. The unit tests inject [`zcl_input_scripted`](src/zcl_input_scripted.clas.abap) instead – the same seam, driven by a predefined list of lines.

This separation (I/O behind an interface, pure logic in its own classes) is what makes the game both interactively playable and testable. It is a good talking point for the training.

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
| [`GameController_ATDD/isShipValid.feature`](GameController_ATDD/isShipValid.feature) | Gherkin acceptance spec | `GameController_ATDD/isShipValid.feature` |
| [`GameController_ATDD/support/steps.mjs`](GameController_ATDD/support/steps.mjs) | Cucumber step definitions | `GameController_ATDD/support/steps.js` |
| [`start.mjs`](start.mjs) | Node shim: keyboard ↔ `zif_input` | – |

Have fun – and remember, the code is unfinished on purpose.
