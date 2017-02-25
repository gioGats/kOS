// Minmus Lander
// Kevin Gisi
// http://youtube.com/gisikw

function main {
  perform_ascent().
  perform_circularization().
  transfer_to(Minmus).
  perform_powered_descent().
  gather_science().
  perform_ascent().
  perform_circularization().
  transfer_to(Kerbin).
  perform_unpowered_descent().
}

function perform_ascent {
  // REFTODO
}

function perform_circularization {
  // REFTODO
}

function transfer_to {
  parameter body.
  // REFTODO
}

function perform_powered_descent {
  // REFTODO
}

function gather_science {
  // REFTODO
}

function perform_unpowered_descent {
  // REFTODO
}

main().
