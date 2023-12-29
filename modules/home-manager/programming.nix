{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    #Rust
    cargo
    rustc
    rust-analyzer
    rustfmt
    #Nix
    nixd
    alejandra
  ];
}
