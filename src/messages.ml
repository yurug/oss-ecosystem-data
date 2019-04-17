(* This file is part of ecoss.
 *
 * Copyright (C) 2019 Yann Régis-Gianas, Théo Zimmermann
 *
 * ecoss is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

open Printf

let initialization_error msg =
  eprintf "Error during initialization:\n  %s\n" msg;
  exit 1

let inform msg =
  printf "info> %s\n%!" msg
