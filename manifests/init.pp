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
#   version: release tag of desired Gitolite version (default "v3.03")
#     can accept version strings, git hashes, or other branches/tags
#   packages: set this to false if you want to define the necessary packages elsewhere
#   nonrootinstallmethod: allows installing gitolite in non-root mode (default false)
#     Different gitolite installation modes are described at
#     http://sitaramc.github.com/gitolite/g2/install.html#install_installing_and_upgrading_gitolite_
#     *NOTE* when using non-root install method set homedir to /home/...
#   keycontent: the public key that should have access to gitolite-admin when first configured
#
# Actions:
#
#   Installs packages to satisfy requirements (optional)
#   Creates source directory (/usr/src/gitolite) and checks out Gitolite repo
#   Creates gitolite management user (local system user, optional)
#   Runs gitolite/install
#   Runs gitolite <public key>
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
#       ;
#   }
#
# [Remember: No empty lines between comments and class definition]
class gitolite (
  $keycontent,
  $password = 'undef',
  $user = "gitolite",
  $homedir = "/var/gitolite",
  $source = "http://github.com/sitaramc/gitolite.git",
  $version = "v3.1",
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
      ensure => "present",
      before => Vcsrepo[$gitolite::srcdir],
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

  if $gitolite::password != 'undef'{
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
  }

  vcsrepo {
    $gitolite::srcdir:
      provider => "git",
      ensure   => "present",
      source   => $gitolite::source,
      revision => $gitolite::version,
      owner    => $gitolite::nonrootinstallmethod ? { true  => $gitolite::user, default => "root" },
      group    => $gitolite::nonrootinstallmethod ? { true  => $gitolite::user, default => "root" },
  }

  file { "${gitolite::homedir}/${gitolite::user}.pub":
    ensure  => file,
    owner   => $gitolite::user,
    group   => $gitolite::user,
    content => $gitolite::keycontent,
    mode    => '0640',
    require => User[$gitolite::user],
  }

  exec {
    "gitolite/install":
      require     => Vcsrepo[$gitolite::srcdir],
      command     => $gitolite::nonrootinstallmethod ? {
        true => "${gitolite::srcdir}/install ${gitolite::homedir}/bin",
        default => "${gitolite::srcdir}/install -ln /usr/local/bin",
      },
      cwd         => $gitolite::srcdir,
      user        => $gitolite::nonrootinstallmethod ? { true => $gitolite::user, default => "root" },
      group       => $gitolite::nonrootinstallmethod ? { true => $gitolite::user, default => "root" },
      logoutput   => "on_failure",
      subscribe   => Vcsrepo[$gitolite::srcdir],
      path        => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      refreshonly => true;
  }

  exec { 'gitolite_setup':
    require     => [
      File["${gitolite::homedir}/${gitolite::user}.pub"],
      Vcsrepo[$gitolite::srcdir],
      Exec['gitolite/install']
    ],
    environment => [
      "HOME=${gitolite::homedir}",
      "USER=${gitolite::user}",
    ],
    subscribe   => File["${gitolite::homedir}/${gitolite::user}.pub"],
    command     => "gitolite setup -pk ${gitolite::user}.pub",
    cwd         => $gitolite::homedir,
    user        => $gitolite::user,
    group       => $gitolite::user,
    logoutput   => 'on_failure',
    path        => ["${gitolite::homedir}/bin", '/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
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
