.PHONY: all osx work bash bash-osx screen vim ssh work doctor

all: bash vim screen ssh

osx: bash vim screen ssh bash-osx

work: bash vim screen ssh bash-osx work

doctor:
	./scripts/dotfiles-doctor.sh

bash:
	$(MAKE) -C bash

bash-osx:
	$(MAKE) -C bash osx

screen:
	$(MAKE) -C screen

vim:
	$(MAKE) -C vim

ssh:
	$(MAKE) -C private ssh

work:
	$(MAKE) -C private work
