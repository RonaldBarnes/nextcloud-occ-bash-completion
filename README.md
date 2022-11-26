# nextcloud-occ-bash-completion
### Tab completion for NextCloud's occ script, with alias for occ.

For bash tab completion to work, `bash-completion` package is required (`apt install bash-completion`)

Furthermore, an alias is needed for `occ`: the `bash-add-alias.sh` script will:
* find location of `occ` if not in current directory
  * use readline to offer tab-completion on the path input
* create a valid alias and offer to run it in the terminal
* offer to add the alias to the user's `.bash_aliases` file
* offer to add the alias to the  `SUDO_USER`'s `.bash_aliases` file, when relevant
* verify that `occ` is owned by the web server user that it found


Finally, the user needs to run the following commands:
```
chown -v root: complete.occ
chmod -v 0644 complete.occ
cp -v ./complete.occ /etc/bash_completion.d/
. /etc/bash_completion.d/complete.occ
```


Once the alias has been created, the completion will
* present all valid switches (starting with "`-`") if `-` is the first character of a word
* present all commands up to and including the first colon (`:`)
* once a command has been chosen, remaining `TAB`s will present all subcommands

