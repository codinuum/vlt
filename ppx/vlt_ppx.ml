(*
 * This file is part of Vlt.
 * Copyright (C) 2023 Codinuum.
 *
 * Vlt is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Vlt is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)


open Ppxlib


module Args = struct
  let level = ref 5
  let logger = ref ""
  let for_pack = ref ""
end

let get_logger_name code_path =
  if !Args.logger <> "" then
    !Args.logger
  else if !Args.for_pack <> "" then
    !Args.for_pack ^ "." ^ code_path
  else
    code_path

module Name = struct
  let expand ~ctxt s =
    let loc = Expansion_context.Extension.extension_point_loc ctxt in
    Ast_builder.Default.estring ~loc s

  let extract () = Ast_pattern.(single_expr_payload @@ (estring __))

  let extension = Extension.(V3.declare "NAME" Context.expression (extract()) expand)
end

module Properties = struct
  let expand ~ctxt expr =
    let loc = Expansion_context.Extension.extension_point_loc ctxt in
    [%expr let open Vlt in [%e expr]]

  let extract () = Ast_pattern.(single_expr_payload __)

  let extension = Extension.(V3.declare "PROPERTIES" Context.expression (extract()) expand)
  let extension_alt = Extension.(V3.declare "WITH" Context.expression (extract()) expand)
end

module Exception = struct
  let expand ~ctxt e =
    let _ = ctxt in
    e

  let extract () = Ast_pattern.(single_expr_payload __)

  let extension = Extension.(V3.declare "EXCEPTION" Context.expression (extract()) expand)
  let extension_alt = Extension.(V3.declare "EXN" Context.expression (extract()) expand)
end


let split_args =
  List.partition
    (fun e ->
      match e.pexp_desc with
      | Pexp_extension(loc, _) -> begin
          match loc.txt with
          | "NAME"
          | "PROPERTIES" | "WITH"
          | "EXCEPTION" | "EXN" -> true
          | _ -> false
      end
      | _ -> false
    )

let make_attr_tbl =
  List.map
    (fun e ->
      match e.pexp_desc with
      | Pexp_extension(loc, _) -> begin
          match loc.txt with
          | "NAME" -> ("cpath", e)
          | "PROPERTIES" | "WITH" -> ("props", e)
          | "EXCEPTION" | "EXN" -> ("exc", e)
          | _ -> assert false
      end
      | _ -> assert false
    )

let arg_to_string = function { txt = lid; _ } -> String.concat "." (Astlib.Longident.flatten lid)

let conv_path loc p =
  let prefix = loc.loc_start.pos_fname in
  if String.starts_with ~prefix p then
    let len = String.length prefix in
    let suffix = String.sub p len ((String.length p) - len) in
    let prefix_ =
      try
        Filename.(String.capitalize_ascii (chop_suffix (basename prefix) ".ml"))
      with
        _ -> prefix
    in
    prefix_ ^ suffix
  else
    p

let get_attrs loc path arg_opt al =
  let logger_name =
    get_logger_name
      (match arg_opt with
      | Some a -> arg_to_string a
      | None -> conv_path loc path)
  in
  let logger = Ast_builder.Default.estring ~loc logger_name in

  let pos = loc.loc_start in
  let file_name = Ast_builder.Default.estring ~loc pos.pos_fname in
  let line_num = Ast_builder.Default.eint ~loc pos.pos_lnum in
  let col_num = Ast_builder.Default.eint ~loc (pos.pos_cnum - pos.pos_bol) in

  let attr_tbl = make_attr_tbl al in
  let logger =
    match List.assoc_opt "cpath" attr_tbl with
    | Some x -> x
    | None -> logger
  in
  let props =
    match List.assoc_opt "props" attr_tbl with
    | Some x -> x
    | None -> [%expr []]
  in
  let exc_opt =
    match List.assoc_opt "exc" attr_tbl with
    | Some x -> [%expr Some [%e x]]
    | None -> [%expr None]
  in
  logger, file_name, line_num, col_num, props, exc_opt

