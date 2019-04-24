type t = {
  name : string;
  packages : unit -> Package.t Seq.t;
  package : string -> Package.t
}

let make name packages package = { name; packages; package }

let name e = e.name

let packages e = e.packages ()

let package e = e.package

exception Package_does_not_exist of string

let dependency_source ecosystem dependency =
  try
    Some (ecosystem.package dependency.Package.package)
  with
    Package_does_not_exist _ -> None

(* This will loop infinitely if there exist an infinite descending
   chain of dependencies. *)
let rec transitive_dependencies ecosystem package =
  package |> Package.dependencies
  |> List.map (fun dependency ->
         dependency
         :: ( dependency
              |> dependency_source ecosystem
              |> function
                | None -> []
                | Some p -> transitive_dependencies ecosystem p ) )
  |> List.fold_left (fun l r ->
         l @ List.filter (fun x ->
                 List.for_all (fun y ->
                     not ( String.equal x.Package.package y.Package.package ) )
                   l)
               r)
       []
