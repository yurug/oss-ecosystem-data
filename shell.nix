{ pkgs ? null }:

if pkgs == null
then import ./. { shell = true; }
else import ./. { shell = true; inherit pkgs; }
