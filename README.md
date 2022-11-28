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
* offer to copy `complete.occ` to `/etc/bash_completion.d` if both exist, then
  ensure correct owner (`root:root`) and permissions (`0644`) are applied

<br />
<br />
<del>Finally, the user needs to run the following commands:</del>

<br />

<br />

The following is now taken care of by `bash-add-alias.sh`:

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


### Examples

An example of the script in action, showing user interaction required before any action taken:

```
# . ./bash-add-alias.sh
Web server user name: "www-data".
Alias for occ command not found for user "root".
Run "alias occ='sudo --user www-data php /var/www/nextcloud/occ'" (y/N)? Y
alias occ='sudo --user www-data php /var/www/nextcloud/occ'
Add alias to /root/.bash_aliases? (y/N) N
Add alias to /home/ron/.bash_aliases? (y/N) N
Run bash completion script complete.occ?  (Y/n) Y
Running /var/www/nextcloud/complete.occ ... success.
Add complete.occ to /etc/bash_completion.d? (y/N) N
DONE.
```



Works from any folder, even when `occ` is not in the current directory:

```
root@(dell):/tmp/nextcloud-occ-bash-completion# occ
activity:        encryption:      memories:        text:
app:             federation:      notification:    theming:
background:      files:           onlyoffice:      trashbin:
background-job:  group:           preview:         twofactorauth:
broadcast:       help             recognize:       update:
check            integrity:       security:        upgrade
circles:         l10n:            serverinfo:      user:
config:          list             sharing:         versions:
dav:             log:             status           workflows:
db:              maintenance:     tag:
deck:            maps:            talk:
root@(dell):/tmp/nextcloud-occ-bash-completion# occ
```

Reduce number of choices by typing `ta`:
```
root@(dell):/tmp/nextcloud-occ-bash-completion# occ ta
tag:   talk:
root@(dell):/tmp/nextcloud-occ-bash-completion# occ ta
```

Increase choices by typing `l`, which completes to `talk:`, then provides all `talk:` options:
```
root@(dell):/tmp/nextcloud-occ-bash-completion# occ talk:
talk:active-calls         talk:room:delete          talk:stun:add
talk:command:add          talk:room:demote          talk:stun:delete
talk:command:add-samples  talk:room:promote         talk:stun:list
talk:command:delete       talk:room:remove          talk:turn:add
talk:command:list         talk:room:update          talk:turn:delete
talk:command:update       talk:signaling:add        talk:turn:list
talk:room:add             talk:signaling:delete     talk:user:remove
talk:room:create          talk:signaling:list
root@(dell):/tmp/nextcloud-occ-bash-completion# occ talk:
```

And so on:
```
root@(dell):/tmp/nextcloud-occ-bash-completion# occ talk:command:
talk:command:add          talk:command:delete       talk:command:update
talk:command:add-samples  talk:command:list
root@(dell):/tmp/nextcloud-occ-bash-completion# occ talk:command:list
```



Works with options beginning with `-` too, if user types in `occ -`[TAB]:
```
root@(dell):/tmp/nextcloud-occ-bash-completion# occ -
--ansi            --no-ansi         --quiet           --version
-h                --no-interaction  -v                -vv
--help            --no-warnings     -V                -vvv
-n                -q                --verbose
root@(dell):/tmp/nextcloud-occ-bash-completion# occ -
```
