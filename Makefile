BLACK := \033[0;30m
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
MAGENTA := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
END := \033[0m

INFO := $(BLUE)
WARN := $(YELLOW)
ERROR := $(RED)

log = @echo "$(INFO)$(1)$(END)"
err = @>&2 echo "$(ERROR)$(1)$(END)"
done = $(call log,"Done!")
run = @$(1) || (n=$$?; >&2 echo "$(ERROR)Failed!$(END)"; exit $$n)

### ZDOTDIR

define ZDOTDIR
export ZDOTDIR="$$HOME/.config/zsh"
endef

export ZDOTDIR
/etc/zshenv:
ifneq ($(ZDOTDIR), "$$HOME/.config/zsh")
	$(call err,"ZDOTDIR misconfigured!")
	$(call log,"Configuring ZDOTDIR...")
	$(call run,echo "$$ZDOTDIR" | sudo tee -a $@ > /dev/null)
	$(call done)
endif

### mkdirs

~/.%:
	$(call log,"Creating dir $@...")
	@mkdir -p $@

### laserwave

~/.local/share/laserwave:
	$(call err,"laserwave not found!")
	$(call log,"Installing laserwave...")
	$(call run,git clone https://github.com/lettertwo/laserwave.nvim.git $@)
	$(call done)

.PHONY: update-laserwave
update-laserwave: ~/.local/share/laserwave
	$(call log,"Updating laserwave...")
	$(call run,cd ~/.local/share/laserwave && git pull)
	$(call done)

### homebrew

BREW := $(shell command -v brew 2> /dev/null)

.PHONY: brew
brew:
ifndef BREW
	$(call err,"brew not found!")
	$(call log,"Installing brew...")
	$(call run,curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
	$(call done)
endif

.PHONY: update-brew
update-brew: brew
	$(call log,"Updating brew bundle...")
	$(call run,brew bundle)
	$(call log,"Cleaning up...")
	$(call run,brew cleanup)
	$(call done)

### sheldon

SHELDON := $(shell command -v sheldon 2> /dev/null)

.PHONY: sheldon
sheldon: brew
ifndef SHELDON
	$(call err,"sheldon not found!")
	$(call log,"Installing sheldon...")
	$(call run,brew install sheldon)
	$(call done)
endif

.PHONY: update-sheldon
update-sheldon: sheldon
	$(call log,"Updating sheldon plugins...")
	$(call run,sheldon lock)
	$(call done)

### neovim + lunarvim

NVIM := $(shell command -v nvim 2> /dev/null)
LVIM := $(shell command -v lvim 2> /dev/null)

.PHONY: nvim
nvim: brew
ifndef NVIM
	$(call err,"nvim not found!")
	$(call log,"Installing neovim...")
	$(call run,brew install --HEAD neovim)
	$(call done)
endif

.PHONY: update-nvim
update-nvim: nvim
	$(call log,"Updating neovim...")
	$(call run,brew reinstall neovim)
	$(call done)

.PHONY: lvim
export LV_BRANCH=rolling
lvim: nvim
ifndef LVIM
	$(call err,"lvim not found!")
	$(call log,"Installing lvim...")
	$(call run,curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/rolling/utils/installer/install.sh | zsh)
	$(call done)
endif

.PHONY: update-lvim
LVIM_OUT := $(shell mktemp)
update-lvim: update-nvim lvim
	$(call log,"Updating LunarVim...")
	$(call run,lvim +LvimUpdate +q)
	$(call log,"Updating Plugins...")
	$(call run,lvim +'autocmd User PackerComplete sleep 100m | write! ${LVIM_OUT} | qall' +PackerUpdate ; cat ${LVIM_OUT} | rg -v 'Press')
	$(call log,"Syncing Core Plugins...")
	$(call run,lvim +'autocmd User PackerComplete sleep 100m | write! ${LVIM_OUT} | qall' +LvimSyncCorePlugins ; cat ${LVIM_OUT} | rg -v 'Press')
	$(call done)

### kitty

KITTY := $(shell command -v kitty 2> /dev/null)

.PHONY: kitty
kitty:
ifndef KITTY
	$(call err,"kitty not found!")
	$(call log,"Installing kitty...")
	$(call run,curl -L https://sw.kovidgoyal.net/kitty/installer.sh | zsh /dev/stdin)
	$(call run,ln -sf /Applications/kitty.app/Contents/MacOS/kitty "$$HOME/.local/bin/kitty")
	$(call done)
endif


.PHONY: update-kitty
update-kitty:
ifndef KITTY
	$(call err,"kitty not found!")
	$(call log,"Installing kitty...")
else
	$(call log,"Updating kitty...")
endif
	$(call run,curl -L https://sw.kovidgoyal.net/kitty/installer.sh | zsh /dev/stdin)
	$(call run,ln -sf /Applications/kitty.app/Contents/MacOS/kitty "$$HOME/.local/bin/kitty")
	$(call done)

### config

.PHONY: update-config
update-config:
	$(call log,"Updating config...")
	$(call run,git pull)
	$(call done)

.PHONY: mkdirs
mkdirs: ~/.cache/zsh ~/.local/share ~/.local/state/zsh/completions

.PHONY: install
install: mkdirs /etc/zshenv ~/.local/share/laserwave brew sheldon lvim kitty
	@echo "Run $(BLUE)make update$(END) to fetch the latest stuff."

.PHONY: update
update: update-config update-laserwave update-brew update-sheldon update-lvim update-kitty
