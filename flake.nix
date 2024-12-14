{
  description = "A simple Rust project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        projectName = "my-rust-project";
      in {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo
            rust-analyzer
            rustfmt
            clippy
          ];

          shellHook = ''
            echo "Rust development environment"
            echo "Rust version: $(rustc --version)"
          '';
        };

        # Build package
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = projectName;
          version = "0.1.0";
          
          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          meta = with pkgs.lib; {
            description = "A simple Rust project";
            homepage = "https://github.com/jameslzhu/${projectName}";
            license = licenses.mit;
            platforms = platforms.unix;
          };
        };

        # Optional: default app for running the project
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${projectName}";
        };
      }
    );
}
