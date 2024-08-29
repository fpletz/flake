{
  services.openssh = {
    enable = true;
    hostKeys = [
      # only ed25519 hostkey, no rsa
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        bits = 256;
      }
    ];
    sftpFlags = [
      "-f AUTHPRIV"
      "-l INFO"
    ];
    moduliFile = ../../static/ssh-moduli;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthOptions = "verify-required";
      # crypto hardening
      Ciphers = [ "chacha20-poly1305@openssh.com" ];
      KexAlgorithms = [ "curve25519-sha256@libssh.org" ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
      # no reverse dns
      UseDns = false;
    };
  };
}
