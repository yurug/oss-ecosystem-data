type dependency = {
    package : string
}
and package = {
  name : string;
  dependencies : unit -> dependency list
}

type t = package

let make name dependencies =
  { name; dependencies }

let name package = package.name

let dependencies package = package.dependencies ()

let make_dependency package =
  { package }
