{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.mobile.quirks.resize-rootfs;
in
{
  options.mobile.quirks.resize-rootfs = {
    enable = mkEnableOption ''
      resize-rootfs, which automatically expands the root filesystem
      to fill the entire partition on first boot.
      Only ext2/3/4 filesystems are supported.

      This is useful for Android system type devices where a small
      image is flashed to a large userdata partition
    '';
  };

  config = mkIf cfg.enable {
    systemd.services.resize-rootfs = {
      description = "Resize root filesystem to fill partition";
      after = [ "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      path = with pkgs; [
        e2fsprogs
        gawk
        util-linux
      ];

      script = ''
        set -euo pipefail

        # Skip if already resized
        if [ -f /var/lib/rootfs-resized ]; then
          echo "Root filesystem has already been resized, skipping."
          exit 0
        fi

        ROOT_DEV=$(findmnt -n -o SOURCE /)
        if [ -z "$ROOT_DEV" ]; then
          echo "Error: could not determine root device."
          exit 1
        fi
        echo "Root device: $ROOT_DEV"

        # Verify filesystem is ext2/3/4 before proceeding
        ROOT_FSTYPE=$(findmnt -n -o FSTYPE /)
        case "$ROOT_FSTYPE" in
          ext2|ext3|ext4) ;;
          *)
            echo "Error: root filesystem is $ROOT_FSTYPE, not ext2/3/4. Skipping resize."
            exit 1
            ;;
        esac

        # Current filesystem size
        BLOCK_COUNT=$(dumpe2fs -h "$ROOT_DEV" 2>/dev/null | awk -F: '/Block count/{gsub(/ /,"",$2); print $2}')
        BLOCK_SIZE=$(dumpe2fs -h "$ROOT_DEV" 2>/dev/null | awk -F: '/Block size/{gsub(/ /,"",$2); print $2}')
        if [ -z "$BLOCK_COUNT" ] || [ -z "$BLOCK_SIZE" ]; then
          echo "Error: could not determine filesystem size."
          exit 1
        fi
        FS_SIZE=$((BLOCK_COUNT * BLOCK_SIZE))
        echo "Current filesystem size: $FS_SIZE bytes"

        # Partition size
        PART_SIZE=$(blockdev --getsize64 "$ROOT_DEV")
        if [ -z "$PART_SIZE" ]; then
          echo "Error: could not determine partition size."
          exit 1
        fi
        echo "Partition size: $PART_SIZE bytes"

        # Resize if filesystem is more than 1% smaller than the partition
        DIFF=$((PART_SIZE - FS_SIZE))
        THRESHOLD=$((PART_SIZE / 100))
        if [ "$DIFF" -gt "$THRESHOLD" ]; then
          echo "Filesystem is smaller than partition by $DIFF bytes (threshold: $THRESHOLD). Resizing..."
          if ! resize2fs "$ROOT_DEV"; then
            echo "resize2fs failed, will retry on next boot."
            exit 1
          fi
          echo "Resize complete."
        else
          echo "Filesystem already fills the partition (difference: $DIFF bytes). No resize needed."
        fi

        # Mark as done — write to a temp file and rename for atomicity,
        # so a crash won't leave a half-written sentinel.
        touch /var/lib/.rootfs-resized.tmp
        mv /var/lib/.rootfs-resized.tmp /var/lib/rootfs-resized
        echo "Marked resize as complete."
      '';
    };
  };
}
