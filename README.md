# ElementRPG

ElementRPG is an game mod for [Soldat](https://www.soldat.pl/) where players
can level up and acquire abilities to enhance their combat abilities.

If you just want to play it on a public server, join:
`soldat://dickson.io:23073/`

# Installation

1. Copy or symlink the `scripts/ElementRPG/` directory into the `scripts/`
   directory of your server. Your server's scripts directory should contain
   the `ElementRPG` directory itself rather than its contents.

2. Configure your server's `server.ini` file to allow the scripts to access the
   server's top level directory. Players data are saved to the
   `data/ElementRPG/` directory from the server's directory.
   * Edit `server.ini`
   * Under `[ScriptCore3]` section, set `Sandboxed=1`

3. (Optional) Install the included weapons mod. This weapons mod radically
   changes the behavior of all weapons in the game. ElementRPG is balanced
   around this weapons mod. It is recommended to use it if you want to
   experience ElementRPG as it is intended.
   * Copy `weapons.ini` into the top level directory of your server

# Support

If you need help setting up your own server, join the [Official Soldat
Discord](https://discordapp.com/invite/soldat)
