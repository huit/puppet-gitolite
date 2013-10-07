# Class: gitolite::rc
#
# This class configures the gitolite.rc file
#
# Parameters:
# umask: set the UMASK variable for Gitolite
# git_config_keys: set the GIT_CONFIG_KEYS variable for Gitolite
# log_extra: set the LOG_EXTRA variable for Gitolite
# roles: set the ROLES array for Gitolite
# pre_create: set the PRE_CREATE array for Gitolite
# post_create: set the POST_CREATE array for Gitolite
# post_compile: set the POST_COMPILE array for Gitolite
#
# Actions:
# - Configures the .gitolite.rc file in the gitolite system user home directory
#
class gitolite::rc(
  $umask           = $gitolite::params::umask,
  $git_config_keys = $gitolite::params::git_config_keys,
  $log_extra       = $gitolite::params::log_extra,
  $roles           = $gitolite::params::roles,
  $pre_create      = $gitolite::params::pre_create,
  $post_create     = $gitolite::params::post_create,
  $post_compile    = $gitolite::params::post_compile,
) inherits gitolite::params {
  
  file { "${gitolite::homedir}/.gitolite.rc":
    ensure  => file,
    owner   => $gitolite::user,
    group   => $gitolite::user,
    content => template('gitolite/gitolite3.rc.erb'),
    mode    => '644',
  }
}
