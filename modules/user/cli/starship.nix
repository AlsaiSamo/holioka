{
  config,
  lib,
  pkgs,
  secrets,
  userName,
  ...
}: let
  cfg = config._hlk_auto.cli;
in {
  config = lib.mkIf (cfg.starship.enable) {
    programs.starship = {
      enable = true;
      settings = {
        format = lib.concatStrings [
          "$directory"
          "$status"
          "$character"
        ];
        right_format = lib.concatStrings [
          "$nix_shell"
          "$docker_context"
          "$username$hostname"
        ];
        add_newline = false;
        #TODO: doesn't show multiline prompt (not even the default one) (on fish)
        #continuation_prompt = "[██](bright-black)  ";
        status = {
          disabled = false;
          format = "[$symbol$status]($style) ";
          pipestatus = true;
          pipestatus_format = "\\[$pipestatus\\] ";
          pipestatus_segment_format = "[$symbol$status]($style)";
        };
        nix_shell.format = "[$symbol$state( \($name\))]($style) ";
        directory = {
          truncation_length = 7;
          truncation_symbol = "… /";
        };
      };
    };
  };
}
