{ pkgs ? (import (fetchTarball https://github.com/NixOS/nixpkgs/tarball/c2612dc0f47e33a2f05fb22c6b2a4671f42b0f80) {})
, shell ? false
}:

with pkgs.ocaml-ng.ocamlPackages_4_07;

let pgx = buildDunePackage rec {
  pname = "pgx";
  version = "20190419";

  minimumOCamlVersion = "4.05";

  src = pkgs.fetchFromGitHub {
    owner = "arenadotio";
    repo = pname;
    rev = "03249c5a11b9572a10869ea2b427ae057be689b2";
    sha256 = "13s4ks8xw21vfiv300svx0vm24bnr1ymr69sihslp06vnzakdbi8";
  };

  buildInputs = [ ppx_tools_versioned base64 ounit ];
  propagatedBuildInputs = [ bisect_ppx ppx_jane uuidm re sexplib ];

  doCheck = true;

  meta = {
    description = "Pure-OCaml PostgreSQL client library";
    inherit (src) homepage;
    license = pkgs.lib.licenses.lgpl2;
  };
}; in

let pgx_unix = buildDunePackage {
  pname = "pgx_unix";
  inherit (pgx) version minimumOCamlVersion src buildInputs doCheck;

  propagatedBuildInputs = [ pgx ];

  meta = {
    description = "PGX using the standard library's Unix module for IO (synchronous)";
    inherit (pgx.meta) homepage license;
  };
}; in

buildDunePackage {

  pname = "ecoss";
  version = "dev";

  minimumOCamlVersion = "4.07";

  src = if shell then null else ./.;

  buildInputs =
    [ csv pgx pgx_unix ] ++ pkgs.lib.optionals shell [ merlin utop odoc ];
}
