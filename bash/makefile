all: base aliases profile

base:
	ln -sf $(CURDIR)/bashrc ~/.bashrc
	ln -sf $(CURDIR)/inputrc ~/.inputrc
	ln -sf $(CURDIR)/inputrc.vi-common ~/.inputrc.vi-common
	ln -sf $(CURDIR)/bash_colors.bash ~/.bash_colors

aliases:
	ln -sf $(CURDIR)/aliases.bash ~/.bash_aliases
	ln -sf $(CURDIR)/llm.bash ~/.llm.bash

profile:
	ln -sf $(CURDIR)/profile.bash ~/.bash_profile

osx:
	ln -sf $(CURDIR)/osx/git-completion.bash ~/.git-completion.bash
	ln -sf $(CURDIR)/osx/osx.bash ~/.osx.bash
	brew install bash-completion
