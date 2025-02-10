let main () =
  let len = Array.length Sys.argv in
  for i = 1 to pred len do
    Aux_.f2 len Sys.argv.(i)
  done

let () =
  [%LOG [%INFO] "start ..."];
  (try 
    main ()
  with e ->
    [%LOG [%FATAL] "uncaught exception" [%EXCEPTION e]];
    Printexc.print_backtrace stdout);
  [%LOG [%INFO] "end ..."]
