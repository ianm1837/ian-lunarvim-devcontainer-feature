# LunarVim DevContainer Feature

This feature installs Neovim, LunarVim, and my (minimal) custom LunarVim configuration inside a DevContainer.

## Usage

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/ianm1837/ian-lunarvim-devcontainer-feature/lunarvim:1": {
      "config_repo": "https://github.com/YOUR_USERNAME/YOUR_LVIM_CONFIG.git"
    }
  }
}
