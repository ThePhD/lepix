eval $(opam config env)
cd ci_repo/source
make lepix
cd ..
python tests/tests.py
