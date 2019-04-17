type t = {
  name : string;
  packages : unit -> Package.t Seq.t;
  package : string -> Package.t
}

let make name packages package = { name; packages; package }

let name e = e.name

let packages e = e.packages ()

let package e = e.package

let dependency_source ecosystem dependency =
  ecosystem.package dependency.Package.package
