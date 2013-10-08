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
* `nonrootinstallmethod`
  allows installing gitolite in non-root mode (default false)
  Different gitolite installation modes are described at
  http://sitaramc.github.com/gitolite/g2/install.html#install_installing_and_upgrading_gitolite_
  *NOTE* when using non-root install method set homedir to /home/...
* `keycontent`
  the public key that should have access to gitolite-admin when first configured
* `rcfile`
  configure .gitolite.rc file in gitolite mgmt user homedir
* `umask`
  set the UMASK variable for gitolite.rc
* `git_config_keys`
  set the GIT_CONFIG_KEYS variable for gitolite.rc
* `log_extra`
  set the LOG_EXTRA variable for gitolite.rc
* `roles`
  set the ROLES array for gitolite.rc
* `pre_create`
  set the PRE_CREATE array for gitolite.rc
* `post_create`
  set the POST_CREATE array for gitolite.rc
* `post_compile`
  set the POST_COMPILE array for gitolite.rc

## Actions:

* Installs packages to satisfy requirements
* Creates source directory (`/usr/src/gitolite`) and checks out Gitolite repo
* Creates gitolite management user (local system user) if necessary
* Runs gitolite/install
* Runs gitolite <public key>

## Requires:

* POSIX-compliant `sh` (attempts to install bash)
* `git` (must be v1.6.6 or later)
* `perl` (must be 5.8 or later)
* `ssh` (client)
* Puppetlabs\vcsrepo

## Sample Usage:

    class {
      "gitolite":
        ;
    }
