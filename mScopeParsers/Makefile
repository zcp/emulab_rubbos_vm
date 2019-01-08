# makefile for compiling the parseenv

#PACKAGE_NAME = venv-elba

#need to fix these
#WORKON_HOME ?= $(HOME)/.venv
#VIRTUAL_ENV ?= $(WORKON_HOME)/$(PACKAGE_NAME)
#PATH := $(VIRTUAL_ENV)/bin:$(PATH)

#MAKE := $(MAKE) --no-print-directory
#SHELL = bash

#JAVACOPTS = -deprecation
#CC = g++
#RM = rm


default:
	@echo "Makefile for $(PACKAGE_NAME)"
	@echo
	@echo 'Usage:'
	@echo
	@echo  '    make all      compile and install all data processing tools'
	#@echo '    make install    install the package in a virtual environment'
	#@echo '    make build      create environment for processing'
	#@echo '    make reset      recreate the virtual environment'
	#@echo '    make check      check coding style (PEP-8, PEP-257)'
	#@echo '    make test       run the test suite, report coverage'
	#@echo '    make readme     update usage in readme'
	#@echo '    make docs       update documentation using Sphinx'
	#@echo '    make publish    publish changes to GitHub/PyPI'
	@echo '    make clean      cleanup all temporary files'
	@echo

all:
	+$(MAKE) -C ElbaLensParser
	+$(MAKE) -C PointintimeParser
	+$(MAKE) -C ServiceTimeParser
	+$(MAKE) -C mScopeTransform

clean:
	+$(MAKE) -C ElbaLensParser clean
	+$(MAKE) -C PointintimeParser clean
	+$(MAKE) -C ServiceTimeParser clean
	+$(MAKE) -C mScopeTransform clean