module Level = struct
  exception Invalid_level of Location.t * string

  let fatal loc = [%expr Vlt.Level.FATAL]
  let error loc = [%expr Vlt.Level.ERROR]
  let warn loc = [%expr Vlt.Level.WARN]
  let info loc = [%expr Vlt.Level.INFO]
  let debug loc = [%expr Vlt.Level.DEBUG]
  let trace loc = [%expr Vlt.Level.TRACE]

  let to_string lv =
    match lv.pexp_desc with
    | Pexp_construct({ txt = Ldot(_, name); _ }, _) -> name
    | Pexp_extension({ txt = name; _ }, _) -> name
    | _ ->
        let loc = lv.pexp_loc in
        let s = Pprintast.string_of_expression lv in
        let mes = Printf.sprintf "invalid log level expression: %s" s in
        raise (Invalid_level(loc, mes))

  let _to_int ?(loc=Location.none) = function
    | "NONE" -> -1
    | "FATAL" -> 0
    | "ERROR" -> 1
    | "WARN" -> 2
    | "INFO" -> 3
    | "DEBUG" -> 4
    | "TRACE" -> 5
    | s -> (*Int.max_int*)
        let mes = Printf.sprintf "invalid log level: %s" s in
        raise (Invalid_level(loc, mes))

  let to_int lv = _to_int ~loc:lv.pexp_loc (to_string lv)

  let expand level ~ctxt =
    let loc = Expansion_context.Extension.extension_point_loc ctxt in
    level loc

  let extract () = Ast_pattern.(drop)

  module Extension = struct
    let make name body = Extension.(V3.declare name Context.expression (extract()) (expand body))
    let fatal = make "FATAL" fatal
    let error = make "ERROR" error
    let warn = make "WARN" warn
    let info = make "INFO" info
    let debug = make "DEBUG" debug
    let trace = make "TRACE" trace
  end

  module Log = struct
    let not_fmt el =
      match el with
      | [e] -> begin
          match e.pexp_desc with
          | Pexp_constant (Pconst_string _) -> false
          | _ -> true
      end
      | _ -> false

    let expand ?(guard=true) level ~loc ~path ~arg expr _el =
      try
        let lv = level loc in
        let lvi = to_int lv in
        if lvi > !Args.level then
          [%expr ()]
        else
          let al, el = split_args _el in
          let el_ = expr::el in
          let logger, file_name, line_num, col_num, props, exc_opt = get_attrs loc path arg al in
          let body =
            if not_fmt el_ then
              Ast_builder.Default.eapply ~loc
                [%expr
                   Vlt.Logger.log [%e logger] [%e lv]
                   ~file:[%e file_name] ~line:[%e line_num] ~column:[%e col_num]
                   ~properties:[%e props] ~error:[%e exc_opt]
                ] [[%expr let open Vlt in [%e expr]]]
            else
              Ast_builder.Default.eapply ~loc
                [%expr
                   Vlt.Logger.logf [%e logger] [%e lv]
                   ~file:[%e file_name] ~line:[%e line_num] ~column:[%e col_num]
                   ~properties:[%e props] ~error:[%e exc_opt]
                ] el_
          in
          if guard then
            match lv.pexp_desc with
            | Pexp_construct({ txt = Ldot(_, "TRACE"); _ }, _) -> body
            | _ ->
                [%expr
                 if Vlt.Logger.check_level [%e logger] [%e lv] then
                   [%e body]
                 else ()
                ]
          else
            body
      with
        e ->
          Ast_builder.Default.pexp_extension ~loc @@
          Location.error_extensionf ~loc "%s" (Printexc.to_string e)

    let extract () =
      Ast_pattern.(
      alt
        (single_expr_payload @@ pexp_apply __ (many (no_label __)))
        (map_result ~f:(fun x -> x []) (single_expr_payload __))
     )
    
    module Extension = struct
      let make guard name level =
        Ppxlib.Extension.(declare_with_path_arg
                            name Context.expression (extract()) (expand ~guard level))

      let tbl = [ (*name, guard, level*)
        "_fatal_log", false, fatal;
        "_error_log", false, error;
        "_warn_log", false, warn;
        "_info_log", false, info;
        "_debug_log", false, debug;
        "_trace_log", false, trace;

        "fatal_log", true, fatal;
        "error_log", true, error;
        "warn_log", true, warn;
        "info_log", true, info;
        "debug_log", true, debug;
        "trace_log", true, trace;
      ]

      let is_ext_name =
        let nl = List.map (fun (n, _, _) -> n) tbl in
        let t = Hashtbl.create (List.length nl) in
        List.iter (fun n -> Hashtbl.add t n true) nl;
        fun x -> try Hashtbl.find t x with Not_found -> false

      let extensions = List.map (fun (name, guard, level) -> make guard name level) tbl

    end

  end (* module Level.Log *)

  module Block = struct
    exception To_be_modified

    let modify_expr lvi expr =
      let checker = object
        inherit Ast_traverse.iter as super
        method! extension ext =
          match ext with
          | { txt = lvn; loc }, _ when (_to_int ~loc lvn) <= lvi -> raise To_be_modified
          | _ -> super#extension ext
      end
      in
      let name_to_int = function
        | "fatal_log" | "fatal_block" -> 0
        | "error_log" | "error_block" -> 1
        | "warn_log" | "warn_block" -> 2
        | "info_log" | "info_block" -> 3
        | "debug_log" | "debug_block" -> 4
        | "trace_log" | "trace_block" -> 5
        | _ -> Int.max_int
      in
      let modifier = object
        inherit Ast_traverse.map
        method! extension ext =
          match ext with
          | { txt = "LOG"; loc }, p -> begin
              try
                let _ = checker#payload p in
                ext
              with
                To_be_modified -> { txt = "_LOG"; loc }, p
          end
          | { txt = name; loc }, p when (name_to_int name) <= lvi -> { txt = "_"^name; loc }, p
          | _ -> ext
      end
      in
      modifier#expression expr

    let expand ?(guard=true) level ~loc ~path ~arg expr_opt expr =
      try
        let lv = level loc in
        let lvi = to_int lv in
        if lvi > !Args.level then
          [%expr ()]
        else
          let expr = modify_expr lvi expr in
          let logger_name =
            get_logger_name
              (match arg with
              | Some a -> arg_to_string a
              | None -> conv_path loc path)
          in
          let logger = Ast_builder.Default.estring ~loc logger_name in
          let is_null e =
            match e.pexp_desc with
            | Pexp_construct({ txt = Lident "()"; _ }, None) -> true
            | _ -> false
          in
          let body =
            match expr_opt with
            | Some e -> [%expr [%e e]; [%e expr]]
            | None -> expr
          in
          if is_null body || not guard then
            body
          else
            match lv.pexp_desc with
            | Pexp_construct({ txt = Ldot(_, "TRACE"); _ }, _) -> body
            | _ ->
                [%expr
                 if Vlt.Logger.check_level [%e logger] [%e lv] then
                   [%e body]
                 else ()
                ]
      with
        e ->
          Ast_builder.Default.pexp_extension ~loc @@
          Location.error_extensionf ~loc "%s" (Printexc.to_string e)

    let extract () =
      Ast_pattern.(
      alt_option
        (single_expr_payload @@ pexp_sequence __ __)
        (single_expr_payload __)
     )
    
    module Extension = struct
      let make guard name level =
        Ppxlib.Extension.(declare_with_path_arg
                            name Context.expression (extract()) (expand ~guard level))

      let tbl = [ (*name, guard, level*)
        "_fatal_block", false, fatal;
        "_error_block", false, error;
        "_warn_block", false, warn;
        "_info_block", false, info;
        "_debug_block", false, debug;
        "_trace_block", false, trace;

        "fatal_block", true, fatal;
        "error_block", true, error;
        "warn_block", true, warn;
        "info_block", true, info;
        "debug_block", true, debug;
        "trace_block", true, trace;
      ]

      let is_ext_name =
        let nl = List.map (fun (n, _, _) -> n) tbl in
        let t = Hashtbl.create (List.length nl) in
        List.iter (fun n -> Hashtbl.add t n true) nl;
        fun x -> try Hashtbl.find t x with Not_found -> false

      let extensions = List.map (fun (name, guard, level) -> make guard name level) tbl

    end

  end (* module Level.Block *)

