(* This file is part of ecoss.
 *
 * Copyright (C) 2019 Yann Régis-Gianas, Théo Zimmermann
 *
 * ecoss is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

open Sys
open Printf
open Messages

let default_data_sets_dir =
  try Sys.getenv "ECOSS_DATASETS" with Not_found -> "./data"

let set_data_sets_dir, data_sets_dir =
  X.ref_as_functions ~init:default_data_sets_dir ()

let check_data_sets_dir_existence () =
  inform "Checking data sets directory.";
  let path = data_sets_dir () in
  if not (file_exists path && is_directory path) then
    initialization_error (sprintf "`%s' does not exist." path)

let data_sets_path filename =
  Filename.concat (data_sets_dir ()) filename

let check_data_set_freshness (prefix, filename) =
  let path = data_sets_path filename in
  let flags = if file_exists path then sprintf "-z \"%s\"" path else "" in
  let curling =
    sprintf "curl -o \"%s\" %s \"%s/%s\""
      (data_sets_path filename) flags prefix filename
  in
  let get_mtime () =
    if flags <> "" then Unix.((stat path).st_mtime) else 0.
  in
  let date = get_mtime () in
  if command curling <> 0 then
    initialization_error (sprintf "Command `%s` failed." curling);
  get_mtime () <> date

let initializers =
  ref []

let register data_sets_initializer =
  initializers := data_sets_initializer :: !initializers

let check_data_sets_freshness () =
  inform "Checking data sets freshness.";
  List.iter (fun f -> f (data_sets_dir ())) !initializers

let initialize () =
  check_data_sets_dir_existence ();
  check_data_sets_freshness ()
