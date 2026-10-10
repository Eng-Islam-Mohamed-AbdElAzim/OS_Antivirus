# Simple Antivirus Daemon

A small bash project for the OS lab. One script watches a folder and moves
suspicious files into a quarantine folder. Another script lets you look through
the quarantined files and either restore them or delete them for good.

## Files

```
.
├── antivirusd.sh    - the antivirus, checks the folder every 5 seconds
├── restore.sh       - lets you restore or delete quarantined files
├── Menu.sh          - small menu to start either script
├── Makefile         - shortcuts for running everything
├── test_dir/        - the folder being watched
└── malicious_dir/   - where flagged files get moved
```

`test_dir` and `malicious_dir` are created automatically by the Makefile.
While the antivirus runs it also creates `directory-info.last` and
`directory-info.new`, which it uses to notice when the folder changes.

## What counts as malicious

A file is flagged if either of these is true:

- its extension is `exe`, `bat`, `vbs`, `scr` or `ps1`
- it contains one of the words `virus`, `trojan`, `malware`, `worm` or
  `ransomware` (upper or lower case doesn't matter)

Both lists are at the top of `antivirusd.sh`, in the variables
`malicious_ex` (extensions) and `malicious_key` (keywords).

The watched folder should only contain files, no subfolders.

## Requirements

Just a Linux terminal with bash and make. On Ubuntu, bash is already there, and
make can be installed with:

```bash
sudo apt update
sudo apt install make
```

## How to run it

Start the antivirus:

```bash
make antivirus
```

It keeps running until you stop it with Ctrl+C. To try it out, open a second
terminal in the same folder and add some files:

```bash
echo "hello" > test_dir/safe.txt
echo "hello" > test_dir/bad.exe
echo "this has a virus" > test_dir/note.txt
```

Within a few seconds the antivirus prints that `bad.exe` and `note.txt` are
malicious and deleted. They get copied to `malicious_dir` and removed from
`test_dir`. `safe.txt` is left alone.

Then stop the antivirus with Ctrl+C and start the restore tool (the two should
not run at the same time):

```bash
make restore
```

It lists the files in `malicious_dir` with numbers. Type a number to pick a
file, or 0 to exit. After picking a file you choose:

1. Restore it back to `test_dir` (it was flagged by mistake)
2. Delete it permanently
3. Leave it and go back to the list

If `malicious_dir` is empty, it just says there are no malicious files to
review.

## How it detects changes

When it starts, the antivirus scans the folder once and saves the output of
`ls -l` to `directory-info.last`. Every 5 seconds it saves a new listing to
`directory-info.new` and compares the two. If they are the same, nothing
happens. If they are different, it scans the folder again and updates
`directory-info.last`.