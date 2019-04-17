(* This file is part of ecoss.
 *
 * Copyright (C) 2019 Yann Régis-Gianas, Théo Zimmermann
 *
 * ecoss is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

(*****************************************************************************)
(*                                Environment                                *)
(*****************************************************************************)

let set_data_sets_dir = DataSets.set_data_sets_dir

let data_sets_dir = DataSets.data_sets_dir

let initialize () =
  DB.initialize ();
  LibrariesIO.initialize ();
  DataSets.initialize ()

let _auto_initialization = initialize ()

(*****************************************************************************)
(*                                   Data                                    *)
(*****************************************************************************)
type ecosystem = Ecosystem.t

let ecosystem_name =
  Ecosystem.name

let ecosystems () =
  LibrariesIO.ecosystems ()

let ecosystem_names () =
  List.map ecosystem_name (ecosystems ())

let ecosystem name =
  List.find (fun e -> Ecosystem.name e = name) (ecosystems ())

type package = Package.t

let ecosystem_packages =
  Ecosystem.packages

type dependency =
  Package.dependency

let package_dependencies =
  Package.dependencies

let dependency_source ecosystem =
  Ecosystem.dependency_source ecosystem