end (* module Level *)

module Log = struct
  let sprintf_expr_list loc el =
    match el with
    | [e] -> begin
        match e.pexp_desc with
        | Pexp_constant (Pconst_string _) -> e
        | _ -> [%expr let open Vlt in [%e e]]
    end
    | _ -> Ast_builder.Default.eapply ~loc [%expr Printf.sprintf] el

  let expand ?(guard=true) ~loc ~path ~arg lv _el =
    try
      let lvi = Level.to_int lv in
      if lvi > !Args.level then
        [%expr ()]
      else
        let al, el = split_args _el in
        let mes = sprintf_expr_list loc el in
        let logger, file_name, line_num, col_num, props, exc_opt = get_attrs loc path arg al in
        let body =
          [%expr
             Vlt.Logger.log [%e logger] [%e lv]
             ~file:[%e file_name] ~line:[%e line_num] ~column:[%e col_num]
             ~properties:[%e props] ~error:[%e exc_opt]
             [%e mes]
          ]
        in
        if guard then
          match lv.pexp_desc with
          | Pexp_extension(a, _) when String.equal a.txt "TRACE" -> body
          | _ ->
              [%expr
               if Vlt.Logger.check_level [%e logger] [%e lv] then
                 [%e body]
               else ()
             ]
        else
          body
    with
    | Level.Invalid_level(loc, mes) ->
        Ast_builder.Default.pexp_extension ~loc @@
        Location.error_extensionf ~loc "%s" mes
    | e ->
        Ast_builder.Default.pexp_extension ~loc @@
        Location.error_extensionf ~loc "%s" (Printexc.to_string e)

  let extract () =
    Ast_pattern.(
    single_expr_payload @@ pexp_apply __ (many (no_label __))
   )

  let extension, _extension =
    let f guard name =
      Extension.(declare_with_path_arg name Context.expression (extract()) (expand ~guard))
    in
    f true "LOG", f false "_LOG"

