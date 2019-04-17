.PHONY: all install uninstall clean doc utop

all:
	dune build @install

utop:
	dune utop

install:
	dune install

uninstall:
	dune uninstall

clean:
	dune clean

doc:
	dune build @doc
