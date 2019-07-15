# Makefile for epydemic
#
# Copyright (C) 2017--2019 Simon Dobson
# 
# This file is part of epydemic, epidemic network simulations in Python.
#
# epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# epydemic is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with epydemic. If not, see <http://www.gnu.org/licenses/gpl.html>.

# The name of our package on PyPi
PACKAGENAME = epydemic

# The version we're building
VERSION = 0.99.2


# ----- Sources -----

# Source code
SOURCES_SETUP_IN = setup.py.in
SOURCES_SDIST = dist/$(PACKAGENAME)-$(VERSION).tar.gz
SOURCES_CODE = \
	epydemic/__init__.py \
	epydemic/networkdynamics.py \
	epydemic/synchronousdynamics.py \
	epydemic/stochasticdynamics.py \
	epydemic/loci.py \
	epydemic/process.py \
	epydemic/compartmentedmodel.py \
	epydemic/sir_model.py \
	epydemic/sir_model_fixed_recovery.py \
	epydemic/sis_model.py \
	epydemic/sis_model_fixed_recovery.py \
	epydemic/sirs_model.py \
	epydemic/adddelete.py

SOURCES_TESTS = \
	test/__init__.py \
	test/test_networkdynamics.py \
	test/test_stochasticrates.py \
	test/test_compartmentedmodel.py \
	test/compartmenteddynamics.py \
	test/test_sir.py \
	test/test_sis.py \
	test/test_fixed_recovery.py \
	test/test_adddelete.py
TESTSUITE = test

SOURCES_TUTORIAL = doc/epydemic.ipynb
SOURCES_DOC_CONF = doc/conf.py
SOURCES_DOC_BUILD_DIR = doc/_build
SOURCES_DOC_BUILD_HTML_DIR = $(SOURCES_DOC_BUILD_DIR)/html
SOURCES_DOC_ZIP = epydemic-doc-$(VERSION).zip
SOURCES_DOC_GENERAL = \
	doc/index.rst \
	doc/install.rst \
	doc/reference.rst \
	doc/simulation.rst \
	doc/bibliography.rst \
	doc/glossary.rst
SOURCES_DOC_SOURCES = \
	doc/networkdynamics.rst \
	doc/synchronousdynamics.rst \
	doc/stochasticdynamics.rst \
	doc/loci.rst \
	doc/compartmentedmodel.rst \
	doc/sir.rst \
	doc/sis.rst \
	doc/sir_fixed_recovery.rst \
	doc/sis_fixed_recovery.rst \
	doc/adddelete.rst
SOURCES_DOC_TUTORIAL = \
	doc/tutorial.rst \
	doc/tutorial/use-standard-model.rst \
	doc/tutorial/build-sir.rst \
	doc/tutorial/run-at-scale.rst  \
	doc/tutorial/advanced-topics.rst
SOURCES_DOC_COOKBOOK = \
	doc/cookbook.rst \
	doc/cookbook/build-network-in-experiment.rst \
	doc/cookbook/population-powerlaw-cutoff.rst \
	doc/cookbook/monitoring-progress.rst \
	doc/cookbook/powerlaw-cutoff.png \
	doc/cookbook/sir-progress-dt.png \
	doc/cookbook/sir-progress-er.png \
	doc/cookbook/sir-progress-plc.png
SOURCES_DOC_JOSS = paper.md
SOURCES_DOCUMENTATION = \
	$(SOURCES_DOC_GENERAL) \
	$(SOURCES_DOC_SOURCES) \
	$(SOURCES_DOC_TUTORIAL) \
	$(SOURCES_DOC_COOKBOOK)

SOURCES_UTILS = \
    utils/make-powerlaw-cutoff.py \
    utils/make-monitor-progress.py

SOURCES_EXTRA = \
	README.rst \
	LICENSE \
	HISTORY \
	CONTRIBUTORS
SOURCES_GENERATED = \
	MANIFEST \
	setup.py

# Python packages needed
# For the system to install and run
PY_REQUIREMENTS = \
    six \
	numpy \
	networkx \
	future \
	epyc
# For the documentation and development venv
PY_DEV_REQUIREMENTS = \
	ipython \
	jupyter \
	mpmath \
	matplotlib \
	seaborn \
	nose \
	tox \
	coverage \
	sphinx \
	twine

# Packages that shouldn't be saved as requirements (because they're
# OS-specific, in this case OS X, and screw up Linux compute servers,
# or because of Python 2.7 vs 3.7 incompatibilities)
PY_NON_REQUIREMENTS = \
	appnope \
	functools32 \
	subprocess32 \
	futures
VENV = venv3
REQUIREMENTS = requirements.txt
DEV_REQUIREMENTS = dev-requirements.txt


# ----- Tools -----

# Base commands
PYTHON = python
IPYTHON = ipython
JUPYTER = jupyter
IPCLUSTER = ipcluster
TOX = tox
COVERAGE = coverage
PIP = pip
TWINE = twine
GPG = gpg
VIRTUALENV = python3 -m venv
ACTIVATE = . $(VENV)/bin/activate
TR = tr
CAT = cat
SED = sed
RM = rm -fr
CP = cp
CHDIR = cd
ZIP = zip -r

