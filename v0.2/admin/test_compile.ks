function recursive_compile_files {
  parameter vd.
  for vi in vd:list() {
    if vi:isfile {compile vi:name.}
    else {recursive_compile_files(vi).}}}


for vi in archive:files:values {
  if vi:isfile {compile vi:name.}
  else {recursive_compile_files(vi).}
}
