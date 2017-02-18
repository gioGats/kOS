//pre_launch.ks

// Establish global variables
local terminal_velocity is ship:TERMVELOCITY.
// TODO Check to see how terminal_velocity compares to individual boosters vs. the fully fueled vessel.
// FUTURE Dynamically generate this value.
set required_landing_dv to 1.5 * terminal_velocity.

local total_upper_dv is 1000.  //TODO Determine this dynamically.
local deorbit_dv is ORBITAL_VELOCITY(100000,100000,100000) - ORBITAL_VELOCITY(100000,0,100000).
local fine_tuning_dv is 100.
set available_upper_dv to (total_upper_dv - required_landing_dv - deorbit_dv - fine_tuning_dv).

local u is constant:G * Kerbin:Mass.  // TODO May need to update for kOS 1.0+
local radius is 700000.
set min_boost_pe to (2/((2/radius)-(((sqrt(u/radius)-available_upper_dv)^2)/u))) - 1300000.

// Hard-Coded for KS-25 Vector engine.
set landing_isp to 295.
// FUTURE Dynamically generate this value.

//TODO - Warn if margins are exceeded

Notify("Pre-Launch calculations complete").
