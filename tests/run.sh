#!/usr/bin/env bash
# Run the iLOX checks and exit non-zero if any fails. OPENSCAD names the binary (default: openscad); tessella must
# resolve as <tessella/tess.scad>, beside iLOX.scad or on OPENSCADPATH.
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

# Every case must stop on one of calc_ucell's assertions, whose messages start "ERROR:"; a parser error does not count.
# The out-of-range index ends the loop.
for i in $(seq 0 99); do
    run -D "case=$i" tests/clearance/rejected_inputs.scad
    rc=$?
    grep -q 'case must be 0 to' "$out/log" && break
    if [ $rc -ne 0 ] && grep -q 'failed: "ERROR: ' "$out/log"; then ok "rejected_inputs case $i"; else fail "rejected_inputs case $i"; fi
done
[ "$i" -gt 0 ] || fail "rejected_inputs: no cases ran"

if ! run -D shift=0.19 tests/clearance/radial_gap.scad && grep -q 'top level object is empty' "$out/log"; then ok "radial_gap 0.19 apart"; else fail "radial_gap 0.19 apart"; fi
if run -D shift=0.21 tests/clearance/radial_gap.scad; then ok "radial_gap 0.21 touching"; else fail "radial_gap 0.21 touching"; fi

for f in examples/simpleUsage/*.scad; do
    for part in both A B; do
        if run --hardwarnings -D "part=\"$part\"" "$f"; then ok "$f part=$part"; else fail "$f part=$part"; fi
    done
done

exit $failed
