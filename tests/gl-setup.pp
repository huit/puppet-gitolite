class {
  "gitolite":
    user     => "gitolite",
    password => "3858f62230ac3c915f300c664312c63f";
  "gitolite::gl-setup":
    user    => $gitolite::user,
    homedir => $gitolite::homedir;
}