# Root directory
ROOT = $(shell pwd)

# Constructed commands
RUN_TESTS = $(TOX)
RUN_COVERAGE = $(COVERAGE) erase && $(COVERAGE) run -a setup.py test && $(COVERAGE) report -m --include '$(PACKAGENAME)*'
RUN_NOTEBOOK = $(JUPYTER) notebook
RUN_SETUP = $(PYTHON) setup.py
RUN_SPHINX_HTML = PYTHONPATH=$(ROOT) make html
RUN_TWINE = $(TWINE) upload dist/$(PACKAGENAME)-$(VERSION).tar.gz dist/$(PACKAGENAME)-$(VERSION).tar.gz.asc
NON_REQUIREMENTS = $(SED) $(patsubst %, -e '/^%*/d', $(PY_NON_REQUIREMENTS))


# ----- Top-level targets -----

# Default prints a help message
help:
	@make usage

# Run tests for all versions of Python we're interested in
test: env setup.py
	$(ACTIVATE) && $(RUN_TESTS)

# Run coverage checks over the test suite
coverage: env
	$(ACTIVATE) && $(RUN_COVERAGE)

# Build the API documentation using Sphinx
.PHONY: doc
doc: $(SOURCES_DOCUMENTATION) $(SOURCES_DOC_CONF)
	$(ACTIVATE) && $(CHDIR) doc && $(RUN_SPHINX_HTML)

# Run a server for writing the documentation
.PHONY: docserver
docserver:
	$(ACTIVATE) && $(CHDIR) doc && PYTHONPATH=.. $(RUN_NOTEBOOK)

# Build a development venv from the known-good requirements in the repo
.PHONY: env
env: $(VENV)

$(VENV):
	$(VIRTUALENV) $(VENV)
	$(CP) $(DEV_REQUIREMENTS) $(VENV)/requirements.txt
	$(ACTIVATE) && $(CHDIR) $(VENV) && $(PIP) install -r requirements.txt

# Build a development venv from the latest versions of the required packages,
# creating a new requirements.txt ready for committing to the repo. Make sure
# things actually work in this venv before committing!
.PHONY: newenv
newenv:
	$(RM) $(VENV)
	$(VIRTUALENV) $(VENV)
	echo $(PY_REQUIREMENTS) | $(TR) ' ' '\n' >$(VENV)/$(REQUIREMENTS)
	$(ACTIVATE) && $(CHDIR) $(VENV) && $(PIP) install -r requirements.txt && $(PIP) freeze >requirements.txt
	$(NON_REQUIREMENTS) $(VENV)/requirements.txt >$(REQUIREMENTS)
	echo $(PY_DEV_REQUIREMENTS) | $(TR) ' ' '\n' >$(VENV)/$(REQUIREMENTS)
	$(ACTIVATE) && $(CHDIR) $(VENV) && $(PIP) install -r requirements.txt && $(PIP) freeze >requirements.txt
	$(NON_REQUIREMENTS) $(VENV)/requirements.txt >$(DEV_REQUIREMENTS)

# Build a source distribution
sdist: $(SOURCES_SDIST)

# Upload a source distribution to PyPi
upload: $(SOURCES_SDIST)
	$(GPG) --detach-sign -a dist/$(PACKAGENAME)-$(VERSION).tar.gz
	$(ACTIVATE) && $(RUN_TWINE)

# Clean up the distribution build 
clean:
	$(RM) $(SOURCES_GENERATED) epyc.egg-info dist $(SOURCES_DOC_BUILD_DIR) $(SOURCES_DOC_ZIP)

# Clean up everything, including the computational environment (which is expensive to rebuild)
reallyclean: clean
	$(RM) $(VENV)


# ----- Generated files -----

# Manifest for the package
MANIFEST: Makefile
	echo  $(SOURCES_EXTRA) $(SOURCES_GENERATED) $(SOURCES_CODE) | $(TR) ' ' '\n' >$@

# The setup.py script
setup.py: $(SOURCES_SETUP_IN) Makefile
	$(CAT) $(SOURCES_SETUP_IN) | $(SED) -e 's/VERSION/$(VERSION)/g' -e 's/REQUIREMENTS/$(PY_REQUIREMENTS:%="%",)/g' >$@

# The source distribution tarball
$(SOURCES_SDIST): $(SOURCES_GENERATED) $(SOURCES_CODE) Makefile
	$(ACTIVATE) && $(RUN_SETUP) sdist


# ----- Usage -----

define HELP_MESSAGE
Available targets:
   make test         run the test suite for all Python versions we support
   make coverage     run coverage checks of the test suite
   make doc          build the API documentation using Sphinx
   make dist         create a source distribution
   make upload       upload distribution to PyPi
   make clean        clean-up the build
   make reallyclean  clean up the virtualenv as well

endef
export HELP_MESSAGE

usage:
	@echo "$$HELP_MESSAGE"
