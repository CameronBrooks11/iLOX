#!/usr/bin/env bash
# Run the iLOX checks and exit non-zero if any fails. OPENSCAD names the binary (default: openscad); tessella must
# resolve as <tessella/tess.scad>: beside iLOX.scad, on OPENSCADPATH or in the OpenSCAD libraries folder.
set -u
cd "$(dirname "$0")/.." || exit 1
scad=${OPENSCAD:-openscad}
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
failed=0

run() { "$scad" "$@" -o "$out/out.stl" >"$out/log" 2>&1; }
ok() { echo "ok    $1"; }
fail() {
    echo "FAIL  $1"
    sed 's/^/      /' "$out/log"
    failed=1
}

if run --hardwarnings tests/clearance/clearance_check.scad; then ok clearance_check; else fail clearance_check; fi

# The file's own range assertion gives the last case. Every case must stop on one of calc_ucell's assertions, whose
# messages start "ERROR:"; a parser error does not count.
run -D case=-1 tests/clearance/rejected_inputs.scad
last=$(grep -o 'case must be 0 to [0-9]*' "$out/log" | grep -o '[0-9]*$')
if [ -z "$last" ]; then
    fail "rejected_inputs: case count"
else
    for i in $(seq 0 "$last"); do
        if ! run -D "case=$i" tests/clearance/rejected_inputs.scad && grep -q 'failed: "ERROR: ' "$out/log"; then
            ok "rejected_inputs case $i"
        else
            fail "rejected_inputs case $i"
        fi
    done
fi

if ! run --hardwarnings -D shift=0.19 tests/clearance/radial_gap.scad &&
    grep -q 'top level object is empty' "$out/log"; then
    ok "radial_gap 0.19 apart"
else
    fail "radial_gap 0.19 apart"
fi
if run --hardwarnings -D shift=0.21 tests/clearance/radial_gap.scad; then
    ok "radial_gap 0.21 touching"
else
    fail "radial_gap 0.21 touching"
fi

for f in examples/simpleUsage/*.scad; do
    for part in both A B; do
        if run --hardwarnings -D "part=\"$part\"" "$f"; then ok "$f part=$part"; else fail "$f part=$part"; fi
    done
done

exit $failed
