//boot_payload.ks
set core:volume:name to core:tag.
if not exists(core:volume:name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", core:volume:name + ":/lib/main.ks"). }
runoncepath(core:volume:name + ":/lib/main.ks").

local mission_script is "/missions/" + core:tag.
Require(mission_script, False).
Require("0:/boot/boot_deployed.ks", False).

when (not core:messages:empty) THEN {
  if core:messages:pop():content:tostring = "deploy" {
    Require(mission_script, True).
    Require("0:/boot/boot_deployed.ks", False).
    set core:BOOTFILENAME to "payload:/boot/boot_deployed.ks".
    reboot.
  }
  preserve.
  wait 0.1.
}
