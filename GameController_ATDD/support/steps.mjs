// Cucumber step definitions for isShipValid.feature.
//
// This is the ABAP counterpart of GameController_ATDD/support/steps.js in the
// battleship-nodejs repository. The *.feature file is identical in both repos:
// only the wiring differs. Here the steps drive the TRANSPILED ABAP classes
// (zcl_ship, zcl_position, zcl_game_controller) on Node.js — exactly the same
// logic you would call from ABAP Unit inside a SAP system.
//
// Run with:  npm run cucumber   (transpiles the ABAP first, then runs cucumber-js)

import { Given, When, Then, BeforeAll, defineParameterType } from "@cucumber/cucumber";
import { strict as assert } from "node:assert";

import { initializeABAP } from "../../output/init.mjs";
import { zcl_ship } from "../../output/zcl_ship.clas.mjs";
import { zcl_position } from "../../output/zcl_position.clas.mjs";
import { zcl_game_controller } from "../../output/zcl_game_controller.clas.mjs";

let ship;
let actual;

// Boot the ABAP runtime once before any scenario runs.
BeforeAll(async function () {
  await initializeABAP();
});

defineParameterType({
  name: "bool",
  regexp: /"([^"]*)"/,
  transformer(text) {
    return text.toLowerCase() === "true";
  },
});

Given("I have a {int} ship with {int} positions", async function (size, positions) {
  ship = await new zcl_ship().constructor_({ name: "Ship", size });
  for (let i = 1; i <= positions; i++) {
    const pos = await new zcl_position().constructor_({ column: "A", row: i });
    await ship.add_position({ position: pos });
  }
});

When("I check if the ship is valid", async function () {
  // is_ship_valid returns an ABAP_BOOL ('X' = true, ' ' = false).
  const result = await zcl_game_controller.is_ship_valid({ ship });
  actual = result.get() === "X";
});

Then("the result should be {bool}", function (expected) {
  assert.strictEqual(actual, expected);
});
