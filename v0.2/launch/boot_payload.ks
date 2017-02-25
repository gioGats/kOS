//boot_payload.ks

if not exists(volume():name + ":/lib/main.ks") {COPYPATH("0:/lib/main.ks", volume():name + ":/lib/main.ks").}
runoncepath(volume():name + ":/lib/main.ks").

local mission_script is "/missions/" + "".   //TODO Add Mission name
Require(mission_script, False).

// TODO Wait for activate message

Require(mission_script, True).
Require("0:/boot/boot_deployed.ks").
core::BOOTFILENAME("1:/boot/boot_deployed.ks").

reboot.
