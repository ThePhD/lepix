import unittest
import subprocess
import argparse
import sys
import os.path

# whether or not we're on a 64-bit system
is_x64 = sys.maxsize > 2**32
is_nix = 'linux' in sys.platform
is_windows = 'win32' in sys.platform

lepix = 'source/lepixc'
lli = 'lli'

os.makedirs(os.path.join("tests", "output"), exist_ok=True)

def output_file(f):
	return os.path.join("tests", "output", f)

def input_file(f):
	return os.path.join("tests", f)
	

def run_process(target, *args):
	sp = subprocess.Popen([target] + list(args), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	out, err = sp.communicate()
	return sp.returncode, out, err

def run_compiler(*args):
	r, sout, serr = run_process(lepix, *args)
	return r, sout, serr

def run_lli(*args):
	r, sout, serr = run_process(lli, *args)
	return r, sout, serr

def compile_and_run(input, output = None):
	if output is None:
		output = output_file(os.path.basename(input)) + ".ll";
	compiler_r, compiler_out, compiler_err = run_compiler("-l",  "-o", output, input)
	if compiler_r != 0:
		return compiler_r, compiler_out, compiler_err
	lli_r, lli_out, lli_err = run_lli(output)
	return lli_r, lli_out, lli_err

def compile_and_run_case(input):
	return compile_and_run(input_file(input))

class hello_world_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		self.returncode, self.output, self.error = compile_and_run_case("hello_world.lepix")
		typed_output = int(self.output);
		self.assertEqual(self.returncode, 0)
		self.assertEqual(self.output, "24\n")
		self.assertEqual(typed_output, 24)
		self.assertEqual(self.error, "")

if __name__ == '__main__':
    unittest.main()