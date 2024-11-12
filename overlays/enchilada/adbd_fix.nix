final: prev: {
  libhybris = prev.libhybris.overrideAttrs {
    #TODO: this is actually read (checked with a bad hardening flag)
    hardeningDisable = ["zerocallusedregs"];
    #NOTE: https://github.com/NixOS/nixpkgs/issues/101979#issuecomment-2322846044
    #NIX_HARDENING_ENABLE="";
    NIX_DEBUG = "1";
  };
}
