# Use the current logged-in user
USER = $(shell whoami)
PRIMARY_GROUP = $(id -gn ${USER})

# Define phony targets
.PHONY: tmux_config tmux_plugins_dir tmux

# Target to copy the configuration file
tmux_config:
	cp ./tmux/tmux.conf /home/$(USER)/.tmux.conf
	chown $(USER):$(PRIMARY_GROUP) /home/$(USER)/.tmux.conf
	chmod 0640 /home/$(USER)/.tmux.conf

# Target to create the plugins directory
tmux_plugins_dir:
	mkdir -p /home/$(USER)/.tmux
	tar -xf ./tmux/plugins.tar -C /home/$(USER)/.tmux
	chown $(USER):$(PRIMARY_GROUP) /home/$(USER)/.tmux
	chmod 0750 /home/$(USER)/.tmux

# All-in-one target to run all the tasks
tmux: tmux_config tmux_plugins_dir
