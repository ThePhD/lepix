#!/usr/bin/env python

import ninja_syntax
import os, sys, glob, re
import itertools
import argparse

# whether or not we're on a 64-bit system
is_x64 = sys.maxsize > 2**32
is_nix = 'linux' in sys.platform
is_windows = 'win32' in sys.platform

# utilities
def flags(*args):
	return ' '.join(itertools.chain(*args))

def replace_extension(f, e):
	(root, ext) = os.path.splitext(f)
	return root + e

def ocaml_object_file(f, e):
	return replace_extension(f, '.cmo')

def copy_directory_command( f, t = None ):
	if t is None:
		t = '$in'
	if is_windows:
		return 'robocopy /COPYALL /E {} {}'.format(f, t)
	else:
		return 'cp -rf {} {}'.format(f, t)

def copy_file_command( f, t = None ):
	if t is None:
		t = '$in'
	if is_windows:
		return 'robocopy /COPYALL {} {}'.format(f, t)
	else:
		return 'cp -f {} {}'.format(f, t)

def remove_directory_command( t = None ):
	if t is None:
		t = '$in'
	if is_windows:
		return 'rmdir /S /Q {}'.format(t)
	else:
		return 'rm -rf {}'.format(t)

def remove_file_command( t = None ):
	if t is None:
		t = '$in'
	if is_windows:
		return 'erase /F /S /Q /A {}'.format(t)
	else:
		return 'rm -f {}'.format(t)

default_install_dir = os.path.join('/usr', 'bin') if is_nix else './bin/'

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
ocamlparse = os.environ.get('MENHIR', "menhir")

# general variables
include = [ '.', './include' ]
ocamlc_flags = [ '-c' ]
ocamllex_flags = [ ]
ocamlparse_flags = [ ]
ocamllink_flags = [ ]

if args.debug:
	# debug flags and config go here
	ocamlcflags.extend(['-g'])

# ninja file constructions
# write the default ninja file
ninja = ninja_syntax.Writer(open('build.ninja', 'w'))

# variables
ninja.variable('ninja_required_version', '1.3')

ninja.variable('ocamlc', ocamlc)
ninja.variable('ocamllink', ocamllink)
ninja.variable('ocamllex', ocamllex)
ninja.variable('ocamlparse', ocamlparse)

ninja.variable('ocamlc_flags', flags(ocamlc_flags))
ninja.variable('ocamllink_flags', flags(ocamllink_flags))
ninja.variable('ocamllex_flags', flags(ocamllex_flags))
ninja.variable('ocamlparse_flags', flags(ocamlparse_flags))

ninja.variable('output_dir', output_dir)
ninja.variable('obj_dir', obj_dir)
ninja.variable('install_dir', install_dir)

ninja.newline()

# rules
ninja.rule('bootstrap', command = ' '.join(['python'] + sys.argv), generator = True)
ninja.rule('lexer', command = '$ocamllex -MMD -MF $out.d -c $cxxflags -Werror $in -o $out',
					  deps = 'gcc', depfile = '$out.d',
					  description = 'Compiling $in to $out')
ninja.rule('compile', command = '$ocamlc -MMD -MF $out.d -c $cxxflags -Werror $in -o $out',
					  deps = 'gcc', depfile = '$out.d',
					  description = 'Compiling $in to $out')
ninja.rule('link', command = '$cxx $cxxflags $in -o $out $ldflags', description = 'creating $out')
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
