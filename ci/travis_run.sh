apt-get update
apt install -y git python python3 build-essential m4 autotools-dev autoconf pkg-config ocaml menhir opam llvm llvm-dev llvm.3.8
opam init -y
eval $(opam config env)
opam install -y llvm.3.8
eval $(opam config env)
cd source
make lepix
cd ..
python tests/tests.py
cd ..
