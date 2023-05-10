[%%prepare_logger]

class foo = object
  method m0 x =
    let y =
      [%debug_log "x=%d" x];
      x + 1
    in
    y
end

module A = struct

  module B = struct

    let f0 x =
      [%debug_log "x=%d" x];
      x + 1

    class bar = object
      method m1 (type s) cmp =
        let module S = Set.Make(struct
          type t = s
          let compare x y =
            [%debug_log "@"];
            cmp x y
        end) in
        (module S : Set.S with type elt = s)
    end

  end

end

let main () =
  [%debug_log "@"]

[%%capture_path
class foo = object
  method m0 x =
    let y =
      [%debug_log "x=%d" x];
      x + 1
    in
    y
end
]

[%%capture_path
module A = struct

  module B = struct

    let f0 x =
      [%debug_log "x=%d" x];
      x + 1

    class bar = object
      method m1 (type s) cmp =
        let module S = Set.Make(struct
          type t = s
          let compare x y =
            [%debug_log "@"];
            cmp x y
        end) in
        (module S : Set.S with type elt = s)
    end

  end

end
]

[%%capture_path
let main () =
  [%debug_log "@"]
]
