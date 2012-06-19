# Class: gitolite::gl-setup
#
# This class executes gl-setup
#
# Parameters:
#
#   user: name of gitolite admin user
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
#       user    => 'admin',
#       homedir => '/home/admin',
#       userkeycontent = 'ssh-rsa X76287hjashd873629o...',
#   }
#
# [Remember: No empty lines between comments and class definition]
class gitolite::gl-setup (
  $user,
  $homedir,
  $userkeysource = undef,
  $userkeycontent = undef,
  $refreshonly = true
) {
  Class["gitolite"] -> Class["gitolite::gl-setup"]

  file {
    "${gitolite::homedir}/${gl-setup::user}.pub":
      ensure  => "file",
      owner   => $gitolite::gl-setup::user,
      group   => $gitolite::gl-setup::user,
      source  => $gitolite::gl-setup::userkeysource,
      content => $gitolite::gl-setup::userkeycontent,
      mode    => 640;
  }

  exec {
    "gl-setup":
      require     => File["${gitolite::gl-setup::homedir}/${gitolite::gl-setup::user}.pub"],
      subscribe   => File["${gitolite::gl-setup::homedir}/${gitolite::gl-setup::user}.pub"],
      command     => "gl-setup -q -q ${gl-setup::user}.pub",
      environment => [
        "HOME=${gitolite::gl-setup::homedir}",
        "USER=${gitolite::gl-setup::user}",
      ],
      cwd         => $gitolite::gl-setup::homedir,
      user        => $gitolite::gl-setup::user,
      group       => $gitolite::gl-setup::user,
      logoutput   => "on_failure",
      path        => ["${gitolite::gl-setup::homedir}/bin", "/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      refreshonly => $gitolite::gl-setup::refreshonly;
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
