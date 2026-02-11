{
  lib,
  stdenv,
  buildLinux,
  fetchFromGitLab,
  ...
}:

let
  suffix = "xanmod1";
  modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
  version = "6.18.10";
  hash = "sha256-bYKYx9ctHuWG+WS/Wtt4p2uW6vy2g5ikLqSPWeNeSn0=";
in
buildLinux {
  inherit version modDirVersion;

  src = fetchFromGitLab {
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

      # Preemptive Full Tickless Kernel at 1000Hz
      HZ = freeform "1000";
      HZ_250 = no;
      HZ_1000 = yes;

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
      GENERIC_CPU = yes;
      X86_64_VERSION = freeform "3";
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
      HAMRADIO = lib.modules.mkForce no;
      AX25 = lib.modules.mkForce unset;
      WWAN = no;
      ISDN = no;
      NET_DSA = no;
      WINESYNC = unset;
      DVB_CORE = no;
      MCB = no;
      FUSION = lib.modules.mkForce no;
      TARGET_CORE = no;
      POWER_SEQUENCING = no;
      RC_CORE = lib.modules.mkForce no;
      MEDIA_CEC_RC = lib.modules.mkForce unset;
      MEDIA_CRC_RC = lib.modules.mkForce unset;
      LIRC = lib.modules.mkForce unset;
      AGP = lib.modules.mkForce no;
      # big scsi modules
      SCSI_LPFC = no;
      SCSI_BFA_FC = no;
      SCSI_QLA_ISCSI = no;
      SCSI_QLA_FC = no;
      MEGARAID_NEWGEN = lib.modules.mkForce no;
      MEGARAID_LEGACY = no;
      MEGARAID_SAS = no;
      SCSI_MPT3SAS = no;
      SCSI_MPT2SAS = no;
      SCSI_MPI3MR = no;
      SCSI_AACRAID = no;
      SCSI_AIC7XXX = no;
      SCSI_AIC79XX = no;
      SCSI_AIC94XX = no;
      SCSI_CXGB3_ISCSI = no;
      SCSI_CXGB4_ISCSI = no;
      AIC79XX_DEBUG_ENABLE = lib.modules.mkForce unset;
      AIC7XXX_DEBUG_ENABLE = lib.modules.mkForce unset;
      AIC94XX_DEBUG = lib.modules.mkForce unset;
    };

  extraMeta = {
    branch = lib.versions.majorMinor version;
  };
}
