let () =
  Vlt.Filter.register
    "myfilter"
    (fun e -> (e.Vlt.Event.line mod 2) = 0)

let () =
  Vlt.Layout.register
    "mylayout"
    ([],
     [],
     (fun e ->
       Printf.sprintf "file \"%s\" says \"%s\" with level \"%s\" (line: %d)"
         e.Vlt.Event.file
         e.Vlt.Event.message
         (Vlt.Level.to_string e.Vlt.Event.level)
         e.Vlt.Event.line))
