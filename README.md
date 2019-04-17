# Uniform access to data about OSS ecosystems

## Installation

### From the sources

```
opam install .
```

## Setup

By default, the data sets are expecting to be loaded in `./data`. This
can be changed by setting the environment variable `ECOSS_DATASETS` to
another path.

We are using postgres to efficiently store data sets, so you need to setup
postgres properly. It will also consume several gigabytes on your hard drive.

`ecoss` is expecting a database named `ecoss` to which it can connect
using the standard environment variables `PGHOST`, `PGDATABASE`,
`PGUSER` and `PGPASSWORD`.

Typically, on my Debian distribution, I issued the following commands:
```
sudo -u postgres createuser --interactive yann
# I gave me superuser power, and I configure a password:
sudo -u postgres psql -c "ALTER USER yann PASSWORD 'postgres';"
createdb ecoss
```
Then, the following works:
```
PGHOST=localhost PGUSER=yann PGPORT=postgresql PGPASSWORD=postgres dune utop
```

## Example

```
open Ecoss

let maven = ecosystem "Maven"

let count, get = Ecoss__X.histogram ()

let () =
   ecosystem_packages maven
|> Seq.map (fun p -> length (package_dependencies p))
|> Seq.iter count

let dependencies_distribution =
   get () |> List.sort compare
```
