#default params for gitolite module and it's classes
class gitolite::params {
  $password         = 'undef'
  $user             = "gitolite"
  $homedir          = "/var/gitolite"
  $source           = "http://github.com/sitaramc/gitolite.git"
  $version          = "v3.1"
  $packages         = true
  $nonrootinstallmethod = false
  $rcfile           = false
  $umask            = '0077'
  $git_config_keys  = ''
  $log_extra        = '1'
  $roles            = ['READERS',
                       'WRITERS']
  $pre_create       = []
  $post_create      = ['post-compile/update-git-configs',
                       'post-compile/update-gitweb-access-list',
                       'post-compile/update-git-daemon-access-list']
  $post_compile     = ['post-compile/ssh-authkeys',
                       'post-compile/update-git-configs',
                       'post-compile/update-gitweb-access-list',
                       'post-compile/update-git-daemon-access-list']
}
