#!/bin/sh
# Show a regex grader both ways: on a reply it must pass, and on one it must fail.
#
#   grader-check.sh [--require <case>]... [<case>]
#
# An eval case's `regex` grader is a JavaScript RegExp, so this runs each pattern in node, with
# the grader's flags, on replies kept in scripts/grader-replies/<case>/:
#
#   <grader>.pass.md     the pattern must match it
#   <grader>.fail.md     the pattern must not match it (also <grader>.fail-2.md, and so on)
#
# <case> is the eval case's name, its folder under plugins/shipkit/evals/ with / read as -, and
# <grader> is the grader file's name without .md. One line is printed for each reply: `PASS`
# when the pattern did what the file's name says, `FAIL` when it did not. A `FAIL` is also
# printed for a reply folder that names no case, a reply whose grader does not exist or is not
# a regex grader, a pattern node cannot compile, and a grader with a pass reply and no fail
# reply, or the reverse. With a <case>, only that folder is read. `--require <case>` also fails
# each regex grader of that case that has no replies at all. The last line is
# "grader-check: <n> as expected, <m> not".
#
# This is the verifier plan's rules 18 and 23 as a command: a grader that has only been shown
# to pass is a number moved, not a number fixed. The replies are written by hand. They show
# what the pattern does with a reply, not what a model says.
#
# GRADER_EVALS and GRADER_REPLIES name other folders (the smoke check uses scratch ones).
# Exit status: 0 when every line is PASS; 1 when one is FAIL; 2 on usage, or with no node.
# Spec: .shipkit/specs/misses-to-checks/ (REQ-40).

ROOT=$(cd "$(dirname "$0")/.." && pwd)
EVALS=${GRADER_EVALS:-$ROOT/plugins/shipkit/evals}
REPLIES=${GRADER_REPLIES:-$ROOT/scripts/grader-replies}
usage() { echo "usage: grader-check.sh [--require <case>]... [<case>]" >&2; exit 2; }

ONLY=""; NEED=""
while [ $# -gt 0 ]; do
  case "$1" in
    --require) [ $# -ge 2 ] && [ -n "$2" ] || usage; NEED="$NEED $2"; shift ;;
    -*) usage ;;
    *) [ -z "$ONLY" ] || usage; ONLY=$1 ;;
  esac
  shift
done
command -v node >/dev/null 2>&1 || {
  echo "grader-check: node not found: a regex grader is a JavaScript RegExp, and node reads it" >&2; exit 2; }

GC_EVALS="$EVALS" GC_REPLIES="$REPLIES" GC_ONLY="$ONLY" GC_REQUIRE="$NEED" node - <<'JS'
const fs = require('fs'), path = require('path');
const evals = process.env.GC_EVALS, replies = process.env.GC_REPLIES;
const only = process.env.GC_ONLY || '';
const need = (process.env.GC_REQUIRE || '').split(' ').filter(Boolean);
let ok = 0, bad = 0;
const pass = (m) => { console.log('PASS  ' + m); ok++; };
const fail = (m) => { console.log('FAIL  ' + m); bad++; };

// Every eval case: a folder with a prompt.md, outside any folder named fixtures.
const cases = {};
(function walk(dir, rel) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch (e) { return; }
  for (const e of entries) {
    if (e.isDirectory()) { if (e.name !== 'fixtures') walk(path.join(dir, e.name), rel.concat(e.name)); }
    else if (e.name === 'prompt.md' && rel.length) cases[rel.join('-')] = dir;
  }
})(evals, []);

// A grader file's pattern and flags, as a RegExp; or why not.
function grader(file) {
  const fm = fs.readFileSync(file, 'utf8').match(/^---\n([\s\S]*?)\n---/);
  if (!fm) return { err: 'the grader has no frontmatter' };
  const get = (k) => { const r = fm[1].match(new RegExp('^' + k + ':[ \\t]*(.*)$', 'm')); return r ? r[1].trim() : null; };
  const unquote = (v) => {
    if (v.length >= 2 && v[0] === "'" && v[v.length - 1] === "'") return v.slice(1, -1).replace(/''/g, "'");
    if (v.length >= 2 && v[0] === '"' && v[v.length - 1] === '"') return JSON.parse(v);
    return v;
  };
  const type = get('type');
  if (type !== 'regex') return { err: 'not a regex grader (type: ' + type + ')', other: true };
  const p = get('pattern');
  if (p === null) return { err: 'the grader has no pattern' };
  try { return { re: new RegExp(unquote(p), unquote(get('flags') || '')) }; }
  catch (e) { return { err: 'the pattern does not compile in node: ' + e.message }; }
}

let dirs = [];
try { dirs = fs.readdirSync(replies, { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name).sort(); }
catch (e) { /* no replies folder: nothing to read */ }
if (only) {
  if (dirs.indexOf(only) < 0) fail(only + ': no replies folder');
  dirs = dirs.filter((d) => d === only);
}

const seen = {};
for (const c of dirs) {
  if (!cases[c]) { fail(c + ': no eval case has that name'); continue; }
  seen[c] = {};
  for (const f of fs.readdirSync(path.join(replies, c)).sort()) {
    const m = f.match(/^(.+)\.(pass|fail)(-\d+)?\.md$/);
    if (!m) { fail(c + ' ' + f + ': not a reply file name (<grader>.pass.md or <grader>.fail.md)'); continue; }
    const g = m[1], kind = m[2], gfile = path.join(cases[c], 'graders', g + '.md');
    if (!fs.existsSync(gfile)) { fail(c + ' ' + f + ': the case has no grader ' + g + '.md'); continue; }
    const gr = grader(gfile);
    if (gr.err) { fail(c + ' ' + f + ': ' + gr.err); continue; }
    const s = seen[c][g] = seen[c][g] || { pass: 0, fail: 0 };
    s[kind]++;
    const hit = gr.re.test(fs.readFileSync(path.join(replies, c, f), 'utf8'));
    if (hit === (kind === 'pass')) pass(c + ' ' + f + ': ' + (hit ? 'matched, as it must' : 'not matched, as it must not be'));
    else fail(c + ' ' + f + ': ' + (hit ? 'matched, and it must not' : 'not matched, and it must'));
  }
  for (const g of Object.keys(seen[c]).sort()) {
    if (!seen[c][g].pass) fail(c + ' ' + g + ': a fail reply and no pass reply');
    if (!seen[c][g].fail) fail(c + ' ' + g + ': a pass reply and no fail reply');
  }
}

for (const c of need) {
  if (!cases[c]) { fail(c + ': required, and no eval case has that name'); continue; }
  let files = [];
  try { files = fs.readdirSync(path.join(cases[c], 'graders')).filter((f) => f.endsWith('.md')).sort(); } catch (e) { /* none */ }
  for (const f of files) {
    const g = f.slice(0, -3);
    if (grader(path.join(cases[c], 'graders', f)).other) continue;
    if (!(seen[c] && seen[c][g])) fail(c + ' ' + g + ': no replies in ' + path.join(path.basename(replies), c));
  }
}

console.log('grader-check: ' + ok + ' as expected, ' + bad + ' not');
process.exit(bad ? 1 : 0);
JS
