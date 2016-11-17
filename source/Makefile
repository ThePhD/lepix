#Clean intermediate files
clean :
	ocamlbuild -clean
	rm -rf testall.log *.diff microc scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o
	rm -rf parser.output

lepix :
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis lepix.native



