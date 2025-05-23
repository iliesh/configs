# Tmux Configuration Makefile
# Handles both user and system-wide tmux installations

# Variables
USER := $(shell whoami)
PRIMARY_GROUP := $(shell id -gn $(USER))
HOME_DIR := $(HOME)
TMUX_CONFIG_SRC := ./tmux/tmux.conf
TMUX_PLUGINS_SRC := ./tmux/plugins.tar
GLOBAL_CONFIG_DIR := /etc
GLOBAL_PLUGINS_DIR := /usr/local/share/tmux
USER_PLUGINS_DIR := $(HOME_DIR)/.tmux

# Define phony targets
.PHONY: help tmux tmux-user tmux-global clean-user clean-global clean install-user install-global check-deps

# Default target
help:
	@echo "Tmux Configuration Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  tmux         - Install tmux config for current user (default)"
	@echo "  tmux-user    - Install tmux config for current user"
	@echo "  tmux-global  - Install tmux config globally (requires sudo)"
	@echo "  clean-user   - Remove user tmux configuration"
	@echo "  clean-global - Remove global tmux configuration (requires sudo)"
	@echo "  clean        - Remove both user and global configurations"
	@echo "  check-deps   - Check if required files exist"
	@echo "  help         - Show this help message"

# Default target points to user installation
tmux: tmux-user

# Check if required source files exist
check-deps:
	@echo "Checking dependencies..."
	@test -f $(TMUX_CONFIG_SRC) || (echo "Warning: $(TMUX_CONFIG_SRC) not found" && exit 1)
	@test -f $(TMUX_PLUGINS_SRC) || (echo "Warning: $(TMUX_PLUGINS_SRC) not found" && exit 1)
	@echo "All dependencies found"

# User installation targets
install-user-config: check-deps
	@echo "Installing user tmux configuration..."
	@sed 's|set-environment -g TMUX_PLUGIN_MANAGER_PATH.*|set-environment -g TMUX_PLUGIN_MANAGER_PATH "$(USER_PLUGINS_DIR)"|g; s|run.*tpm.*|run "$(USER_PLUGINS_DIR)/tpm/tpm"|g' $(TMUX_CONFIG_SRC) > $(HOME_DIR)/.tmux.conf
	@chown $(USER):$(PRIMARY_GROUP) $(HOME_DIR)/.tmux.conf
	@chmod 644 $(HOME_DIR)/.tmux.conf
	@echo "User configuration installed"

install-user-plugins: check-deps
	@echo "Installing user tmux plugins..."
	@mkdir -p $(HOME_DIR)/.tmux
	@tar -xf $(TMUX_PLUGINS_SRC) -C $(HOME_DIR)/.tmux
	@chown -R $(USER):$(PRIMARY_GROUP) $(HOME_DIR)/.tmux
	@chmod -R 755 $(HOME_DIR)/.tmux
	@echo "User plugins installed"

tmux-user: install-user-config install-user-plugins
	@echo "User tmux installation complete!"

# Global installation targets (requires sudo)
install-global-config: check-deps
	@echo "Installing global tmux configuration..."
	@sed 's|set-environment -g TMUX_PLUGIN_MANAGER_PATH.*|set-environment -g TMUX_PLUGIN_MANAGER_PATH "$(GLOBAL_PLUGINS_DIR)/plugins"|g; s|run.*tpm.*|run "$(GLOBAL_PLUGINS_DIR)/plugins/tpm/tpm"|g' $(TMUX_CONFIG_SRC) | sudo tee $(GLOBAL_CONFIG_DIR)/tmux.conf > /dev/null
	@sudo chown root:root $(GLOBAL_CONFIG_DIR)/tmux.conf
	@sudo chmod 644 $(GLOBAL_CONFIG_DIR)/tmux.conf
	@echo "Global configuration installed"

install-global-plugins: check-deps
	@echo "Installing global tmux plugins..."
	@sudo mkdir -p $(GLOBAL_PLUGINS_DIR)
	@sudo tar -xf $(TMUX_PLUGINS_SRC) -C $(GLOBAL_PLUGINS_DIR)
	@sudo chown -R root:root $(GLOBAL_PLUGINS_DIR)
	@sudo chmod -R 755 $(GLOBAL_PLUGINS_DIR)
	@echo "Global plugins installed"

tmux-global: install-global-config install-global-plugins
	@echo "Global tmux installation complete!"

# Cleanup targets
clean-user:
	@echo "Removing user tmux configuration..."
	@rm -f $(HOME_DIR)/.tmux.conf
	@rm -rf $(HOME_DIR)/.tmux
	@echo "User configuration removed"

clean-global:
	@echo "Removing global tmux configuration..."
	@sudo rm -rf $(GLOBAL_CONFIG_DIR)/tmux.conf
	@sudo rm -rf $(GLOBAL_PLUGINS_DIR)
	@echo "Global configuration removed"

clean: clean-user clean-global
	@echo "All tmux configurations removed"