end (* module Log *)

module Prepare = struct
  let expand ~ctxt =
    let loc = Expansion_context.Extension.extension_point_loc ctxt in
    if !Args.level >= 0 then
      let cp = Expansion_context.Extension.code_path ctxt in
      let logger_name = get_logger_name (Code_path.fully_qualified_path cp) in
      let logger = Ast_builder.Default.estring ~loc logger_name in
      [%stri let () = Vlt.Logger.prepare [%e logger]]
    else
      [%stri let () = ()]

  let extract () = Ast_pattern.(drop)

  let extension =
    Extension.(V3.declare "prepare_logger" Context.structure_item (extract()) expand)
end

module StructureItem = struct
  let expand ~ctxt si =

    let cp = Expansion_context.Extension.code_path ctxt in
    let logger_name = get_logger_name (Code_path.fully_qualified_path cp) in

    let mapper = object (self)
      inherit [string list] Ast_traverse.map_with_context

      method! value_binding ctxt vb =
        match vb.pvb_pat.ppat_desc with
        | Ppat_var { txt = vname; _ } ->
            { vb with pvb_expr = self#expression (("."^vname)::ctxt) vb.pvb_expr }
        | _ -> { vb with pvb_expr = self#expression ctxt vb.pvb_expr }

      (*method! structure_item_desc ctxt idesc =
        match idesc with
        | Pstr_eval(e, a) -> Pstr_eval (self#expression ctxt e, a)
        | Pstr_value(r, vbl) -> Pstr_value(r, List.map (self#map_value_bind ctxt) vbl)
        | Pstr_module mb -> Pstr_module (self#module_binding ctxt mb)
        | Pstr_recmodule mbl -> Pstr_recmodule (List.map (self#module_binding ctxt) mbl)
        | Pstr_class cdl -> Pstr_class (List.map (self#class_declaration ctxt) cdl)
        | Pstr_include inc ->
            Pstr_include { inc with pincl_mod = self#module_expr ctxt inc.pincl_mod }
        | _ -> idesc*)

      method! module_binding ctxt mbind =
        match mbind with
        | { pmb_name = { txt = Some mname; _}; _ } -> begin
            let ctxt = ("."^mname) :: ctxt in
            { mbind with pmb_expr = self#module_expr ctxt mbind.pmb_expr }
        end
        | _ -> { mbind with pmb_expr = self#module_expr ctxt mbind.pmb_expr }

      method! class_declaration ctxt cdecl =
        match cdecl with
        | { pci_name = { txt = cname; _}; _ } -> begin
            let ctxt = ("."^cname) :: ctxt in
            { cdecl with pci_expr = self#class_expr ctxt cdecl.pci_expr }
        end

      method! class_field_desc ctxt cfield_desc =
        match cfield_desc with
        | Pcf_method({ txt = mname; loc }, priv, Cfk_concrete(ovrd, expr)) -> begin
            let ctxt = ("#"^mname) :: ctxt in
            Pcf_method({ txt = mname; loc }, priv, Cfk_concrete(ovrd, self#expression ctxt expr))
        end
        | Pcf_initializer expr -> begin
            let ctxt = "#<init>" :: ctxt in
            Pcf_initializer (self#expression ctxt expr)
        end
        | _ -> cfield_desc

      method! expression_desc ctxt expr_desc =
        let map_expr = self#expression ctxt in
        let map_expr_opt = function
          | Some e -> Some (map_expr e)
          | None -> None
        in
        match expr_desc with
        | Pexp_letmodule({ txt = mname_opt; _} as m, me, e) -> begin
            let ctxt =
              match mname_opt with
              | Some mname -> ("."^mname) :: ctxt
              | None -> ctxt
            in
            Pexp_letmodule(m, self#module_expr ctxt me, map_expr e)
        end
        | Pexp_let(r, vbl, e) -> Pexp_let(r, List.map (self#value_binding ctxt) vbl, map_expr e)
        | Pexp_function c -> Pexp_function (self#cases ctxt c)
        | Pexp_fun(a, e_opt, p, e) -> Pexp_fun(a, map_expr_opt e_opt, p, map_expr e)
        | Pexp_apply(e, al) -> Pexp_apply(map_expr e, List.map (fun(l, e) -> l, map_expr e) al)
        | Pexp_match(e, c) -> Pexp_match(map_expr e, self#cases ctxt c)
        | Pexp_try(e, c) -> Pexp_try(map_expr e, self#cases ctxt c)
        | Pexp_tuple el -> Pexp_tuple (List.map map_expr el)
        | Pexp_construct(c, Some e) -> Pexp_construct(c, Some (map_expr e))
        | Pexp_variant(l, Some e) -> Pexp_variant(l, Some (map_expr e))
        | Pexp_record(rl, e_opt) ->
            Pexp_record(List.map (fun (l, e) -> l, map_expr e) rl, map_expr_opt e_opt)
        | Pexp_field(e, l) -> Pexp_field(map_expr e, l)
        | Pexp_setfield(e0, l, e1) -> Pexp_setfield(map_expr e0, l, map_expr e1)
        | Pexp_array el -> Pexp_array (List.map map_expr el)
        | Pexp_ifthenelse(e0, e1, e2_opt) ->
            Pexp_ifthenelse(map_expr e0, map_expr e1, map_expr_opt e2_opt)
        | Pexp_sequence(e0, e1) -> Pexp_sequence(map_expr e0, map_expr e1)
        | Pexp_while(e0, e1) -> Pexp_while(map_expr e0, map_expr e1)
        | Pexp_for(p, e0, e1, d, e2) -> Pexp_for(p, map_expr e0, map_expr e1, d, map_expr e2)
        | Pexp_constraint(e, t) -> Pexp_constraint(map_expr e, t)
        | Pexp_coerce(e, t_opt, t) -> Pexp_coerce(map_expr e, t_opt, t)
        | Pexp_send(e, l) -> Pexp_send(map_expr e, l)
        | Pexp_setinstvar(l, e) -> Pexp_setinstvar(l, map_expr e)
        | Pexp_override lel -> Pexp_override (List.map (fun (l, e) -> l, map_expr e) lel)
        | Pexp_letexception(c, e) -> Pexp_letexception(c, map_expr e)
        | Pexp_assert e -> Pexp_assert (map_expr e)
        | Pexp_lazy e -> Pexp_lazy (map_expr e)
        | Pexp_poly(e, t) -> Pexp_poly(map_expr e, t)
        | Pexp_object cs -> Pexp_object (self#class_structure ctxt cs)
        | Pexp_newtype(l, e) -> Pexp_newtype(l, map_expr e)
        | Pexp_open(o, e) -> Pexp_open(o, map_expr e)
        | Pexp_letop l -> begin
            let map_bop bop =
              match bop.pbop_pat.ppat_desc with
              | Ppat_var { txt = vname; _ } ->
                  { bop with pbop_exp = self#expression (("."^vname)::ctxt) bop.pbop_exp }
              | _ -> { bop with pbop_exp = map_expr bop.pbop_exp }
            in
            Pexp_letop { let_ = map_bop l.let_;
                         ands = List.map map_bop l.ands;
                         body = map_expr l.body }
        end
        | Pexp_extension e -> Pexp_extension (self#extension ctxt e)
        | _ -> expr_desc

      method! extension ctxt ext =
        let check en =
          en = "LOG" || en = "_LOG" ||
          Level.Log.Extension.is_ext_name en ||
          Level.Block.Extension.is_ext_name en
        in
        match ext with
        | { txt = ename; loc }, p when ctxt <> [] && check ename -> begin
            let path = "."^logger_name^(String.concat "" (List.rev ctxt)) in
            { txt = ename^path; loc }, self#payload ctxt p
        end
        | _ -> ext
    end
    in
    mapper#structure_item [] si

  let extract () = Ast_pattern.(pstr (__ ^:: nil))

  let extension =
    Extension.(V3.declare "capture_path" Context.structure_item (extract()) expand)
end


let () =
  Driver.add_arg "-level"
    (Arg.String (fun s -> Args.level := Level._to_int s)) ~doc:"<level> Set logging level";
  Driver.add_arg "-logger"
    (Arg.Set_string Args.logger) ~doc:"<name> Set logger name";
  Driver.add_arg "-for-pack"
    (Arg.Set_string Args.for_pack) ~doc:"<prefix> Set prefix for logger names";
  let level_rules =
    List.map
      Context_free.Rule.extension
      Level.Extension.([fatal; error; warn; info; debug; trace])
  in
  let log_rule = Context_free.Rule.extension Log.extension in
  let _log_rule = Context_free.Rule.extension Log._extension in

  let name_rule = Context_free.Rule.extension Name.extension in
  let props_rule = Context_free.Rule.extension Properties.extension in
  let props_alt_rule = Context_free.Rule.extension Properties.extension_alt in
  let exc_rule = Context_free.Rule.extension Exception.extension in
  let exc_alt_rule = Context_free.Rule.extension Exception.extension_alt in
  let prep_rule = Context_free.Rule.extension Prepare.extension in

  let vlt_rule = Context_free.Rule.extension StructureItem.extension in

  let rules0 =
    log_rule::_log_rule::
    name_rule::props_rule::props_alt_rule::exc_rule::exc_alt_rule::
    level_rules
  in
  let rules1 =
    List.fold_left
      (fun l x -> (Context_free.Rule.extension x)::l)
      rules0
      Level.Log.Extension.extensions
  in
  let rules =
    vlt_rule::
    prep_rule::
    (List.fold_left
       (fun l x -> (Context_free.Rule.extension x)::l)
       rules1
       Level.Block.Extension.extensions)
  in
  Driver.register_transformation ~rules "_vlt_ppx"
