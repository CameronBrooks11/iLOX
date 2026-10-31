# Pilot coupons

Small iLOX joints for finding the clearance window: the gaps at which a printed pair fuses, latches or falls apart, and how far the printed gap departs from nominal. The window they find sets the clearances for the specimens in [`../tensile`](../tensile/README.md), which go on the test machine.

`coupon.scad` builds one coupon, laid out to print:

- `set = "linear"`: three A rails and two B rails, 20 mm long, on a 30 × 20 mm substrate. The halves slide together along the rails.
- `set = "radial"`: seven A pins and three B pins on a substrate about 26 × 25 mm. Each B pin sits among three A pins.
- `part = "A"` prints A substrate down; `"B"` prints B turned over, substrate down; `"both"` prints the pair assembled, in place.

Both sets use the cell of `examples/simpleUsage`, 5 mm wide and 10 mm tall, with `tip_clearance` 0.2 mm. Each half has a tab engraved with set, part, clearance and substrate thickness, such as `L-A 0.15/1`; an in-place pair has one tab, on A.

## The ladder

`ladder.csv` lists 96 coupons: both sets, at substrate thicknesses of 1 and 2 mm, at clearances of 0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4 and 0.5 mm, each as A, B and both. Substrate thickness is a variable because the halves engage by flexing the substrate. Export them with [scadbatch](https://github.com/CameronBrooks11/scadbatch):

```
scadbatch export specimens/pilot/coupon.scad specimens/pilot/ladder.csv out/
```

Print each coupon as many times as the pilot needs. `tests/run.sh` exports every row.

## Record with each print

The iLOX commit the STLs came from (`git rev-parse --short HEAD`): the meaning of `clearance` changed in #22, the tip gap arrived in #23, and the radial spacing changed in #32. Fill in [print-settings.md](print-settings.md) once per batch and keep the slicer profile beside it.
