# Class: gitolite::gl-setup
#
# This class executes gl-setup
#
# Parameters:
#
#   username: name of gitolite admin user
#   userkeysource: gitolite admin user public key source
#   userkeycontent: gitolite admin user public key content
#   refreshonly:
#
# Actions:
#
#   Runs gl-setup -q -q <public_ley_file>
#
# Requires:
#
#   class gitolite
#
# Sample Usage:
#
#   class {
#     "gitolite":
#       ...
#   }
#   class {
#     "gl-setup":
#       username => 'admin',
#       userkeycontent = 'ssh-rsa X76287hjashd873629o...',
#   }
#
# [Remember: No empty lines between comments and class definition]
class gitolite::gl-setup (
  $username,
  $userkeysource = undef,
  $userkeycontent = undef,
  $refreshonly = true,
) {
  Class['gitolite'] -> Class['gl-setup']

  file {
    "${gitolite::homedir}/${gl-setup::username}.pub":
      ensure  => "file",
      owner   => $gitolite::user,
      group   => $gitolite::user,
      source  => $gl-setup::userkeysource,
      content => $gl-setup::userkeycontent,
      mode    => 640,
  }

  exec {
    "gl-setup":
      require     => File["${gitolite::homedir}/${gl-setup::username}.pub"],
      subscribe   => File["${gitolite::homedir}/${gl-setup::username}.pub"],
      command     => "gl-setup -q -q ${gl-setup::username}.pub",
      environment => [
        "HOME=${gitolite::homedir}",
        "USER=${gitolite::user}",
      ],
      cwd         => $gitolite::homedir,
      user        => $gitolite::user,
      group       => $gitolite::user,
      logoutput   => "on_failure",
      path        => ["${gitolite::homedir}/bin", "/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      refreshonly => $gl-setup::refreshonly,
  }
}
#
# Copyright (C) 2012 Oleg Chunikhin <oleg.chunikhin@gmail.com>
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
