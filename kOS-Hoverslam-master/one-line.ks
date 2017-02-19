//created by /u/supreme_blorgon (blorgon on KSP forum).

wait until verticalspeed < 0.
lock steering to srfretrograde.
set throt to 0.
lock throttle to throt.
//the '0.635' down there in the throttle function should be bigger the lower your TWR is. 0.635 works for any TWR > 2, so I'm thinking of adding a small function that adjusts that value if your TWR is < 2, but it's not really a priority for me since my propulsive landers always have higher TWRs than that (and I use parachutes when possible).
until (altitude - geoposition:terrainheight) < 2 {
    set throt to min(1,max(0,(((0.635/(1+constant:e^(5-1.5*(altitude-geoposition:terrainheight))))+((altitude-geoposition:terrainheight)/min(-1,(verticalspeed))))+(abs(verticalspeed)/(availablethrust/mass))))).
    wait 0.
}
