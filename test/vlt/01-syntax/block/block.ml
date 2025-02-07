[%%prepare_logger]

let () =
  begin %info_block
    Printf.printf "FOO\n";
    [%info_log "BAR"];
    [%debug_log "BAZ"];
  end

let () =
  begin %debug_block
    [%LOG [%WARN] "FOO"]
  end

let () =
  begin %info_block
  end
