(* This file is part of ecoss.
 *
 * Copyright (C) 2019 Yann Régis-Gianas, Théo Zimmermann
 *
 * ecoss is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

val data_sets_dir : unit -> string
(** [data_sets_dir ()] is a directory where data sets are stored.
    By default, it is "./data" but this value can be overriden
    using the environment variable [$ECOSS_DATASETS] or by calling
    [set_data_sets_dir] *)

val set_data_sets_dir : string -> unit
(** Define [data_sets_dir ()]. *)

val initialize : unit -> unit
(** [initialize ()] ensures that [data_sets_dir ()] contains the
    up-to-date data sets that [ecoss] can handle. It also loads
    several index in memory. This function is automatically called
    during startup. Yet, it can be called again to refresh the
    state of the library, typically when [data_sets_dir ()] has
    been changed by external means. *)

type ecosystem

val ecosystems : unit -> ecosystem list

val ecosystem : string -> ecosystem

val ecosystem_names : unit -> string list

val ecosystem_name : ecosystem -> string

type package

val ecosystem_packages : ecosystem -> package Seq.t

type dependency

val package_dependencies : package -> dependency list
