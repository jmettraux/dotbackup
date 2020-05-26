
# dotbackup

scripts/scheme for tarsnap backup on OSX.

```sh
$ dotbackup

# ==>
#
# dotbackup -b / --backup
#   backs up the files and directories listed in /Users/jmettraux/.backup/targets.txt
# dotbackup -l / --list
#   lists the backup files, latest last
# dotbackup --delete {fname}
#   deletes a backup file
# dotbackup -t {fname}|last
#   lists the content of a backup file (or of the latest if 'last')
# dotbackup --last
#   outputs the name of the latest backup file
# dotbackup --extract [fname]|last|
#   extracts a given backup file or the latest if 'last' or none
```


## license

MIT (See [LICENSE.txt](LICENSE.txt)

