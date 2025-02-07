[%%prepare_logger]

let () =
  [%LOG [%FATAL] "no parameter"];
  [%LOG [%INFO] "one parameter: %d" 1];
  [%LOG [%ERROR] "two parameters: %d %s" 1 "abc"];
  [%LOG [%DEBUG] "three parameters: %d %s %f" 1 "abc" 3.];
  [%LOG [%WARN] "four parameters: %d %s %f %B" 1 "abc" 3. true];
  [%LOG [%TRACE] "five parameters: %d %s %f %B %c" 1 "abc" 3. true 'x'];
  ()

let id x = x

let () =
  [%LOG [%FATAL] "no parameter"];
  [%LOG [%INFO] "one parameter: %d" (id 1)];
  [%LOG [%ERROR] "two parameters: %d %s" 1 (id "abc")];
  [%LOG [%DEBUG] "three parameters: %d %s %f" 1 "abc" (id 3.)];
  [%LOG [%WARN] "four parameters: %d %s %f %B" 1 "abc" 3. (id true)];
  [%LOG [%TRACE] "five parameters: %d %s %f %B %c" 1 "abc" 3. true (id 'x')];
  ()
