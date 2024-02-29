Instrument with vlt.ppx:
  $ dune describe pp simple.ml 2> /dev/null | tail -n 10
  let () = ()
  let main () =
    ();
    if (Array.length Sys.argv) = 0 then ();
    for i = 1 to pred (Array.length Sys.argv) do
      (try (); print_endline (Sys.getenv (Sys.argv.(i))) with | Not_found -> ())
    done;
    ()
  let () =
    (); (try main () with | e -> ((); Printexc.print_backtrace stdout)); ()
