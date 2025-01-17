# Use the current logged-in user
USER = $(shell whoami)
PRIMARY_GROUP = $(id -gn ${USER})

# Define phony targets
.PHONY: tmux_config tmux_plugins_dir tmux

# Target to copy the configuration file
tmux_config:
	cp ./tmux/tmux.conf ${HOME}/.tmux.conf
	chown $(USER):$(PRIMARY_GROUP) ${HOME}/.tmux.conf
	chmod 0640 ${HOME}/.tmux.conf

# Target to create the plugins directory
tmux_plugins_dir:
	mkdir -p ${HOME}/.tmux
	tar -xf ./tmux/plugins.tar -C ${HOME}/.tmux
	chown $(USER):$(PRIMARY_GROUP) ${HOME}/.tmux
	chmod 0750 ${HOME}/.tmux

# All-in-one target to run all the tasks
tmux: tmux_config tmux_plugins_dir
