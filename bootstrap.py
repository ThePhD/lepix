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
parser.epilog = """In order to install lepix, administrative privileges might be required.
Note that installation is done through the 'ninja install' command. To uninstall, the
command used is 'ninja uninstall'. The default installation directory for this
system is {}""".format(default_install_dir)

args = parser.parse_args()

# Default Directories
platform = 'x64' if is_x64 else 'x86' 
configuration = 'debug' if args.debug else 'release' 
obj_dir = os.path.join(platform, configuration, 'obj')
output_dir = os.path.join(platform, configuration)
lepix_output = 'lepix'
lepix_output_name = 'lepix' + ( '.exe' if is_windows else '' )
install_dir = args.install_dir

# Compiler: Read from environment or defaulted
ocamlc = os.environ.get('OCAMLC', "ocamlc") 
ocamllink = ocamlc
ocamllex = os.environ.get('OCAMLLEX', "ocamllex") 
ocamlparse = os.environ.get('MENHIR', "ocamlparse")

# general variables
ocamlc_flags = [ '-c' ]
ocamllex_flags = [ ]
ocamlparse_flags = [ ]
ocamllink_flags = [ ]

if args.debug:
	# debug flags and config go here
	ocamlc_flags.extend(['-g'])
	ocamllink_flags.extend(['-g'])

# installation commands
copy_command = copy_file_command(os.path.join(output_dir, lepix_output_name), install_dir)
remove_command = remove_file_command(os.path.join(install_dir, lepix_output_name))

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
ninja.rule('lexer', command = '$ocamllex -c $ocamllex_flags $in -o $out',
					  description = 'running lexer generator $ocamllex - $in to $out')
ninja.rule('parser', command = '$ocamlparse -c $ocamlparse_flags $in -o $out',
					  description = 'running parser generator $ocamlparse - $in to $out')
ninja.rule('compile', command = '$ocamlc -c $ocamlc_flags -Werror $in -o $out',
					  description = 'compiling with $ocamlc - $in to $out')
ninja.rule('link', command = '$ocamllink -o $out $in $ocamllink_flags',
		 description = 'linking with $ocamllink - creating $out')
ninja.rule('installer', command = copy_command)
ninja.rule('uninstaller', command = remove_command)
ninja.newline()

# Files, rules and inputs
lepix_compiler_object_files = ['ast.cmx', 'codegen.cmx', 'parser.cmx', 'scanner.cmx', 'semantic.cmx', 'lepix.cmx']
[
	('parser.ml', 'parser', ['parser.mly'])
	('scanner.ml', 'lexer', ['scanner.mll'])
	('codegen.cmo', 'compile', ['ast.cmo'])
	('ast.cmo', 'compile', [])
	('lepix.cmo', 'compile', ['semantic.cmo', ''])
	('scanner.cmo', 'compile', [''])
	('semantic.cmo', 'compile', ['ast.cmo'])
	('parser.cmi', 'compile', ['ast.cmo'])
	('parser', 'compile', [''])
	(lepix_output_name, 'link', lepix_compiler_object_files)
]

# builds
ninja.build('build.ninja', 'bootstrap', implicit = sys.argv[0])
ninja.build('lepix_lexer', 'lexer', inputs = lepix_compiler_lexer_files)
ninja.build('lepix_parser', 'parser', inputs = lepix_compiler_parser_files)
ninja.build('lepix_compile', 'compile', inputs = lepix_compiler_object_files)
ninja.build('lepix_link', 'link', inputs = lepix_compiler_object_files)
ninja.build(lepix_output_name, 'phony', inputs = lepix_compiler)
ninja.build('clean', 'phony', inputs = lepix)
ninja.default(lepix_output_name)
