set core:volume:name to core:tag.
if not exists(core:volume:name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", core:volume:name + ":/lib/main.ks"). }
runoncepath(core:volume:name + ":/lib/main.ks").

set terminal:width to 50.
set terminal:height to 50.
set terminal:charwidth to 18.
set terminal:charheight to 18.

Require("/lib/record_lift.ks", True).
