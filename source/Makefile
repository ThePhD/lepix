.PHONY: default
default: all;

# Clean intermediate files
clean :
	ocamlbuild -use-menhir -build-dir obj -clean
	rm -rf lepixc lepix
	rm -rf scanner.ml parser.ml parser.mli
	rm -rf prescanner.ml preparser.ml preparser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o
	rm -rf parser.automaton preparser.automaton 
	rm -rf parser.output preparser.output parser.conflicts preparser.conflicts 

# Build top level lepix executable
lepix :
	ocamlbuild -use-ocamlfind -use-menhir -tag thread -pkgs core,llvm,llvm.analysis -build-dir obj lepix.native
	cp -f obj/lepix.native lepixc

install :
	cp lepixc /usr/local/bin/lepixc

uninstall :
	rm -f /usr/local/bin/lepixc

.PHONY: all
all : lepix
