[%%prepare_logger]
[%%capture_path
let main () =
  [%trace_log "entering main"];
  if (Array.length Sys.argv) = 0 then
    [%warn_log "no %s" "argument"];
  for i = 1 to pred (Array.length Sys.argv) do
    try
      [%debug_log "getting variable "];
      print_endline (Sys.getenv Sys.argv.(i))
    with
    | Not_found ->
        [%error_log "undefined variable" [%PROPERTIES ["var", Sys.argv.(i)]]];
  done;
  [%trace_log "leaving main"]
]
let () =
  [%info_log "start ..." [%NAME "App"]];
  (try 
    main ()
  with e ->
    [%fatal_log "uncaught exception" [%EXCEPTION e]];
    Printexc.print_backtrace stdout);
  [%info_log "end ..." [%NAME "App"]]
