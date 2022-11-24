{lib, pkgs, ...}:

#move this away?
let
    myPython = pkgs.python310.withPackages (p: with p; [
    ]);
in
{
    home.packages = [
        myPython
    ];
}
