Instrument with vlt.ppx:
  $ dune describe pp simple.ml 2> /dev/null
  [@@@ocaml.ppx.context
    {
      tool_name = "ppx_driver";
      include_dirs = [];
      load_path = [];
      open_modules = [];
      for_package = None;
      debug = false;
      use_threads = false;
      use_vmthreads = false;
      recursive_types = false;
      principal = false;
      transparent_modules = false;
      unboxed_types = false;
      unsafe_string = false;
      cookies = []
    }]
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
