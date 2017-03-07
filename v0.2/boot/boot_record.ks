set core:volume:name to core:tag.
if not exists(core:volume:name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", core:volume:name + ":/lib/main.ks"). }
runoncepath(core:volume:name + ":/lib/main.ks").

Require("/lib/record_lift.ks", True).
