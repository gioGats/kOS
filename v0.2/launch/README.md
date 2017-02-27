# Launch Scripts: Reusable Series

### Rated Performance
| Vessel Name | Inline Size | Configuration | Payload to LKO (100km x 100km) |
| ----------- | ----------- | ------------- | ------------------------------ |
| ----------- | 2.5m        | Single        | 25t                            |
| ----------- | 2.5m        | Triple        | 50t                            |
| ----------- | 3.75m       | Single        | 75t                            |
| ----------- | 3.75m       | Triple        | 100t                           |



##### Program Sequence
- run all boot scripts:
  - 
- run pre_launch.ks
  - Estimate available UpperStage dv
  - Estimate minimum acceptable boost periapsis
  - Warn if margins are exceeded
- run boost.ks
  - Launch runmode loop:
    - Liftoff
    - Heading update function
    - Pitch update function
    - Staging check function
      - If True, throttle down, stage, and send activate message to Booster CPU(s)
      - Exit loop
    - Print function
    - Log function
- run upper_stage.ks (on UpperStage CPU)
  - Exit atmosphere commands
  - Circularize at Apoapsis
  - Fine tune parking orbit (100km x 100km with reasonable deviation)
  - Warp to deorbit point
  - Deploy payload, and send activate message to Payload CPU
  - Deorbit
  - Recovery

- run booster_recover.ks (on Booster CPU(s))
  - Burn reverse heading until expected landing stops getting closer to target
  - Wait until vertical speed < 0
  - Orient surface retrograde
  - HoverSlam

##### Single Booster CPU Config:
| Vol # | Name          | Boot Script     |
| ----- | ------------- | --------------- |
| 1     | UpperStage    | boot_launch.ks  |
| 2     | Payload       | boot_payload.ks |
| 3     | CenterBooster | boot_booster.ks |

##### Tri Booster CPU Config:
| Vol # | Name          | Boot Script       |
| ----- | ------------- | ----------------- |
| 1     | UpperStage    | boot_launch.ks    |
| 2     | Payload       | boot_payload.ks   |
| 3     | CenterBooster | boot_booster.ks |
| 4     | LeftBooster   | boot_booster.ks |
| 5     | RightBooster  | boot_booster.ks |
