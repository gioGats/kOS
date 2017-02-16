@LAZYGLOBAL off.
NOTIFY("Loading lib_pid").
function PID_init {
  parameter Kp, Ki, Kd, cMin, cMax.

  local SeekP is 0.
  local P is 0.
  local I is 0.
  local D is 0.
  local oldT is -1.
  local oldInput is 0.

  local P_a is list(Kp, Ki, Kd, cMin, cMax, SeekP, P, I, D, oldT, oldInput).

  return P_a.
}.

function PID_seek {
  parameter P_a, seekVal, curVal.

  local Kp   is P_a[0].
  local Ki   is P_a[1].
  local Kd   is P_a[2].
  local cMin is P_a[3].
  local cMax is P_a[4].
  local oldS   is P_a[5].
  local oldP   is P_a[6].
  local oldI   is P_a[7].
  local oldD   is P_a[8].
  local oldT   is P_a[9].
  local oldInput is P_a[10].

  local P is seekVal - curVal.
  local D is oldD.
  local I is oldI.
  local newInput is oldInput.

  local t is time:seconds.
  local dT is t - oldT.

  if oldT < 0 {

  } else {
    if dT > 0 {
     set D to (P - oldP)/dT.
     local onlyPD is Kp*P + Kd*D.
     if (oldI > 0 or onlyPD > cMin) and (oldI < 0 or onlyPD < cMax) {
      set I to oldI + P*dT.
     }.
     set newInput to onlyPD + Ki*I.
    }.
  }.

  set newInput to max(cMin,min(cMax,newInput)).

  set P_a[5] to seekVal.
  set P_a[6] to P.
  set P_a[7] to I.
  set P_a[8] to D.
  set P_a[9] to t.
  set P_a[10] to newInput.

  return newInput.
}.
