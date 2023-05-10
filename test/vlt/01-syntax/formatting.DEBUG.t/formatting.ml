[%%prepare_logger]

let () =
  [%fatal_log "no parameter"];
  [%info_log "one parameter: %d" 1];
  [%error_log "two parameters: %d %s" 1 "abc"];
  [%debug_log "three parameters: %d %s %f" 1 "abc" 3.];
  [%warn_log "four parameters: %d %s %f %B" 1 "abc" 3. true];
  [%trace_log "five parameters: %d %s %f %B %c" 1 "abc" 3. true 'x'];
  ()

let id x = x

let () =
  [%fatal_log "no parameter"];
  [%info_log "one parameter: %d" (id 1)];
  [%error_log "two parameters: %d %s" 1 (id "abc")];
  [%debug_log "three parameters: %d %s %f" 1 "abc" (id 3.)];
  [%warn_log "four parameters: %d %s %f %B" 1 "abc" 3. (id true)];
  [%trace_log "five parameters: %d %s %f %B %c" 1 "abc" 3. true (id 'x')];
  ()
