apt-get update
apt install git python python3 build-essential ocaml opam llvm llvm-dev llvm.3.8
opam init
opam install llvm
opam install llvm.3.8
eval $(opam config env)
cd source
make lepix
cd ..
python tests/tests.py
cd ..
