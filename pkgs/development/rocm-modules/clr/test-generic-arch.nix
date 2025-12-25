{
  lib,
  stdenv,
  makeImpureTest,
  fetchFromGitHub,
  clr,
  rocm-smi,
}:

let

  examples = stdenv.mkDerivation {
    pname = "rocm-hip-examples";
    version = "2024-04-11";

    src = fetchFromGitHub {
      owner = "ROCm";
      repo = "HIP-Examples";
      rev = "cdf9d101acd9a3fc89ee750f73c1f1958cbd5cc3";
      hash = lib.fakeHash;
    };

    nativeBuildInputs = [
      clr
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      amdclang++ -x hip -o $out/bin/vectoradd \
        --offload-arch=gfx9-generic \
        --offload-arch=gfx10-1-generic \
        --offload-arch=gfx10-3-generic \
        --offload-arch=gfx11-generic \
        --offload-arch=gfx12-generic \
        vectorAdd/vectoradd_hip.cpp

      runHook postInstall
    '';

    meta = {
      description = "Example programs for ROCm HIP ";
      homepage = "https://github.com/ROCm/HIP-Examples";
      # TODO: what???
      # license = lib.licenses.bsd2;
      platforms = lib.platforms.linux;
      teams = [ lib.teams.rocm ];
    };
  };

in
makeImpureTest {
  name = "hip-example-generic-arch";
  testedPackage = "rocmPackages.clr";

  sandboxPaths = [
    "/sys"
    "/dev/dri"
    "/dev/kfd"
  ];

  nativeBuildInputs = [ examples rocm-smi ];

  testScript = ''
    rocm-smi

    vectoradd
  '';

  meta = {
    teams = [ lib.teams.rocm ];
  };
}
