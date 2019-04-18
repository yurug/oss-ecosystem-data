open Printf
open X
module Pg = Pgx_unix
module Pv = Pgx_value

let set_dbname, dbname =
  X.ref_as_functions ~init:"ecoss" ()

let set_connection, connection =
  X.ref_as_functions ()

let set_debug_mode, debug_mode =
  X.ref_as_functions ~init:false ()

let escape s =
  Str.(global_replace (regexp "'") "\\'" s)

let query q params =
  let params = List.map Pv.of_string params in
  if debug_mode () then Printf.eprintf "Query: %s\n%!" q;
  Pg.execute ~params (connection ()) q

let command q params =
  query q params |> ignore

let fresh_table id schema =
  command
    (Printf.sprintf {| CREATE TABLE IF NOT EXISTS %s (%s); |} id schema)
    []

let string =
  !! Pv.to_string

let single_string = function
  | [ s ] -> string s
  | _ -> failwith "Not a single string"

let table_cardinal id =
  query {| SELECT COUNT(ID) FROM $1; |} [id] |> function
  | [ [ count ] ] -> X.unSome (Pv.to_int count)
  | _ -> assert false

let import_csv id schema csv ks =
  fresh_table id schema;
  if table_cardinal id = 0 then (
    command {| COPY $1 FROM $2 DELIMITER ',' CSV HEADER; |} [id; csv];
    List.iter
      (fun k -> command (sprintf {| CREATE INDEX ON %s(%s); |} id k) [])
      ks
  )

let connect () =
  Pg.connect ~database:(dbname ()) ()

let initialize () =
  set_connection (connect ());
  at_exit (fun () -> Pg.close (connection ()))
