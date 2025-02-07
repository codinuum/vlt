[%%prepare_logger]

class foo = object
  method m0 x =
    let y =
      [%debug_log "x=%d" x];
      x + 1
    in
    y

  initializer
    [%debug_log "init"];
end

module A = struct

  module B = struct

    let f0 x =
      [%debug_log "x=%d" x];
      x + 1

    class bar = object (self)
      method m1 (type s) cmp =
        let module S = Set.Make(struct
          type t = s
          let compare x y =
            [%debug_log "@"];
            cmp x y
        end) in
        (module S : Set.S with type elt = s)

      initializer
        [%debug_log "init"];
        let _ = self#m1 (fun x y -> f0 x + (new foo)#m0 y) in
        ()
    end

  end

end

let main () =
  [%debug_log "@"];
  let _ = new A.B.bar in
  ()

let _ = main()


[%%capture_path
class foo2 = object
  method m0 x =
    let y =
      [%debug_log "x=%d" x];
      x + 1
    in
    y

  initializer
    [%debug_log "init"];
end
]

[%%capture_path
module A2 = struct

  module B = struct

    let f0 x =
      [%debug_log "x=%d" x];
      x + 1

    class bar = object (self)
      method m1 (type s) cmp =
        let module S = Set.Make(struct
          type t = s
          let compare x y =
            [%debug_log "@"];
            cmp x y
        end) in
        (module S : Set.S with type elt = s)

      initializer
        [%debug_log "init"];
        let _ = self#m1 (fun x y -> f0 x + (new foo2)#m0 y) in
        ()
    end

  end

end
]

[%%capture_path
let main () =
  [%debug_log "@"];
  let _ = new A2.B.bar in
  ()
]

let _ = main()
