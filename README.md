# Mono

Minimal prompt. I removed command duration because I feel it's unnecessary. So
now it's slightly more minimal.


## Install

With [fisherman]

```fish
fisher pvsr/mono
```

## Features

* Git
    * Clean
    * Dirty / Touched
    * Staged
    * Staged + Dirty
    * Stashed
    * Unpushed commits (ahead)
    * Unpulled commits (behind)
    * Unpulled and unpushed commits (diverged)
    * Detached HEAD
    * Branch name
* $status
* $VIRTUAL_ENV
* $status in context
* Background jobs
* Superpowers (sudo)
* Host information

[fisherman]: https://github.com/fisherman/fisherman
