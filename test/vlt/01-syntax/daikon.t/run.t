Instrument with vlt.ppx:
  $ dune describe pp daikon.ml 2> /dev/null | tail -n 25
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
