ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
TARGETS := $(wildcard .??*)
IGNORES := .git .gitignore
FILES := $(filter-out $(IGNORES), $(TARGETS))
INITFILES := $(wildcard $(ROOT)/etc/init/*.sh)

help:
	@echo "make help   => Show this messages"
	@echo "make list   => Show dotfiles in this repository"
	@echo "make init   => Setup environment settings"
	@echo "make deploy => Create symbolic link to home directory"
	@echo "make clean  => Remove dotfiles to home directory, and this repository"

list:
	@$(foreach val, $(FILES), ls -dF $(val);)

deploy:
	@echo "### Start to deploy dotfiles to home directory ###"
	@echo ''
	@$(foreach val, $(FILES), ln -snfv $(abspath $(val)) $(HOME)/$(val);)

init:
	@echo "### Start to init environment settings ###"
	@echo ''
	@$(foreach val, $(INITFILES), sh $(val);)

clean:
	@echo "### Remove dotfiles to home directory, and this repository ###"
	@echo ''
	@-$(foreach val, $(FILES), rm -vrf $(HOME)/$(val);)
	-rm -fr $(ROOT)
