eval $(opam config env)
cd ci_repo/source
make lepix
cd ..
python3 tests/tests.py
