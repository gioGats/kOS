NOTIFY("Loading lib_comms").

FUNCTION ACTIVATE_COMMS {
  until ADDONS:RT:HASCONNECTION(SHIP) {
      for name in LIST("RTShortAntenna1", "longAntenna", "RTLongAntenna3", "RTLongAntenna2") {
        ACTIVATE_OMNI("", name).
        wait 1.  //REFTODO Confirm loop exits correctly
        DEACTIVATE("", name).
      }
      for name in LIST("mediumDishAntenna", "RTShortDish2", "commDish", "RTLongDish2", "RTGigaDish2", "RTGigaDish1") {
        ACTIVATE_DISH("", name).
        wait 1.  //REFTODO Confirm loop exits correctly
        DEACTIVATE("", name).
      }
  }
}

FUNCTION ACTIVATE_OMNI {
  PARAMETER tag is "".
  PARAMETER name is "".
  IF tag != "" {
    local guesses is ship:partstagged(tag).
    if guesses:length > 0 {
      local ant is guesses[0].
      local antM is ant:getModule("ModuleRTAntenna").
      antM:DOEVENT("activate").
    }
  }
  ELSE IF name != "" {
    local guesses is ship:partsnamed(name).
    if guesses:length > 0 {
      local ant is guesses[0].
      local antM is ant:getModule("ModuleRTAntenna").
      antM:DOEVENT("activate").
    }
  }
  ELSE {
    local errorString is "No omni antenna matches tag/name " + name + tag.
    print errorString.
  }
}

FUNCTION ACTIVATE_DISH {
  PARAMETER tag is "".
  PARAMETER tgt is "".
  PARAMETER name is "".
  IF tgt = "" {
    local tgtList is LIST("Kerbin", "KSC", "Atlas-2-1", "Atlas-2-2"). //REFTODO Verify correct ship names
  }
  ELSE {
    local tgtList is LIST(tgt).
  }

  IF tag != "" {
    local guesses is ship:partstagged(tag).
    if guesses:length > 0 {
      local ant is guesses[0].
      local antM is ant:getModule("ModuleRTAntenna").
      antM:DOEVENT("activate").
      for t in tgtList {
        m:SETFIELD("target", tgt).
        if ADDONS:RT:HASCONNECTION(SHIP) {
          break.
        }
      }
    }
  }
  ELSE IF name != "" {
    local guesses is ship:partsnamed(name).
    if guesses:length > 0 {
      local ant is guesses[0].
      local antM is ant:getModule("ModuleRTAntenna").
      antM:DOEVENT("activate").
      for t in tgtList {
        m:SETFIELD("target", tgt).
        if ADDONS:RT:HASCONNECTION(SHIP) {
          break.
        }
      }
    }
  }
  ELSE {
    local errorString is "No dish antenna matches tag/name " + name + tag.
    print errorString.
  }
}

FUNCTION DEACTIVATE {
  PARAMETER tag is "".
  PARAMETER name is "".
  IF tag != "" {
    local guesses is ship:partstagged(tag).
    if guesses:length > 0 {
      set ant to guesses[0].
      set antM to ant:getModule("ModuleRTAntenna").
      antM:DOEVENT("deactivate").  //REFTODO Confirm proper module command
    }
  }
  ELSE IF name != "" {
    local guesses is ship:partsnamed(name).
    if guesses:length > 0 {
      local ant is guesses[0].
      local antM is ant:getModule("ModuleRTAntenna").
      antM:DOEVENT("deactivate").  //REFTODO Confirm proper module command
    }
  }
  ELSE {
    local errorString is "No dish/omni antenna matches tag/name " + name + tag.
    print errorString.
  }
}
