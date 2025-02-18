# overriding widget colors
widget color options with default values - sorted alphabetically:
```
set -g @ponokai-attached-clients-colors "blue black"
set -g @ponokai-battery-colors "red black"
set -g @ponokai-client-colors "yellow bg1"
set -g @ponokai-continuum-colors "blue black"
set -g @ponokai-cpu-usage-colors "orange black"
set -g @ponokai-custom-plugin-colors "blue black"
set -g @ponokai-cwd-colors "grey black"
set -g @ponokai-flag-colors "purple black"
set -g @ponokai-fossil-colors "green black"
set -g @ponokai-git-colors "green black"
set -g @ponokai-gpu-power-draw-colors "green black"
set -g @ponokai-gpu-ram-usage-colors "blue black"
set -g @ponokai-gpu-usage-colors "red black"
set -g @ponokai-hg-colors "green black"
set -g @ponokai-kubernetes-context-colors "blue black"
set -g @ponokai-libre-colors "fg0 bg2"
set -g @ponokai-message-colors "fg0 bg2"
set -g @ponokai-mpc-colors "green black"
set -g @ponokai-network-bandwidth-colors "blue black"
set -g @ponokai-network-colors "green black"
set -g @ponokai-network-ping-colors "blue black"
set -g @ponokai-network-vpn-colors "blue black"
set -g @ponokai-pane-border-colors "purple, grey"
set -g @ponokai-playerctl-colors "green black"
set -g @ponokai-powerline-colors "purple bg1"
set -g @ponokai-ram-usage-colors "blue black"
set -g @ponokai-spotify-tui-colors "green black"
set -g @ponokai-ssh-session-colors "green black"
set -g @ponokai-status-colors "fg0 bg1"
set -g @ponokai-synchronize-panes-colors "blue black"
set -g @ponokai-terraform-colors "purple black"
set -g @ponokai-time-colors "purple black"
set -g @ponokai-tmux-ram-usage-colors "blue black"
set -g @ponokai-weather-colors "blue black"
set -g @ponokai-window-status-colors "purple bg1"
```

# overriding color variables

all ponokai colors can be overridden and new variables can be added.
use the `set -g @ponokai-colors "color variables go here"` option. put each new variable on a new line for readability or all variables on one line to save space.

for a quick setup, add one of the following options to your config:
**better readability**
```
set -g @ponokai-colors "
# Ponokai Color Palette
black='#000000'
bg_dim='#252630'
bg0='#000000'
bg1='#1c1c1c'
bg2='#303030'
bg3='#444444'
bg4='#585858'
bg_red='#ffb3bd'
diff_red='#a67f82'
bg_green='#cbecb0'
diff_green='#818f80'
bg_blue='#b3e7f9'
diff_blue='#808d9f'
diff_yellow='#9c937a'
fg0='#f2f2f3'
red='#ff8c9a'
orange='#f3bb9a'
yellow='#f8e7b0'
green='#b4e49a'
blue='#98d4e7'
purple='#bdb2ff'
grey='#c4c6cf'
grey_dim='#9da1af'
"
```
**saving space**
```
set -g @ponokai-colors " black='#000000' bg_dim='#252630' bg0='#000000' bg1='#1c1c1c' bg2='#303030' bg3='#444444' bg4='#585858' bg_red='#ffb3bd' diff_red='#a67f82' bg_green='#cbecb0' diff_green='#818f80' bg_blue='#b3e7f9' diff_blue='#808d9f' diff_yellow='#9c937a' fg='#f2f2f3' red='#ff8c9a' orange='#f3bb9a' yellow='#f8e7b0' green='#b4e49a' blue='#98d4e7' purple='#bdb2ff' grey='#c4c6cf' grey_dim='#9da1af' "
```