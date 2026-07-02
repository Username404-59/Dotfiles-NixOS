# nix-env --install disko
{
  disko.devices = {
    disk = {
      my-disk = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1024M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              type = "swap";
              size = "32G";
              discardPolicy = "once"; # Better than having "pages" because I'm not gonna keep my computer running for 200 days
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                mountpoint = "/";
                format = "f2fs";
                mountOptions = [
                  "defaults"
                  "discard"
                  "X-fstrim.notrim"
                  "compress_algorithm=lzo-rle"
                  "compress_extension=*"
                  "compress_chksum"
                  "atgc"
                  "gc_merge"
                  "checkpoint=enable"
                  "checkpoint_merge"
                  "fsync_mode=posix"
                  "nat_bits"
                ];
              };
            };
          };
        };
      };
    };
  };
}