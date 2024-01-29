{ lib, fetchFromGitHub, buildLinux, kernelPatches, ... }:

let
  mainVariant = {
    version = "6.7.2";
    hash = "sha256-nY7C3Qt5slxafvyVGtTf0celPF+W9MepL6MjsnPzTXg=";
  };

  xanmodKernelFor = { version, suffix ? "xanmod1", hash }:
    let
      modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
    in
    buildLinux {
      inherit version modDirVersion;

      src = fetchFromGitHub {
        owner = "xanmod";
        repo = "linux";
        rev = modDirVersion;
        inherit hash;
      };

      kernelPatches = [
        kernelPatches.bridge_stp_helper
        kernelPatches.request_key_helper
      ];

      structuredExtraConfig = with lib.kernel; {
        # Google's BBRv3 TCP congestion Control
        TCP_CONG_BBR = yes;
        DEFAULT_BBR = yes;

        # WineSync driver for fast kernel-backed Wine
        WINESYNC = module;

        # Preemptive Full Tickless Kernel at 250Hz
        HZ = freeform "250";
        HZ_250 = yes;
        HZ_1000 = no;

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
        SLS = yes;
        ENERGY_MODEL = yes;
        WQ_POWER_EFFICIENT_DEFAULT = yes;
        CPU_FREQ_STAT = yes;
        CPU_IDLE_GOV_LADDER = yes;
        CPU_IDLE_GOV_TEO = yes;
        ARCH_MMAP_RND_BITS = freeform "32";
        ARCH_MMAP_RND_COMPAT_BITS = freeform "16";
        RANDOMIZE_KSTACK_OFFSET_DEFAULT = yes;
        NET_IPGRE_BROADCAST = yes;
        XFRM_ESPINTCP = yes;
        INET_ESPINTCP = yes;
        INET6_ESPINTCP = yes;
        IPV6_SIT_6RD = yes;
        IPV6_IOAM6_LWTUNNEL = yes;
        BPFILTER = yes;
        BPFILTER_UMH = module;

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
      };

      extraMeta = {
        branch = lib.versions.majorMinor version;
        description = "Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
      };
    };
in
xanmodKernelFor mainVariant
