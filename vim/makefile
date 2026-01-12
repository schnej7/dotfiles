all: base plugins

base:
	mkdir -p ~/.vim
	ln -sf $(CURDIR)/vimrc ~/.vimrc

plugins:
	rm -rf ~/.vim/pack
	ln -sf $(CURDIR)/pack ~/.vim/pack
