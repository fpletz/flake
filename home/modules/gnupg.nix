{ lib, config, ... }:
{
  options.bpletza.workstation.gnupg = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.bpletza.workstation.gnupg {
    programs.gpg = {
      enable = true;
      settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = [
          "show-uid-validity"
          "show-unusable-subkeys"
        ];
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        with-key-origin = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        armor = true;
        use-agent = true;
        keyserver = "hkps://keys.gnupg.net";
        auto-key-locate = "wkd,dane,local";
        auto-key-retrieve = true;
      };
    };
  };
}
