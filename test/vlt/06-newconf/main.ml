let main () =
  let len = Array.length Sys.argv in
  for i = 1 to pred len do
    Aux_.f2 len Sys.argv.(i)
  done

let () =
  [%info_log "start ..."];
  (try 
    main ()
  with e ->
    [%fatal_log "uncaught exception" [%EXCEPTION e]];
    Printexc.print_backtrace stdout);
  [%info_log "end ..."]
