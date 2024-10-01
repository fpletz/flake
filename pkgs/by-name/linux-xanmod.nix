{
  lib,
  stdenv,
  buildLinux,
  fetchFromGitHub,
  ...
}:

let
  suffix = "xanmod1";
  modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
  version = "6.11.1";
  hash = "sha256-Wev7qAJ0U4AtE8WTJpNGK63WVhcTBD5oPVKcZDTwJXQ=";
in
buildLinux {
  inherit version modDirVersion;

  src = fetchFromGitHub {
    owner = "xanmod";
    repo = "linux";
    rev = modDirVersion;
    inherit hash;
  };

  structuredExtraConfig =
    let
      inherit (lib.kernel)
        yes
        no
        freeform
        unset
        ;
    in
    {
      # Google's BBRv3 TCP congestion Control
      TCP_CONG_BBR = yes;
      DEFAULT_BBR = yes;

      # Preemptive Full Tickless Kernel at 250Hz
      HZ = freeform "250";
      HZ_250 = yes;
      HZ_1000 = no;

      RCU_EXPERT = yes;
      RCU_FANOUT = freeform "64";
      RCU_FANOUT_LEAF = freeform "16";
      RCU_BOOST = yes;
      RCU_BOOST_DELAY = freeform "0";
      RCU_EXP_KTHREAD = yes;

      # Full preemption
      PREEMPT = lib.mkOverride 60 yes;
      PREEMPT_VOLUNTARY = lib.mkOverride 60 no;

      # x86-64-v3 psABI
      GENERIC_CPU3 = yes;
      MODULE_COMPRESS_XZ = lib.modules.mkForce no;
      MODULE_COMPRESS_ZSTD = yes;
      PERF_EVENTS_AMD_POWER = yes;

      # diff to xanmod
      FW_LOADER_COMPRESS_ZSTD = yes;
      WATCH_QUEUE = yes;
      UCLAMP_TASK = yes;
      UCLAMP_BUCKETS_COUNT = freeform "5";
      UCLAMP_TASK_GROUP = yes;
      MTRR_SANITIZER_ENABLE_DEFAULT = freeform "1";
      ADDRESS_MASKING = yes;
      ENERGY_MODEL = yes;
      WQ_POWER_EFFICIENT_DEFAULT = yes;
      CPU_FREQ_STAT = yes;
      CPU_IDLE_GOV_LADDER = yes;
      CPU_IDLE_GOV_TEO = yes;
      ARCH_MMAP_RND_BITS = if stdenv.hostPlatform.isx86_64 then freeform "32" else freeform "18";
      ARCH_MMAP_RND_COMPAT_BITS = freeform "16";
      RANDOMIZE_KSTACK_OFFSET_DEFAULT = yes;
      NET_IPGRE_BROADCAST = yes;
      XFRM_ESPINTCP = yes;
      INET_ESPINTCP = yes;
      INET6_ESPINTCP = yes;
      IPV6_SIT_6RD = yes;
      IPV6_IOAM6_LWTUNNEL = yes;

      # for CRIU
      MEM_SOFT_DIRTY = yes;

      # disable unneeded features
      BATMAN_ADV = no;
      INFINIBAND = lib.modules.mkForce no;
      INFINIBAND_IPOIB = lib.modules.mkForce unset;
      INFINIBAND_IPOIB_CM = lib.modules.mkForce unset;
      PCCARD = no;
      SCSI_LOWLEVEL_PCMCIA = lib.modules.mkForce unset;
      MOST = no;
      SIOX = no;
      IPACK_BUS = no;
      GREYBUS = no;
      XEN = lib.modules.mkForce no;
      CAN = no;
      AFS_FS = no;
      AF_RXRPC = no;
      CAIF = no;
      PARPORT = no;
      MEMSTICK = no;
      COMEDI = no;
      USB_GSPCA = no;
      IIO = no;
      HAMRADIO = no;
      WWAN = no;
      ISDN = no;
      SCSI_LPFC = no;
      TCM_QLA2XXX = no;
      SCSI_BFA_FC = no;
      SCSI_QLA_ISCSI = no;
      NET_DSA = no;
      WINESYNC = unset;
    };

  extraMeta = {
    branch = lib.versions.majorMinor version;
  };
}
