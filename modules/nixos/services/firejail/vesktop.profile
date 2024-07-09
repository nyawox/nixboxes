# Firejail profile for discord
# This file is overwritten after every install/update
# Persistent local customizations
include discord.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/vesktop

mkdir ${HOME}/.config/vesktop
whitelist ${HOME}/.config/vesktop

private-bin discord,Discord
private-opt discord,Discord

# Redirect
include discord-common.profile
