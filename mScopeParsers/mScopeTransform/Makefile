PACKAGE_NAME = venv-mscope
VIRTUAL_ENV := $(DATATOOLS_HOME)/$(PACKAGE_NAME)
PATH := $(VIRTUAL_ENV)/bin:$(PATH)

all: install init test

init: install
	@echo export VIRTUAL_ENV=$(VIRTUAL_ENV) >> $(HOME)/.bashrc

test: init
	@bash -c '. $(VIRTUAL_ENV)/bin/activate; python3 test_transform.py;'

install:
	@test -d "$(VIRTUAL_ENV)" || mkdir -p "$(VIRTUAL_ENV)"
	@test -x "$(VIRTUAL_ENV)/bin/python" || virtualenv --quiet "$(VIRTUAL_ENV)"
	@pip install --no-deps .
	@pip install -r ./requirements.txt 

clean:
	rm -rf "$(VIRTUAL_ENV)"

#reset:
#	$(MAKE) clean
#	rm -rf "$(VIRTUAL_ENV)"
#	$(MAKE) install

#check:
#	@scripts/check-code-style.sh

.PHONY: init clean test install all
