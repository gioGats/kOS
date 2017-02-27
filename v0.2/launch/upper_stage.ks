//upper_stage.ks
//
function coast {
  // Exit atmosphere commands
  when (ship:Altitude > 50000) then { brakes on. }
  // FUTURE Change to ag10 when action groups available
  // when (ship:Altitude > 50000) then { ag10 on. }

  Raise_pe().

  // FUTURE - Fine tune parking orbit (100km x 100km with reasonable deviation)
  // FUTURE - Warp to deorbit point
  list processors in ps.
  for p in ps {
    if p:connection:isconnected {
      p:connection:sendMessage("deploy").
    }
  }
  stage.

  lock steering to ship:north.
  lock throttle to 0.1.
  wait 1.
  lock steering to ship:retrograde.
  lock throttle to 1.
  wait 20.
  shutdown.

  // FUTURE - Smart deorbit

  // FUTURE - Recovery

}

function raise_pe {
  PARAMETER Pe is ship:apoapsis.
  local v0 is CALC(Ship:Apoapsis,Ship:Periapsis,Ship:Apoapsis).
  local v1 is CALC(Ship:Apoapsis,Pe,Ship:Apoapsis).
  local dv is v1 - v0.
  set nd to node(time:seconds+eta:apoapsis,0,0,dv).
  add nd.
}
