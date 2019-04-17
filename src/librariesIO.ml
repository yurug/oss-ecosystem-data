open X
open Messages
open Printf

let tarball =
  "Libraries.io-open-data-1.4.0.tar.gz"

let uri = (
  "https://zenodo.org/record/2536573/files/",
  tarball
)

let subdir =
  "libraries-1.4.0-2018-12-22"

let numeric field = field, "numeric"

let string field = field, "varchar"

let declaration_of_field (what, ty) =
  what ^ " " ^ ty

let scheme_of_fields fields =
  String.concat "," (List.map declaration_of_field fields)

let projects_fields = [
    numeric "ID";
    string "Platform";
    string "Name";
    string "CreatedTimestamp";
    string "UpdatedTimestamp";
    string "Description";
    string "Keywords";
    string "HomepageURL";
    string "Licenses";
    string "RepositoryURL";
    string "VersionsCount";
    string "SourceRank";
    string "LatestReleasePublishTimestamp";
    string "LatestReleaseNumber";
    numeric "PackageManagerID";
    numeric "DependentProjectsCount";
    string "Language";
    string "Status";
    string "LastsyncedTimestamp";
    string "DependentRepositoriesCount";
    numeric "RepositoryID";
]

let dependencies_fields = [
    numeric "ID";
    string "Platform";
    string "ProjectName";
    string "ProjectID";
    string "VersionNumber";
    numeric "VersionID";
    string "DependencyName";
    string "DependencyPlatform";
    string "DependencyKind";
    string "OptionalDependency";
    string "DependencyRequirements";
    numeric "DependencyProjectID"
  ]

let csvs = [
    "projects",     "projects-1.4.0-2018-12-22.csv",
    projects_fields, [ "Platform" ];

    "dependencies", "dependencies-1.4.0-2018-12-22.csv",
    dependencies_fields, [ "Platform"; "ProjectName" ]

    (* "tags-1.4.0-2018-12-22.csv";
     * "projects_with_repository_fields-1.4.0-2018-12-22.csv";
     * "repositories-1.4.0-2018-12-22.csv";
     * "versions-1.4.0-2018-12-22.csv",
     * "repository_dependencies-1.4.0-2018-12-22.csv" *)
]

let untar_csv data_sets_dir csv =
  inform (sprintf "Extracting %s. (This can take some time...)" csv);
  let path = Filename.concat subdir csv in
  if not (Sys.file_exists (Filename.concat data_sets_dir path)) then
    X.critical_command (
      sprintf "cd %s; tar xvfz %s %s" data_sets_dir tarball path
    );
  inform (sprintf "Extraction of %s, done." csv)

let process_csv data_sets_dir (id, csv, fields, keys) =
  untar_csv data_sets_dir csv;
  let full_path =
    Filename.(
      concat (Sys.getcwd ()) (
          concat data_sets_dir (concat subdir csv)))
  in
  inform (sprintf "Importing %s in the database." id);
  DB.import_csv id (scheme_of_fields fields) full_path keys

let refresh data_sets_dir =
  List.iter (process_csv data_sets_dir) csvs

let initialize () = DataSets.register (fun data_sets_dir ->
  if DataSets.check_data_set_freshness uri then refresh data_sets_dir
)

let dependencies_of_package e p =
  DB.query {| SELECT DISTINCT DependencyName FROM dependencies
                       WHERE Platform=$1 and ProjectName=$2; |}
           [e; p]
  |> List.map DB.single_string
  |> List.map Package.make_dependency

let make_package e p =
  let deps p = fun () -> dependencies_of_package e p in
  Package.make p (deps p)

let packages_of_ecosystem e =
  DB.query {| SELECT DISTINCT Name FROM projects WHERE Platform=$1; |} [e]
  |> fun packages ->
     Seq.(map (DB.single_string $$ (make_package e)) (seq_of_list packages))

let package_of_ecosystem e p =
  DB.query
    {| SELECT DISTINCT Name FROM projects WHERE Platform=$1 and Name=$2; |}
    [e; p]
 |> function [ package ] ->
              make_package e (DB.single_string package)
           | _ -> assert false

let platforms () =
  DB.query {| SELECT DISTINCT Platform FROM projects; |} []
  |> List.map DB.single_string

let ecosystems () : Ecosystem.t list =
  let make e =
    Ecosystem.make e
      (fun () -> packages_of_ecosystem e)
      (package_of_ecosystem e)
  in
  List.map make (platforms ())
