{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:
buildGoModule rec {
  pname = "systemd-lock-handler";
  version = "2.4.2";

  src = fetchFromSourcehut {
    owner = "~whynothugo";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-sTVAabwWtyvHuDp/+8FKNbfej1x/egoa9z1jLIMJuBg=";
  };

  vendorHash = "sha256-dWzojV3tDA5lLdpAQNC9NaADGyvV7dNOS3x8mfgNNtA=";

  postInstall = ''
    install -vD -m 0444 -t $out/lib/systemd/user \
      systemd-lock-handler.service \
      lock.target \
      sleep.target \
      unlock.target
  '';

  meta = with lib; {
    description = "Translates systemd-system lock/sleep signals into systemd-user target activations";
    homepage = "https://git.sr.ht/~whynothugo/systemd-lock-handler";
    license = with licenses; [ isc ];
    maintainers = with lib; [ fpletz ];
    platforms = platforms.linux;
  };
}
