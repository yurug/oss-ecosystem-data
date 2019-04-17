#!/usr/bin/env sh

check_program () {
  echo -n "Checking availability of $1... "
  if ! which $1 1> /dev/null; then
      echo "Please install \`$2\`.";
      exit 1
  fi
  echo "OK."
}

check_program psql "Postgres"
