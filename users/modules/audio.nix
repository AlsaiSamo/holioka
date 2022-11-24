{lib, pkgs, ...}:

{
    home.persistence."/state/home/imikoy" = {
        directories = [
            ".local/state/wireplumber"
        ];
    };
}
