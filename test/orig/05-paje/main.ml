module Definitions = struct
  let logger = ""
  let level = Vlt.Level.TRACE

  type container_type = [ `Program ]
  let container_types = [ `Program, "Program", None, "P" ]

  type event_type = [ `Start | `End ]
  let event_types = [ `Start, "Start", `Program, "S" ;
                      `End, "End", `Program, "E" ]

  type state_type = [ `Running ]
  let state_types = [ `Running, "Running", `Program, "R" ]

  type variable_type = unit
  let variable_types = []

  type link_type = [ `Message ]
  let link_types = [ `Message, "Message", `Program, `Program, `Program, "M" ]

  type entity_value_type = unit
  let entity_value_types = [ (), "", `Program, (1.0, 1.0, 1.0), "" ]
end

module MyPaje = Vlt.Paje.Make (Definitions)

let sender ch =
  for i = 0 to 9 do
    Thread.delay (0.1 +. (Random.float 0.2));
    [%LOG [%TRACE] MyPaje.t
      [%WITH MyPaje.start_link
         ~typ:`Message ~container:"main" ~start_container:"sender"
         ~value:(string_of_int i) ~key:"i" []]];
    Event.sync (Event.send ch i);
  done;
  Thread.delay (0.1 +. (Random.float 0.2));
  [%LOG [%TRACE] MyPaje.t
    [%WITH MyPaje.start_link ~typ:`Message ~container:"main" ~start_container:"sender"
       ~value:"99" ~key:"i" []]];
  Event.sync (Event.send ch 99)

let receiver ch =
  let last = ref 0 in
  while !last <> 99 do
    let e = Event.receive ch in
    last := Event.sync e;
    [%LOG [%TRACE] MyPaje.t
      [%WITH MyPaje.end_link ~typ:`Message ~container:"main" ~end_container:"receiver"
         ~value:(string_of_int !last) ~key:"i" []]];
    print_int !last;
    print_newline ()
  done

let _ =
  [%LOG [%TRACE] MyPaje.t
    [%WITH MyPaje.create_container ~name:"main" ~typ:`Program []]];

  [%LOG [%TRACE] MyPaje.t
    [%WITH MyPaje.create_container ~name:"sender" ~typ:`Program ~container:"main" []]];

  [%LOG [%TRACE] MyPaje.t
    [%WITH MyPaje.create_container ~name:"receiver" ~typ:`Program ~container:"main" []]];

  [%LOG [%TRACE] MyPaje.t
    [%WITH MyPaje.new_event ~typ:`Start ~container:"main" ~value:"" []]];

  Random.self_init ();
  let ch = Event.new_channel () in
  let s = Thread.create sender ch in
  let r = Thread.create receiver ch in
  Thread.join s;
  Thread.join r;
  [%LOG [%TRACE] MyPaje.t
    [%WITH MyPaje.new_event ~typ:`End ~container:"main" ~value:"" []]]
