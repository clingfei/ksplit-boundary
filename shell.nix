let
  sources = import nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
pkgs.stdenv.mkDerivation {
  name = "ksplit-boundary";
  buildInputs = with pkgs; [
    llvmPackages_10.libllvm.dev
    clang_10
    #llvmPackages_10.llvm.lib
  ];
}
