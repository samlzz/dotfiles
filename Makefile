STOW_DIR := $(CURDIR)
TARGET   := $(HOME)

# Répertoires non-stowés (séparés par des espaces)
EXCLUDE  := templates out_home

ALL_DIRS := $(patsubst %/,%,$(wildcard */))
PACKAGES := $(filter-out $(EXCLUDE),$(ALL_DIRS))

.DEFAULT_GOAL := help

.PHONY: all stow unstow restow stow-all unstow-all dry-run dry-run-all list help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

list: ## List available packages
	@echo "Available packages:"
	@for p in $(PACKAGES); do echo "  $$p"; done

stow: ## Stow one or more packages        →  make stow PKG="mysh git"
	@test -n "$(PKG)" || (echo "usage: make stow PKG=\"pkg1 pkg2\"" && exit 1)
	stow --dir=$(STOW_DIR) --target=$(TARGET) $(PKG)

unstow: ## Unstow one or more packages      →  make unstow PKG="mysh git"
	@test -n "$(PKG)" || (echo "usage: make unstow PKG=\"pkg1 pkg2\"" && exit 1)
	stow --dir=$(STOW_DIR) --target=$(TARGET) -D $(PKG)

restow: ## Re-symlink one or more packages  →  make restow PKG="mysh"
	@test -n "$(PKG)" || (echo "usage: make restow PKG=\"pkg1 pkg2\"" && exit 1)
	stow --dir=$(STOW_DIR) --target=$(TARGET) -R $(PKG)

dry-run: ## Simulate stow without applying   →  make dry-run PKG="mysh git"
	@test -n "$(PKG)" || (echo "usage: make dry-run PKG=\"pkg1 pkg2\"" && exit 1)
	stow --dir=$(STOW_DIR) --target=$(TARGET) -nv $(PKG)

stow-all: ## Stow all packages
	stow --dir=$(STOW_DIR) --target=$(TARGET) $(PACKAGES)

unstow-all: ## Unstow all packages
	stow --dir=$(STOW_DIR) --target=$(TARGET) -D $(PACKAGES)

dry-run-all: ## Simulate stow of all packages without applying
	stow --dir=$(STOW_DIR) --target=$(TARGET) -nv $(PACKAGES)
