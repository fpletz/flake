{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    openFirewall = true;
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
      Ciphers = [
        "chacha20-poly1305@openssh.com"
      ];
      KexAlgorithms = [
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
      # no reverse dns
      UseDns = false;
    };
  };

  programs.ssh = {
    ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
    ];
    kexAlgorithms = [
      "sntrup761x25519-sha512@openssh.com"
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group-exchange-sha256"
    ];
    hostKeyAlgorithms = [
      "ssh-ed25519-cert-v01@openssh.com"
      "ssh-ed25519"
      "sk-ssh-ed25519-cert-v01@openssh.com"
      "sk-ssh-ed25519@openssh.com"
      "ssh-rsa-cert-v01@openssh.com"
      "ssh-rsa"
    ];
    macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
      "umac-128@openssh.com"
    ];
  };
}
