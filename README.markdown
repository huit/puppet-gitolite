# gitolite

This module automatically installs [gitolite](http://sitaramc.github.com/gitolite) and performs initial configuration.  At present, it supports Red Hat-like and Debian-like platforms.

**NOTE**: you must generate the SSH public key for the management user yourself (either with your own Puppet manifest, or manually) and install it before gitolite will work properly.  See the [documentation](http://sitaramc.github.com/gitolite/root.html).

## Parameters:

* `user`  
  name of gitolite management user (default "gitolite")  
* `password`  
  HASHED (not plain-text) password of gitolite management user  
* `homedir`  
  home directory of gitolite management user  
  **NOTE** repositories are hosted here  
* `version`  
  release tag of desired Gitolite version (default "v3.1")  
  can accept version strings, git hashes, or other branches/tags  
* `packages`  
  boolean value that determines whether this module will define the necessary package resources  
  set this to `false` if you want to define them elsewhere in your manifests

## Actions:

* Installs packages to satisfy requirements
* Creates source directory (`/usr/src/gitolite`) and checks out Gitolite repo
* Creates gitolite management user (local system user) if necessary
* Runs `gl-system-install` command if necessary

## Requires:

* POSIX-compliant `sh` (attempts to install bash)
* `git` (must be v1.6.6 or later)
* `perl` (must be 5.8 or later)
* `ssh` (client)

## Sample Usage:

    class {
      "gitolite":
        ;
    }
