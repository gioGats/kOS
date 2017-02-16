NOTIFY("Loading lib_orbit").
FUNCTION LNG_TO_DEGREES {
  PARAMETER lng.

  RETURN MOD(lng + 360, 360).
}

FUNCTION TARGET_ANGLE {
  PARAMETER tgt.

  RETURN MOD(
    LNG_TO_DEGREES(ORBITABLE(tgt):LONGITUDE)
    - LNG_TO_DEGREES(SHIP:LONGITUDE) + 360,
    360
  ).
}

FUNCTION TRANSFER_ANGLE {
  PARAMETER tgt, trans_alt, dest_alt.
  local a0 is (2*Ship:Body:radius + trans_alt + dest_alt)/2.
  local a1 is Target:Orbit:SemiMajorAxis.
  local ratio is 0.5 * sqrt((a0/a1)^3).
  return -1*((360 * ratio) - 180).
}

FUNCTION TRANSFER_NODE {
  PARAMETER tgt.
  sas off.
  set target to ORBITABLE(tgt).
  local Pe is (Ship:Apoapsis + Ship:Periapsis)/2.
  local Ap is (Target:Apoapsis + Target:Periapsis)/2.
  local tgt_ang is TRANSFER_ANGLE(tgt, Pe, Ap).

  local v0 is CALC(Ship:Apoapsis, Ship:Periapsis, Ship:Altitude).
  local v1 is CALC(Ap, Ship:Altitude, Ship:Altitude).
  local dv is v1 - v0.
  local m_t is mnv_time(dv).

  local current_angle is TARGET_ANGLE(tgt).
  wait 1.
  local delta_angle is abs(TARGET_ANGLE(tgt) - current_angle)/1.
  local time_to_burn is abs(tgt_ang - current_angle)/delta_angle.

  until false{
    local current_angle is TARGET_ANGLE(tgt).
    wait 0.5.
    local delta_angle is abs(TARGET_ANGLE(tgt) - current_angle)/0.5.
    local time_to_burn is abs(tgt_ang - current_angle)/delta_angle.
    clearscreen.
    print "mnv_time:        " + round(m_t, 2) at (5,5).
    print "delta_angle:     " + round(delta_angle, 2) at (5,6).
    print "time_to_burn:    " + round(time_to_burn, 2) at (5,7).
    print "target_angle:    " + round(tgt_ang, 2) at (5,8).
    print "current_angle:   " + round(current_angle, 2) at (5,9).
    if time_to_burn < m_t {
      break.
    }
    else if time_to_burn < m_t*2 {
      set warp to 0.
      lock steering to ship:prograde.
    }
    else if time_to_burn < m_t*3 { set warp to 1. wait 1.}
    else if time_to_burn < m_t*4 { set warp to 2. wait 1.}
    else  { set warp to 4. wait 1. }
  }
  set nd to node(time:seconds+m_t,0,0,dv).
  add nd.
}


// Ship's delta v
FUNCTION TLM_DELTAV {
  LIST ENGINES IN shipEngines.
  SET dryMass TO SHIP:MASS - ((SHIP:LIQUIDFUEL + SHIP:OXIDIZER) * 0.005).
  RETURN shipEngines[0]:ISP * 9.81 * LN(SHIP:MASS / dryMass).
}

// Time to impact
FUNCTION TLM_TTI {
  PARAMETER margin.

  LOCAL d IS ALT:RADAR - margin.
  LOCAL v IS -SHIP:VERTICALSPEED.
  LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.

  RETURN (SQRT(v^2 + 2 * g * d) - v) / g.
}

FUNCTION PHASE_ANGLE {
  PARAMETER tgt.

  RETURN MOD(
    LNG_TO_DEGREES(ORBITABLE(tgt):LONGITUDE)
    - LNG_TO_DEGREES(ORBITABLE("Kerbin"):LONGITUDE) + 360,
    360
  ).
}

