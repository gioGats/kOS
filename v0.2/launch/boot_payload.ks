//boot_payload.ks

if not exists(volume():name + ":/lib/main.ks") {COPYPATH("0:/lib/main.ks", volume():name + ":/lib/main.ks").}
runoncepath(volume():name + ":/lib/main.ks").

local mission_script is "/missions/" + core:tag.
Require(mission_script, False).

when (not core:messages:empty) THEN {
  if core:messages:pop():content:tostring = "deploy" {
    Require(mission_script, True).
    Require("0:/boot/boot_deployed.ks").
    core::BOOTFILENAME("1:/boot/boot_deployed.ks").
  }
  preserve.
}

reboot.
