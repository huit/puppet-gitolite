# Class: gitolite
#
# This module manages gitolite
#
# Parameters:
#
#   user: name of gitolite management user (default "gitolite")
#   password: HASHED (not plain-text) password of gitolite management user
#   homedir: home directory of gitolite management user
#     *NOTE* repositories are hosted here
#   version: release tag of desired Gitolite version (default "v2.3")
#     can accept version strings, git hashes, or other branches/tags
#   packages: set this to false if you want to define the necessary packages elsewhere
#
# Actions:
#
#   Installs packages to satisfy requirements
#   Creates source directory (/usr/src/gitolite) and checks out Gitolite repo
#   Creates gitolite management user (local system user)
#   Runs gl-system-install command
#
# Requires:
#
#   POSIX-compliant sh (attempts to install bash)
#   git (must be v1.6.6 or later)
#   perl (must be 5.8 or later)
#   ssh (client)
#
# Sample Usage:
#
#   class {
#     "gitolite":
#       password => '$1$oqINGwwF$yTik.GEYoKJtEHJBzt/.01';
#   }
#
# [Remember: No empty lines between comments and class definition]
class gitolite (
  $user = "gitolite",
  $password,
  $homedir = "/var/gitolite",
  $version = "v2.3",
  $packages = true
) {

  $bashpkg = $operatingsystem ? {
    /(redhat|centos|fedora)/ => "bash",
    /(debian|ubuntu)/        => "bash",
    default                  => "bash"
  }
  $gitpkg = $operatingsystem ? {
    /(redhat|centos|fedora)/ => "git",
    /(debian|ubuntu)/        => "git-core",
    default                  => "git"
  }
  $perlpkg = $operatingsystem ? {
    /(redhat|centos|fedora)/ => "perl",
    /(debian|ubuntu)/        => "perl",
    default                  => "perl"
  }
  $sshpkg = $operatingsystem ? {
    /(redhat|centos|fedora)/ => "openssh-clients",
    /(debian|ubuntu)/        => "openssh-client",
    default                  => "ssh-client"
  }

  $srcdir = "/usr/src/gitolite"

  if $packages {
    Package {
      ensure => "present"
    }

    package {
      $gitolite::bashpkg:
        ;
      $gitolite::gitpkg:
        require => Package[$gitolite::sshpkg];
      $gitolite::perlpkg:
        require => Package[$gitolite::bashpkg];
      $gitolite::sshpkg:
        require => Package[$gitolite::bashpkg];
    }
  }

  group {
    $gitolite::user:
      ensure => "present";
  }


  user {
    $gitolite::user:
      require  => Group[$gitolite::user],
      ensure   => "present",
      comment  => "Gitolite Hosting",
      gid      => "gitolite",
      home     => $gitolite::homedir,
      password => $gitolite::password,
      system   => true;
  }

  file {
    $gitolite::homedir:
      require => User[$gitolite::user],
      ensure  => "directory",
      owner   => $gitolite::user,
      group   => $gitolite::user,
      mode    => 750;
  }

  vcsrepo {
    $gitolite::srcdir:
      ensure   => "present",
      source   => "git://github.com/sitaramc/gitolite.git",
      revision => $gitolite::version,
      require  => [
        Package[$gitolite::gitpkg,$gitolite::perlpkg],
        User[$gitolite::user],
        File[$gitolite::homedir]
      ],
      notify => Exec["gl-system-install"];
  }

  exec {
    "gl-system-install":
      require     => Vcsrepo[$gitolite::srcdir],
      command     => "./src/gl-system-install /usr/bin ${gitolite::homedir}/conf ${gitolite::homedir}/hooks",
      cwd         => $gitolite::srcdir,
      user        => "root",
      group       => "root",
      logoutput   => "on_failure",
      creates     => "${gitolite::homedir}/conf",
      refreshonly => true;
  }
}
