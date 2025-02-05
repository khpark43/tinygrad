{
  description = "auto updating tinygrad overlay";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.python3.withPackages (ps: [
              ps.tqdm
              ps.numpy
              ps.sentencepiece
              ps.tiktoken
              ps.torch
              ps.hypothesis
              ps.pytest
              ps.mypy
              ps.jax
              ps.librosa
            ]))
            pkgs.clang
            pkgs.cudaPackages.cuda_nvcc
            pkgs.cudaPackages.cuda_cudart
            pkgs.cudaPackages.cuda_nvrtc
            pkgs.cudaPackages.cudatoolkit
            pkgs.glibc
            pkgs.ocl-icd
            pkgs.linuxPackages.nvidia_x11
          ];

          # Python packages you want to include in the environment
          shellHook = ''
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.cudaPackages.cuda_nvrtc.lib}/lib:${pkgs.cudaPackages.cuda_cudart.stubs}/lib:${pkgs.cudaPackages.cudatoolkit}
            export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH:${pkgs.linuxPackages.nvidia_x11}/lib
            export PYTHONPATH=.
            echo "Python environment activated!"
          '';
        };
      }
    );
}
