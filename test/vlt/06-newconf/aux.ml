let f1 x =
  [%info_log "entering 'f1'"];
  print_endline x;
  [%info_log "leaving 'f1'"]

let f2 n x =
  [%info_log "entering 'f2'"];
  if (n < 0) then [%warn_log "negative n"];
  for i = 1 to n do
    let _ = i in [%trace_log "inside 'f2' loop"];
    f1 x
  done;
  [%info_log "leaving 'f2'"]
