local terminal                   = "foot"
local fileManager                = "thunar"
local menu                       = "rofi -show drun"
local browser                    = "firefox"
local discord                    = "vesktop"
local steam                      = "steam"
local prism_launcher             = "prismlauncher"
local obsidian                   = "obsidian"
local calculator                 = terminal .. " -e bc -lq"
local resourceMonitor            = terminal .. " -e btop"
local bandwhich                  = terminal .. " -e bandwhich"

local clipboardHistory           = "cliphist list | rofi -dmenu | cliphist decode | wl-copy"
local emojiSelector              = "rofi -modi emoji -show emoji -emoji-mode copy"
local nerdEmojiSelector          = "rofi -modi nerdy -show nerdy"
local zalgoText                  = config_dir .. "/modules/home/rofi/zalgo.sh"
local hyprpicker                 = "hyprpicker -a -f hex -l"

local screenshotSelection        = "grimblast -nf copy area"
local screenshotSelectionSwappy  = 'GRIMBLAST_EDITOR="swappy -f " grimblast -nf edit area'
local screenshotFullscreen       = "grimblast -nf copy screen"
local screenshotFullscreenSwappy = 'GRIMBLAST_EDITOR="swappy -f " grimblast -nf edit screen'
