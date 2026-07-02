{ config, lib, ... }:

{
  # Note: for f2fs, create it with "sudo mkfs.f2fs -l root -i -O extra_attr,flexible_inline_xattr,inode_checksum,sb_checksum,compression,lost_found /dev/sdxY"
  fileSystems."/".options = lib.mkMerge [
    [ "noatime" ]
    (lib.mkIf (config.fileSystems."/".fsType == "f2fs") (lib.mkAfter [
      "discard" # Better (on f2fs) than fstrim
      "X-fstrim.notrim" # To avoid fstrim
      "compress_algorithm=lzo-rle"
      "compress_extension=*"
      #"nocompress_extension=avif,bmp,gif,heic,heif,ico,jpe,jpeg,jpg,png,svg,tif,tiff,webp,3gp,avi,flv,m4v,mkv,mov,mp4,mpeg,mpg,webm,wmv,aac,flac,m4a,mid,midi,mp3,ogg,opus,wav,wma,7z,bz2,gz,rar,tar,tgz,xz,zip,zst,docx,odt,odp,ods,pptx,xlsx,pdf,db,gpg,key,p12,pem,sqlite,sqlite3,enc,aab,apk,appimage,bin,deb,dll,elf,exe,jar,so,rpm,img,iso,qcow2,vdi,vhd,vmdk,otf,ttf,class,dump,log,swp,tmp,bak,cache,part,old,new,core"
      "compress_chksum"
      "atgc"
      "gc_merge"
      "checkpoint=enable"
      "checkpoint_merge"
      "fsync_mode=posix"
      "nat_bits"
    ]))
  ];

  services.fstrim.enable = true;

  boot.tmp = {
    useTmpfs = true; # I'll need to disable this or make it bigger if nix builds fail because of it
  };

  # Link to nix-hardware configs in case I get a new laptop some day:
  # https://github.com/NixOS/nixos-hardware
}