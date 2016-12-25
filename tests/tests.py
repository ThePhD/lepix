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
	return sp.returncode, out.decode("utf-8"), err.decode("utf-8")

def run_compiler(*args):
	r, sout, serr = run_process(lepix, *args)
	return r, sout, serr

def run_lli(*args):
	r, sout, serr = run_process(lli, *args)
	return r, sout, serr

def compile_and_run(input, output = None):
	if output is None:
		output = output_file(os.path.basename(input)) + ".ll";
	compiler_r, compiler_out, compiler_err = run_compiler("-c",  "-o", output, input)
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
		self.assertEqual(self.returncode, 0)
		self.assertEqual(self.output, "hello world\n")
		self.assertEqual(self.error, "")

class literals_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		targetoutput = "24\n47\n47\n2\n2\n"
		self.returncode, self.output, self.error = compile_and_run_case("literals.lepix")
		self.assertEqual(self.returncode, 0)
		self.assertEqual(self.output, targetoutput)
		self.assertEqual(self.error, "")

class literals_fail_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		self.returncode, self.output, self.error = compile_and_run_case("literals_fail.lepix")
		self.assertNotEqual(self.returncode, 0)
		self.assertNotEqual(self.error, "")

class overloads_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		targetoutput = "8\n2\n4\n8\n3.500000\n"
		self.returncode, self.output, self.error = compile_and_run_case("overloads.lepix")
		self.assertEqual(self.returncode, 2)
		self.assertEqual(self.output, targetoutput)
		self.assertEqual(self.error, "")

class overloads_fail_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		self.returncode, self.output, self.error = compile_and_run_case("overloads_fail.lepix")
		self.assertNotEqual(self.returncode, 0)
		self.assertNotEqual(self.error, "")

class auto_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		self.returncode, self.output, self.error = compile_and_run_case("auto.lepix")
		self.assertEqual(self.returncode, 2)

		

class preprocess_test(unittest.TestCase):
	def setUp(self):
		#print('In setUp()')
		pass

	def tearDown(self):
		#print('In tearDown()')
		pass

	def test(self):
		self.returncode, self.output, self.error = compile_and_run_case("preprocess.lepix")
		self.assertEqual(self.output, "45\n");
		self.assertEqual(self.returncode, 0)
		
if __name__ == '__main__':
    unittest.main()