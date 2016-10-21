#!/usr/bin/env python

import ninja_syntax
import os, sys, glob, re
import itertools
import argparse

# whether or not we're on a 64-bit system
is_x64 = sys.maxsize > 2**32
is_nix = 'linux' in sys.platform
is_windows = 'win32' in sys.platform

default_install_dir = os.path.join('/usr', 'bin') if 'linux' in sys.platform else './bin/'

# command line stuff
parser = argparse.ArgumentParser()
parser.add_argument('--debug', action='store_true', help='compile with debug flags')
parser.add_argument('--ci', action='store_true', help=argparse.SUPPRESS)
parser.add_argument('--testing', action='store_true', help=argparse.SUPPRESS)
parser.add_argument('--install-dir', metavar='<dir>', help='directory to install the headers to', default=default_install_dir)
parser.epilog = """In order to install sol, administrative privileges might be required.
Note that installation is done through the 'ninja install' command. To uninstall, the
command used is 'ninja uninstall'. The default installation directory for this
system is {}""".format(default_install_dir)

args = parser.parse_args()

# Default Directories
platform = 'x64' if is_x64 else 'x86' 
configuration = 'debug' if args.debug else 'release' 
output_dir = os.path.join(platform, configuration)
obj_dir = os.path.join(platform, configuration, 'obj')
install_dir = args.install_dir

# Compiler: Read from environment or defaulted
ocamlc = os.environ.get('OCAMLC', "ocamlc") 
ocamllink = ocamlc
ocamllex = os.environ.get('OCAMLLEX', "ocamllex") 
ocamlmenhir = os.environ.get('MENHIR', "menhir")

# utilities
def flags(*args):
	return ' '.join(itertools.chain(*args))

def ocaml_object_file(f):
	(root, ext) = os.path.splitext(f)
	return os.path.join(objdir, root + '.cmo')

def replace_extension(f, e):
	(root, ext) = os.path.splitext(f)
	return root + e

def copy_directory( d ):
	return ''

# general variables
include = [ '.', './include' ]
ocamlcflags = [ ]
ocamllexflags = [ ]
ocamlmenhirflags = [ ]
ocamllinkflags = [ ]

copy_command = 'cp -rf {} $in && cp -f {} $in'.format(sol_dir, sol_file)
remove_command = 'rm -rf {} && rm -f {}'.format(os.path.join(args.install_dir, 'sol'), os.path.join(args.install_dir, 'sol.hpp'))
if sys.platform == 'win32':
	copy_command = 'robocopy /COPYALL /E {} $in && robocopy /COPYALL {} $in'.format(sol_dir, sol_file)
	remove_command = 'rmdir /S /Q {} && erase /F /S /Q /A {}'.format(os.path.join(args.install_dir, 'sol'),
																	 os.path.join(args.install_dir, 'sol.hpp'))

if args.debug:
	# debug flags and config go here
	ocamlcflags.extend(['-g', '-O0'])

if 'linux' in sys.platform:
	ldflags.extend(libraries(['dl']))

builddir = 'x64/bin' if is_x64 else 'x86/bin'
objdir = 'x64/obj' if is_x64 else 'x86/obj'

#if 'win32' in sys.platform:
#	 tests = os.path.join(builddir, 'tests.exe')
#else:
#	 tests = os.path.join(builddir, 'tests')

#tests_inputs = []
#tests_object_files = []
#for f in glob.glob('test*.ocaml'):
#	obj = object_file(f)
#	tests_inputs.append(f)
#	tests_object_files.append(obj)

#examples = []
#examples_input = []
#for f in glob.glob('examples/*.lepix'):
#	if 'win32' in sys.platform:
#		example = os.path.join(builddir, replace_extension(f, '.exe'))
#	else:
#		example = os.path.join(builddir, replace_extension(f, ''))
#	examples_input.append(f)
#	examples.append(example)


# ninja file
ninja = ninja_syntax.Writer(open('build.ninja', 'w'))

# variables
ninja.variable('ninja_required_version', '1.3')
ninja.variable('builddir', 'bin')
ninja.variable('cxx', args.cxx)
ninja.variable('cxxflags', flags(cxxflags + includes(include) + dependencies(depends)))
ninja.variable('example_cxxflags', flags(example_cxxflags + includes(include) + dependencies(depends)))
ninja.variable('ldflags', flags(ldflags))
ninja.newline()

# rules
ninja.rule('bootstrap', command = ' '.join(['python'] + sys.argv), generator = True)
ninja.rule('compile', command = '$cxx -MMD -MF $out.d -c $cxxflags -Werror $in -o $out',
					  deps = 'gcc', depfile = '$out.d',
					  description = 'compiling $in to $out')
ninja.rule('link', command = '$cxx $cxxflags $in -o $out $ldflags', description = 'creating $out')
#ninja.rule('tests_runner', command = tests)
#ninja.rule('examples_runner', command = 'cmd /c ' + (' && '.join(examples)) if 'win32' in sys.platform else ' && '.join(examples) )
#ninja.rule('example', command = '$cxx $example_cxxflags -MMD -MF $out.d $in -o $out $ldflags',
#					  deps = 'gcc', depfile = '$out.d',
#					  description = 'compiling example $in to $out')
ninja.rule('installer', command = copy_command)
ninja.rule('uninstaller', command = remove_command)
ninja.newline()

# builds
ninja.build('build.ninja', 'bootstrap', implicit = sys.argv[0])

for obj, f in zip(tests_object_files, tests_inputs):
	ninja.build(obj, 'compile', inputs = f)

for example, f in zip(examples, examples_input):
	ninja.build(example, 'example', inputs = f)

ninja.build(lexer, 'lexer', inputs = compiler_object_files)
ninja.build(parser, 'parser', inputs = compiler_object_files)
ninja.build(compiler, 'compiler', inputs = compiler_object_files)
ninja.build('compiler', 'phony', inputs = compiler)
ninja.build('examples', 'phony', inputs = examples)
ninja.build('install', 'installer', inputs = args.install_dir)
ninja.build('uninstall', 'uninstaller')
ninja.build('run', 'tests_runner', implicit = 'compiler')
ninja.build('run_examples', 'examples_runner', implicit = 'examples')
ninja.default('run run_examples')
