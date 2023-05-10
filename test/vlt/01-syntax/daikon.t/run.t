Instrument with vlt.ppx:
  $ dune describe pp --instrument-with vlt.ppx daikon.ml
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
  type r = {
    x: int ;
    y: float }
  let r =
    let open Vlt.Daikon in
      make_variable_builder (fun r -> [int "x" r.x; float "y" r.y])
  let make_r k = { x = (k * k); y = (float (k - 2)) }
  type c = (bool * string)
  let c = let open Vlt.Daikon in tuple2 bool string
  let make_c k = (true, (String.make k '*'))
  let f x =
    Vlt.Logger.log "Daikon.f" Vlt.Level.TRACE ~file:"daikon.ml" ~line:18
      ~column:2
      ~properties:(let open Vlt in Daikon.enter "f" [Daikon.int "x" x])
      ~error:None (let open Vlt in Daikon.t);
    (let rr = make_r x in
     let cc = make_c x in
     let res = (x * x) mod 2 in
     Vlt.Logger.log "Daikon.f" Vlt.Level.TRACE ~file:"daikon.ml" ~line:23
       ~column:2
       ~properties:(let open Vlt in
                      Daikon.exit "f" (Daikon.int "res" res)
                        [Daikon.int "x" x; r "rr" rr; c "cc" cc]) ~error:None
       (let open Vlt in Daikon.t))
  let () = let l = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10] in List.iter f l
