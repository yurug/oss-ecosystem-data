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
(** The data for a specific ecosystem. *)

val ecosystems : unit -> ecosystem list
(** The list of ecosystems of this data set. *)

val ecosystem_name : ecosystem -> string
(** Every ecosystem has a unique name. *)

val ecosystem_names : unit -> string list
(** The names of the ecosystems of this data set. *)

val ecosystem : string -> ecosystem
(** [ecosystem name] raises [Not_found] if [name] is not
    in [ecosystem_names ()]. *)

type package
(** The data for a package. Each package belongs to an ecosystem. *)

val ecosystem_packages : ecosystem -> package Seq.t
(** [ecosystem_packages e] potentially large list of packages that
    belongs to [e]. *)

type dependency
(** A package has zero, one or several dependencies. *)

val package_dependencies : package -> dependency list
(** [package_dependencies p]. *)

val dependency_source : ecosystem -> dependency -> package option
(** For every [dependency] in [package_dependencies p],
    [dependency_source ecosystem dependency] is a package that is
    necessary for [p]. *)

val transitive_dependencies : ecosystem -> package -> dependency list
(** Compute all transitive dependencies of a given package assuming
    there are no infinite descending chains. *)