FUNCTION Ejection_Angle { //Ejection angle, inclination must be negligible.
    parameter pgde.
    if abs(ship:orbit:inclination) > 5 {
        print "Error: Inclination is significant".
        return.
        }
    if pgde { return VANG(Kerbin:Prograde,Ship:UP). }
    else { return 180 - VANG(Kerbin:Prograde,Ship:UP). }
    }

FUNCTION ZERO_INC { //Uses body latitude to zero inclination
    set lat_0 to ship:latitude.
    wait 5.
    set lat_1 to ship:latitude.
    if lat_1 - lat_0 > 0 { lock steering to ship:North *-1. } //Ship is ascending
    else if lat_1 - lat_0 < 0 { lock steering to ship:North. } //Ship is descending
    DECLARE LOCAL mode to 1.
    //This function isn't even close to done.
    //It needs a way of understanding if it is appraching the asc or dsc node, which it cannot yet do.
    //Then it needs to take d_lat and use that to warp to the node.
    //Then it needs to do the darn burn itself, which will have to be simplified to just a normal/anti-normal burn.
    //This could cause havoc on the rest of the orbital parameters,
    //so it should probably take desired pe and ap as input (default to the ship:ap and ship:pe if not provided).
    //That way, it will correct inclination AND maintain the proper orbit.
    //This could get very expensive in dv in LKO, but shouldn't be much of an issue with intented use in leaving Minmus for interplanetary space.
    until mode = 0 {
        if mode = 1 {
            set d_lat to abs((lat_1 - lat_0)/5).
            if abs(ship:latitude) > d_lat*30 { set WARP TO 0.}
            else if abs(ship:latitude) > d_lat*30 { set WARP TO 0.}
            else if abs(ship:latitude) > d_lat*30 { set WARP TO 0.}
            else if abs(ship:latitude) > d_lat*30 { set WARP TO 0.}
        }
    }
}

FUNCTION INC_NODE {
    PARAMETER TGT.
    set Target to Orbitable(TGT).
    set inc to Target:Orbit:Inclination - Ship:Orbit:Inclination.

    set node_time to TIME_ASC_NODE().

    set b to sqrt((constant:G * Kerbin:Mass)/(Ship:Orbit:SemiMajorAxis))*2*sin(inc/2).
    set Bp to -1*b*sin(inc/2).
    if (quadrant = 1) or (quadrant = 2) {set Bn to b*cos(inc/2).}
    else if (quadrant = 3) or (quadrant = 4) {set Bn to -1*b*cos(inc/2).}

    add NODE(node_time, 0, Bn, Bp).
}

FUNCTION TIME_ASC_NODE {
    // Must have already set target
    set vec_n to VCRS(Target:Prograde:Vector, Target:Up:Vector).

    set t_0 to time:seconds.
    set theta_0 to VANG(SHIP:UP:VECTOR,vec_n)-90.
    wait 1.
    set t to time:seconds.
    set theta to VANG(SHIP:UP:VECTOR,vec_n)-90.
    set d_theta to (theta-theta_0)/(t-t_0).

    if theta > 0 {
        if d_theta > 0 {set quadrant to 3.}
        else {set quadrant to 4.}
        }
    else {
        if d_theta > 0 {set quadrant to 2.}
        else {set quadrant to 1.}
        }

    if status = "ORBITING" {
        set period to SHIP:ORBIT:PERIOD.
        set t to (period/360)*arccos(abs(theta)/inc).
        }
    else {
        set period to SHIP:BODY:ROTATIONPERIOD.
        set t to (period/360)*arccos(abs(theta-inc)/ship:latitude).
        }

    set t to (period/360)*arccos(abs(theta)/inc).
    if (quadrant = 2) or (quadrant = 4) {set node_time to time:seconds + ((period/4)-t).}
    else if (quadrant = 1) or (quadrant = 3) {set node_time to time:seconds + ((period/4)+t).}
    return node_time.
}
