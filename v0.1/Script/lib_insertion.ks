NOTIFY("Loading lib_insertion").

FUNCTION MUNAR_INSERTION {
  // Primitive point and burn full throttle maneuvering initially,
  // Ship must be able to face correctly in 5 seconds.
  clearscreen.


  WARPTO(TIME:SECONDS + ETA:TRANSITION).
  WAIT UNTIL SHIP:OBT:BODY:NAME <> "Kerbin".
  print "Munar orbit!".
  print "eccentricity:        " + round(ship:orbit:eccentricity, 2) at (5,5).
  print "delta_angle:     " + round(ship:orbit:inclination, 2) at (5,6).
  local tval is 0.
  lock throttle to tval.

  if ship:orbit:inclination > 10 and ship:periapsis < 100000 {
    print "Extreme inclination correction".
    lock steering to up.
    wait 5.
    until ship:periapsis > 100000 {
      set tval to 1 - max(0.9, ship:periapsis/150000).
      print "tval:     " + round(tval, 2) at (5,7).
    }
    set tval to 0.
  }
  else if ship:orbit:inclination <= 10 {
    if ship:periapsis > 100000 {
      print "High periapsis correction".
      lock steering to -1*up.
      wait 5.
      until ship:periapsis < 100000 {
        set tval to 1 - max(0.9, 25000/ship:periapsis).
        print "tval:     " + round(tval, 2) at (5,7).
      }
      set tval to 0.
    }
    else if ship:periapsis < 10000{
      print "Low periapsis correction".
      lock steering to up.
      wait 5.
      until ship:periapsis > 10000 {
        set tval to 1 - max(0.9, ship:periapsis/15000).
        print "tval:     " + round(tval, 2) at (5,7).
      }
      set tval to 0.
    }
    else {
      set tval to 0.
    }
  }

  // TODO Determine if equatorial crossing or Pe occurs first.

  WARPTO(TIME:SECONDS + ETA:Periapsis - 20).
  lock steering to retrograde.
  until (ship:Apoapsis < 2*ship:periapsis) and (ship:Apoapsis > 0) {
    if ship:Apoapsis < 0 {
      set tval to 1.
    }
    else {
      set tval to 1 - max(0.9, ship:periapsis/ship:Apoapsis).
    }
    set tval to 0.
  }

  // TODO Burn to zero inclination

  // TODO Check if 0 inc around Minmus is -6 or 0 relative to Kerbin

  // TODO Adjust ordering

  if (ship:periapsis < 10000) or (ship:apoapsis < 0) {
    if ship:apoapsis < 0 {
      lock steering to retrograde.
      until ship:apoapsis > 0 {
        set tval to 1.
      }
      set tval to 0.
    }
    if ship:periapsis < 10000 {
      RAISE_PE(10000).
      MNV_EXEC_NODE(TRUE).
    }
  }

  local v0 is CALC(Ship:Apoapsis, Ship:Periapsis, Ship:Apoapsis).
  local v1 is CALC(Ship:Apoapsis, 10000, Ship:Apoapsis).
  local dv is v1-v0.
  add node(time:seconds+eta:apoapsis,0,0,dv).
  MNV_EXEC_NODE(TRUE).

  local v0 is CALC(Ship:Apoapsis, Ship:Periapsis, Ship:Periapsis).
  local v1 is CALC(Ship:Periapsis, 10000, Ship:Periapsis).
  local dv is v1-v0.
  add node(time:seconds+eta:apoapsis,0,0,dv).
  MNV_EXEC_NODE(TRUE).
}

FUNCTION SPOT_LANDING {
  //Check latitude to calc
}
