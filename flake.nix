{
  description = "Flake to build GHDL from upstream source with gnat-bootstrap14";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ghdl-src = {
      url = "github:ghdl/ghdl";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ghdl-src,
    }:
    let
      systems = [
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          pname = "ghdl";
          version = "git";

          src = ghdl-src;

          nativeBuildInputs = with pkgs; [
            git
            cmake
            gcc
            llvm
            wget
            gnumake
            automake
            zlib
            gnat-bootstrap14
            python3
          ];

          configurePhase = ''
            export GHDL_BACKEND=llvm
            export CC=${pkgs.gcc}/bin/gcc
            export CXX=${pkgs.gcc}/bin/g++

            ./configure --prefix=$out --with-llvm-config --enable-libghdl

          '';

          buildPhase = ''
            make
          '';

          installPhase = ''
            make install
          '';
        };
      });
    };
}
