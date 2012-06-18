# Class: gitolite
#
# This module installs gitolite and performs initial configuration.
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
#   nonrootinstallmethod: allows installing gitolite in non-root mode (default false)
#     Different gitolite installation modes are described at
#     http://sitaramc.github.com/gitolite/g2/install.html#install_installing_and_upgrading_gitolite_
#     *NOTE* when using non-root install method set homedir to /home/...
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
  $packages = true,
  $nonrootinstallmethod = false
) {

  $bashpkg = $operatingsystem ? {
    /(?i:redhat|centos|fedora)/ => "bash",
    /(?i:debian|ubuntu)/        => "bash",
    default                     => "bash"
  }
  $gitpkg = $operatingsystem ? {
    /(?i:redhat|centos|fedora)/ => "git",
    /(?i:debian|ubuntu)/        => "git-core",
    default                     => "git"
  }
  $perlpkg = $operatingsystem ? {
    /(?i:redhat|centos|fedora)/ => "perl",
    /(?i:debian|ubuntu)/        => "perl",
    default                     => "perl"
  }
  $sshpkg = $operatingsystem ? {
    /(?i:redhat|centos|fedora)/ => "openssh-clients",
    /(?i:debian|ubuntu)/        => "openssh-client",
    default                     => "ssh-client"
  }

  $srcdir = $gitolite::nonrootinstallmethod ? {
    true  => "${gitolite::homedir}/gitolite",
    default => "/usr/src/gitolite"
  }

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
      provider => "git",
      ensure   => "present",
      source   => "http://github.com/sitaramc/gitolite.git",
      revision => $gitolite::version,
      owner    => $gitolite::nonrootinstallmethod ? { true  => $gitolite::user, default => "root" },
      group    => $gitolite::nonrootinstallmethod ? { true  => $gitolite::user, default => "root" },
      require  => [
        Package[$gitolite::gitpkg,$gitolite::perlpkg],
        User[$gitolite::user],
        File[$gitolite::homedir]
      ];
  }

  exec {
    "gl-system-install":
      require     => Vcsrepo[$gitolite::srcdir],
      command     => $gitolite::nonrootinstallmethod ? {
        true => "${gitolite::srcdir}/src/gl-system-install ${gitolite::homedir}/bin ${gitolite::homedir}/share/conf ${gitolite::homedir}/share/hooks",
        default => "${gitolite::srcdir}/src/gl-system-install /usr/bin ${gitolite::homedir}/conf ${gitolite::homedir}/hooks",
      },
      cwd         => $gitolite::srcdir,
      user        => $gitolite::nonrootinstallmethod ? { true => $gitolite::user, default => "root" },
      group       => $gitolite::nonrootinstallmethod ? { true => $gitolite::user, default => "root" },
      logoutput   => "on_failure",
      subscribe   => Vcsrepo[$gitolite::srcdir],
      path        => ["${gitolite::homedir}/bin", "/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      refreshonly => true;
  }
}
#
# Copyright (C) 2012 Steve Huff <steve_huff@harvard.edu>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
