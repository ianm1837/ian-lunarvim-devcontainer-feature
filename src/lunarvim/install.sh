#!/bin/bash
set -e

# Load option values from devcontainer-feature.json
CONFIG_REPO=${_REMOTE_USER_CONFIG_repo:-"https://github.com/YOUR_USERNAME/YOUR_LVIM_CONFIG.git"}

echo "Installing system dependencies..."
sudo apt update && sudo apt install -y \
  curl git unzip tar xz-utils \
  build-essential python3 python3-pip python3-venv \
  ripgrep fd-find nodejs npm \
  clang clangd clang-format \
  cargo g++ make cmake \
  bat fzf jq

# Install Neovim manually
echo "Fetching latest Neovim release..."
LATEST_NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
NVIM_TARBALL="nvim-linux64.tar.gz"

echo "Downloading Neovim version $LATEST_NVIM_VERSION..."
curl -LO "https://github.com/neovim/neovim/releases/download/${LATEST_NVIM_VERSION}/${NVIM_TARBALL}"

echo "Extracting Neovim..."
tar xzf $NVIM_TARBALL
sudo mv nvim-linux64 /opt/nvim

# Symlink to make `nvim` available system-wide
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# Verify installation
nvim --version

# Install Node.js for LSPs, Treesitter, and DAP
echo "Ensuring latest Node.js version..."
curl -fsSL https://fnm.vercel.app/install | bash
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"
fnm install --lts
fnm use --lts
npm install -g yarn typescript typescript-language-server pyright eslint prettier

# Install Python dependencies
echo "Setting up Python environment..."
pip3 install --upgrade pip
pip3 install pynvim black flake8 isort

# Install LunarVim
echo "Installing LunarVim..."
LV_BRANCH='release-1.3/neovim-0.9'
LVIM_DIR="$HOME/.local/share/lunarvim"
bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/$LV_BRANCH/utils/installer/install.sh) --yes

# Clone user's LunarVim config
echo "Setting up LunarVim config..."
if [ -d "$HOME/.config/lvim" ]; then
  rm -rf "$HOME/.config/lvim"
fi
git clone "$CONFIG_REPO" "$HOME/.config/lvim"

# Ensure LunarVim dependencies are installed
echo "Running LunarVim sync..."
export PATH="/opt/nvim/bin:$PATH"
lvim --headless +LvimSyncCorePlugins +qall

# Install LazyVim
echo "Installing LazyVim..."
mkdir -p ~/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Install LazyDocker
echo "Installing LazyDocker..."
curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | \
  jq -r '.assets[] | select(.name | contains("Linux_x86_64")) | .browser_download_url' | \
  xargs curl -Lo lazydocker.tar.gz

tar -xzf lazydocker.tar.gz lazydocker
sudo mv lazydocker /usr/local/bin/lazydocker
rm lazydocker.tar.gz

# Verify LazyDocker installation
lazydocker --version

echo "Installation complete! You now have LunarVim, LazyVim, and LazyDocker ready to use."
