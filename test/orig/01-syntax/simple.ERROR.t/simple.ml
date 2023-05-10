[%%prepare_logger]
[%%capture_path
let main () =
  [%LOG [%TRACE] "entering main"];
  if (Array.length Sys.argv) = 0 then
    [%LOG [%WARN] "no %s" "argument"];
  for i = 1 to pred (Array.length Sys.argv) do
    try
      [%LOG [%DEBUG] "getting variable "];
      print_endline (Sys.getenv Sys.argv.(i))
    with
    | Not_found ->
        [%LOG [%ERROR] "undefined variable" [%PROPERTIES ["var", Sys.argv.(i)]]];
  done;
  [%LOG [%TRACE] "leaving main"]
]
let () =
  [%LOG [%INFO] "start ..." [%NAME "App"]];
  (try 
    main ()
  with e ->
    [%LOG [%FATAL] "uncaught exception" [%EXCEPTION e]];
    Printexc.print_backtrace stdout);
  [%LOG [%INFO] "end ..." [%NAME "App"]]
