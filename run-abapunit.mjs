// Runs the ABAP Unit tests and writes a JUnit XML report (testresults_abapunit.xml)
// so the results show up in CI test dashboards next to the Cucumber results.
//
// The transpiler generates output/index.mjs with a hardcoded inventory of test
// classes/methods but only logs to the console. We reuse that inventory (so new
// FOR TESTING methods are picked up automatically) and run each test in
// isolation to capture per-test pass/fail.
//
// Run with:  npm run abapunit   (transpiles first, then executes this file)

import { readFileSync, writeFileSync } from "node:fs";
import { initializeABAP } from "./output/init.mjs";

// Reuse the generated test inventory: lift the getData() function out of the
// generated runner and import it as a module.
const generated = readFileSync("./output/index.mjs", "utf8");
const match = generated.match(/function getData\(\)[\s\S]*?return ret;\s*\n\}/);
if (!match) {
  console.error("Could not read the test inventory from output/index.mjs");
  process.exit(1);
}
writeFileSync("./output/_inventory.mjs", "export " + match[0]);
const { getData } = await import("./output/_inventory.mjs");

await initializeABAP();

const xmlEscape = (s) =>
  String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

const suites = [];
let totalTests = 0;
let totalFailures = 0;

for (const st of getData()) {
  const imported = await import("./output/" + st.filename.replace(/^\.\//, ""));
  const localClass = imported[st.localClass];
  if (localClass.class_setup) await localClass.class_setup();

  const cases = [];
  for (const m of st.methods) {
    totalTests++;
    const name = `${st.localClass}->${m.name}`;
    if (m.skip) {
      cases.push(`    <testcase classname="${xmlEscape(st.objectName)}" name="${xmlEscape(m.name)}"><skipped/></testcase>`);
      console.log(`SKIP ${name}`);
      continue;
    }
    const started = Date.now();
    try {
      const test = await new localClass().constructor_();
      if (test.setup) await test.setup();
      if (test.FRIENDS_ACCESS_INSTANCE.setup) await test.FRIENDS_ACCESS_INSTANCE.setup();
      if (test.FRIENDS_ACCESS_INSTANCE.SUPER && test.FRIENDS_ACCESS_INSTANCE.SUPER.setup) await test.FRIENDS_ACCESS_INSTANCE.SUPER.setup();
      await test.FRIENDS_ACCESS_INSTANCE[m.name]();
      if (test.teardown) await test.teardown();
      if (test.FRIENDS_ACCESS_INSTANCE.teardown) await test.FRIENDS_ACCESS_INSTANCE.teardown();
      if (test.FRIENDS_ACCESS_INSTANCE.SUPER && test.FRIENDS_ACCESS_INSTANCE.SUPER.teardown) await test.FRIENDS_ACCESS_INSTANCE.SUPER.teardown();
      const time = (Date.now() - started) / 1000;
      cases.push(`    <testcase classname="${xmlEscape(st.objectName)}" name="${xmlEscape(m.name)}" time="${time}"/>`);
      console.log(`PASS ${name}`);
    } catch (err) {
      totalFailures++;
      const time = (Date.now() - started) / 1000;
      const message = err && err.message ? err.message : String(err);
      cases.push(
        `    <testcase classname="${xmlEscape(st.objectName)}" name="${xmlEscape(m.name)}" time="${time}">\n` +
        `      <failure message="${xmlEscape(message)}">${xmlEscape(err && err.stack ? err.stack : message)}</failure>\n` +
        `    </testcase>`
      );
      console.log(`FAIL ${name}: ${message}`);
    }
  }

  if (localClass.class_teardown) await localClass.class_teardown();

  const suiteFailures = cases.filter((c) => c.includes("<failure")).length;
  suites.push(
    `  <testsuite name="${xmlEscape(st.objectName)}.${xmlEscape(st.localClass)}" tests="${st.methods.length}" failures="${suiteFailures}">\n` +
    cases.join("\n") +
    `\n  </testsuite>`
  );
}

const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<testsuites tests="${totalTests}" failures="${totalFailures}">\n${suites.join("\n")}\n</testsuites>\n`;
writeFileSync("testresults_abapunit.xml", xml);

console.log(`\nABAP Unit: ${totalTests} test(s), ${totalFailures} failure(s) -> testresults_abapunit.xml`);
process.exit(totalFailures > 0 ? 1 : 0);
