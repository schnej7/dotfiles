.PHONY: all osx work bash bash-osx screen vim ssh git work

all: bash vim screen ssh git

osx: bash vim screen ssh git bash-osx

work: bash vim screen ssh git bash-osx work

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

git:
	$(MAKE) -C private git

work:
	$(MAKE) -C private work
