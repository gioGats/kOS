function recursive_compile_files {
  parameter directory.
  for volumeitem in directory:files {
    if volumeitem:isfile {compile volumeitem.}
    else {recursive_compile_files(volumeitem).}}}

recursive_compile_files(archive).
