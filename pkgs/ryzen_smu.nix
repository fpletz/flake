{
  lib,
  stdenv,
  fetchFromGitLab,
  kernel,
  kmod,
}:

let
  makeCmd = ''
    make \
      -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      ${lib.escapeShellArgs kernel.makeFlags} \
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ryzen_smu";
  version = "0.1.5";

  src = fetchFromGitLab {
    owner = "leogx9r";
    repo = "ryzen_smu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-n4uWikGg0Kcki/TvV4BiRO3/VE5M6/KopPncj5RQFAQ=";
  };

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  hardeningDisable = [
    "format"
    "pic"
  ];

  buildPhase = ''
    runHook preBuild
    ${makeCmd} modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preBuild
    install -vDt $out/lib/modules/${kernel.modDirVersion}/misc ryzen_smu.ko
    runHook postBuild
  '';

  meta = {
    description = "Linux kernel driver to acess SMU for certain AMD Ryzen Processors";
    homepage = "https://gitlab.com/leogx9r/ryzen_smu";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
  };
})
