{
  description = "Clang Template KPI exam";

  inputs = {
    nixpkgs_stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = { self, nixpkgs_stable, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs_stable { system = system; };

          llvm = pkgs.llvmPackages_13;

          packages = with pkgs; [
            # XXX: the order of include matters
            pkgs.clang-tools
            llvm.clang # clangd

            # debugger
            llvm.lldb
          ];
        in
        rec {
          devShell = pkgs.mkShell {
            nativeBuildInputs = [ pkgs.pkg-config ];
            packages = packages;

            CPATH = builtins.concatStringsSep ":" [
              (pkgs.lib.makeSearchPathOutput "dev" "include" ([ llvm.libcxx llvm.libcxxabi ]))
              (pkgs.lib.makeSearchPath "resource-root/include" ([ llvm.clang ]))
            ];
          };

          defaultPackage = llvm.stdenv.mkDerivation rec {
            pname = "Clang Template";
            version = "0.1.1";

            src = ./.;

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = packages;

            sconsFlags = "";

            enableParallelBuilding = true;
          };
        }
      );
}
