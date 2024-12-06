{
  lib,
  stdenv,
  fetchgit,
  fetchpatch,
  perl536,
  pve-common,
  authenpam,
}:

let
  perlDeps = with perl536.pkgs; [
    authenpam
    pve-common
  ];

  perlEnv = perl536.withPackages (_: perlDeps);
in

perl536.pkgs.toPerlModule (
  stdenv.mkDerivation rec {
    pname = "pve-access-control";
    version = "8.2.0";

    src = fetchgit {
      url = "git://git.proxmox.com/git/${pname}.git";
      rev = "de84a7894b61de8fce49539a853c3dd7d5154028";
      hash = "sha256-jnq/VDRRN5l+D94FDGUdwEcmT8v7ZPVru3RvuWGHeP0=";
    };

    sourceRoot = "${src.name}/src";
    patches = [
      (fetchpatch {
        url = "https://github.com/5aaee9/pve-access-control/commit/c83f84937e448ce49885c5dca62c045a2a240919.patch";
        sha256 = "sha256-u/do86YzXVNQlRYIr6SNEWDYx+SUJeMrrtFlnaqPA8s=";
        stripLen = 1;
      })
    ];

    postPatch = ''
      sed -i Makefile \
        -e "s/pveum.1 oathkeygen pveum.bash-completion pveum.zsh-completion/oathkeygen/" \
        -e "/pveum.1/,+2d"
    '';

    buildInputs = [ perlEnv ];
    propagatedBuildInputs = perlDeps;
    dontPatchShebangs = true;

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX="
      "SBINDIR=/.bin"
      "BINDIR=/.bin"
      "PERLDIR=/${perl536.libPrefix}/${perl536.version}"
    ];

    passthru.updateScript = [
      ../update.py
      pname
      "--url"
      src.url
    ];

    meta = with lib; {
      description = "Proxmox VE Access control framework";
      homepage = "git://git.proxmox.com/?p=pve-access-control.git";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [
        camillemndn
        julienmalka
      ];
      platforms = platforms.linux;
    };
  }
)
