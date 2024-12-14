{
  description = "A simple Rust project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShell.${system} = pkgs.mkShell {
        buildInputs = with pkgs; [
          rustc
          cargo
        ];
      };

      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "roflcat";
        version = "0.1.0";
        
        src = ./.;

        cargoLock = {
          lockFile = ./Cargo.lock;
        };
      };
    };
}
