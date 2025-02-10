let f1 x =
  [%LOG [%INFO] "entering 'f1'"];
  print_endline x;
  [%LOG [%INFO] "leaving 'f1'"]

let f2 n x =
  [%LOG [%INFO] "entering 'f2'"];
  if (n < 0) then [%LOG [%WARN] "negative n"];
  for i = 1 to n do
    let _ = i in [%LOG [%TRACE] "inside 'f2' loop"];
    f1 x
  done;
  [%LOG [%INFO] "leaving 'f2'"]
