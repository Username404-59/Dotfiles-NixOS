{ config, lib, pkgs, ... }:

let
  hashingForce = "1s"; # Makes my password more secure (however it will probably take more time to login 😐)

  migrateScript = pkgs.writeShellApplication {
    name = "fscrypt-migrate-homes";

    runtimeInputs = [
      pkgs.fscrypt-experimental
      pkgs.rsync
      pkgs.coreutils
      pkgs.getent
      pkgs.systemd
      pkgs.pamtester
      pkgs.findutils
    ];

    text = ''
      if [[ ! -d /.fscrypt ]] || [[ ! -f /etc/fscrypt.conf ]]; then
        rm -f /etc/fscrypt.conf # Just in case only my /.fscrypt isn't present
        fscrypt setup --force --quiet --time=${hashingForce}
        echo "fscrypt setup completed."
      else
        echo "fscrypt setup already done, skipping."
      fi

      # Find all real user homes (UID in 1000..1100, not system users)
      while IFS=: read -r _ _ uid _ _ homedir _; do
        # Skip system users / users without a valid home
        if [[ "$uid" -lt 1000 || "$uid" -gt 1100 || ! -d "$homedir" ]]; then
          continue
        fi

        echo "Checking $homedir ..."

        # If it's already encrypted, skip. fscrypt status exits with error code if the directory is not encrypted.
        if fscrypt status --quiet "$homedir" 2>/dev/null; then
          echo "  $homedir is already encrypted, skipping."
          continue
        fi

        echo "  $homedir is NOT encrypted. Password required."

        # 1. Read original permissions and owner
        orig_perm=$(stat -c %a "$homedir")
        orig_uid=$(stat -c %u "$homedir")
        orig_gid=$(stat -c %g "$homedir")
        orig_user=$(stat -c %U "$homedir")

        # 2. Ask user password
        user_password=""

        if ! user_password=$(systemd-ask-password --no-tty --timeout=0 --icon="dialog-password" -n "Enter password for user $orig_user to encrypt their home:"); then
          echo "Password prompt cancelled." >&2
          exit 1
        fi

        # Verify it is the right password
        if ! printf '%s' "$user_password" | pamtester login "$orig_user" authenticate 2>/dev/null; then
          echo "Incorrect password." >&2
          exit 1
        fi

        # 3. Rename to .bak
        mv "$homedir" "$homedir.bak"

        # 4. Create new empty directory with exact same permissions
        mkdir "$homedir"
        chown "$orig_uid":"$orig_gid" "$homedir"
        chmod "$orig_perm" "$homedir"

        rm -rf "''${homedir:?}/*" # Just in case

        # 5. Encrypt it
        echo "$user_password" | fscrypt encrypt \
          --source=pam_passphrase \
          --user="$orig_user" \
          "$homedir"

        unset user_password

        # 6. Copy everything back with full preservation
        rsync -axHAX "''${homedir}.bak/" "''${homedir}/"

        # 7. Verify it worked, then remove backup
        if fscrypt status --quiet "$homedir" 2>/dev/null; then
          echo "  Migration successful for $homedir; removing backup."
          find "''${homedir}.bak" -type f -print0 | xargs -0 shred -n1 --remove=unlink
          rm -rf "''${homedir}.bak"
          fscrypt lock --user="$orig_user" "$homedir"
        else
          echo "  ERROR: $homedir does not appear encrypted after migration!"
          echo "  Backup remains at $homedir.bak — manual intervention required."
          exit 1
        fi
      done < <(getent passwd)
    '';
  };

in {
  security.pam.enableFscrypt = true;

  systemd.services.fscrypt-migrate = {
    description = "Migrate unencrypted home directories to fscrypt";
    after = [ "local-fs.target" "systemd-ask-password-plymouth.service" "plymouth-start.service" ];
    before = [ "plymouth-quit.service" "plymouth-quit-wait.service" ];
    wants = [ "systemd-ask-password-plymouth.service" "plymouth-start.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${migrateScript}/bin/${migrateScript.name}";
      RemainAfterExit = true;
      User = "root";
      TimeoutSec = "infinity";
    };
    restartIfChanged = false;
    reloadIfChanged = false;
    unitConfig.ConditionKernelCommandLine = "fscrypt_migration"; # To avoid running it from first boot
  };

  boot.kernelParams = [ config.systemd.services.fscrypt-migrate.unitConfig.ConditionKernelCommandLine ];
}
