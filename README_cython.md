# Speed up `epydemic` by `Cython`
Author: Yiran Ren <yr28@st-andrews.ac.uk>

This file and related files are allowed to be combined with the README.rst 
or do any modify. :)

## Overview
`Cython` is a widely used optimization compiler for accelerating `Python` code.
It can be used to compile `Python` files directly by `setup_cython.py`, 
as long as the packages contained do not conflict with `Cython`. 
From this perspective, `Cython` support many `Python` libraries.
It also supports pure `Python` code mode or adding static typing information
to get more acceleration. 
Also, `Cython` packages is able to run on `PyPy` interpreter 
and expected speed up 10% more. 

## Documentation
This project modifies `epydemic` files by `setup_cython.py`, 
which is used to call `Cython` methods. 
For this project at present if you want to use it to create optimized files,
you need to do is - 
* first, put the `setup_cython.py` under the same directory of the target file;
* put the file name into `ext_modules = cythonize()`,
* then running `python setup_cython.py build_ext --inplace` in command.

If you modified the original files, compiled files, 
you need to recompile it using the setup tool. 
If not, the package will not crash, 
but the corresponding .so file will not work anymore. 
To avoid any possible error and to gain the most from `Cython`, 
it is highly recommended check out `Cython` configurations before updating anything. 

## Changes
Following is a list of the changes made: 

* Readme file: `README_cython.md`
* setup tool: `epydemic/setip_cython.py`
* Compiled file `epydemic/bbt.cpython-39-darwin.so`
* Compiled file `epydemic/compartmentedmodel.cpython-39-darwin.so`
* Compiled file`epydemic/bitstream.cpython-39-darwin.so`
* `Cython` is added into the list of dependencies - `requirements.txt`
* update `.gitignore` - changes saves under `# MISC_cython`