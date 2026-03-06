# Copilot Instructions — Arch Linux Setup Scripts

## Architecture

Three sequential execution phases, each with a different privilege context:

1. **boot/** — Run as root from the Arch live USB. Partitions disks (LUKS + LVM), installs the base system via `pacstrap`, generates `fstab`/`crypttab`.
2. **chroot/** — Run as root inside `arch-chroot /mnt`. Configures bootloader, locale, firewall, desktop (GNOME/GDM), drivers (NVIDIA), and enables systemd services.
3. **user/** — Run as the normal user after first boot. Installs applications, AUR packages, fonts, GNOME settings, and device support.

`common.sh` at the repo root defines shared constants (e.g., `USER_NAME`, `LUKS_NAME`, `VG_NAME`) and helper functions. Every script sources it via a relative path computed from `SCRIPT_DIR`.

## Script Conventions

- **Shebang + strict mode:** Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`. The sole exception is `user/packages/smart/notify.sh` (a smartd callback, not a setup script).
- **SCRIPT_DIR pattern:** Always declare and assign separately (SC2155) then source common.sh at the correct relative depth. The standard header idiom is `SCRIPT_DIR="$(dirname "$(realpath "${0}")")"`  followed by `SCRIPT_NAME="$(basename "${0}")"` and `readonly SCRIPT_DIR SCRIPT_NAME`:
  - 1 level: `. "${SCRIPT_DIR}/../common.sh"` (boot/, chroot/, user/)
  - 2 levels: `. "${SCRIPT_DIR}/../../common.sh"` (user/devices/, user/fonts/, user/packages/)
  - 3 levels: `. "${SCRIPT_DIR}/../../../common.sh"` (user/packages/visual-studio-code/)
- **Variables:** `readonly` is reserved for `SCRIPT_DIR` and `SCRIPT_NAME` (in each script header) and the shared constants in `common.sh`. All other variables use `lower_snake_case` without `readonly`.
- **Functions in common.sh:** Public API is `snake_case` (e.g., `pacman_install`, `die`). Internal helpers are `_prefixed` (e.g., `_pacman`).

## Aggregator install.sh Pattern

Subdirectory `install.sh` files aggregate modules using a dispatch loop:

```bash
configs=(module1 module2 module3)
for config in "${configs[@]}"; do
    config_path="${SCRIPT_DIR}/${config}.sh"
    if [[ ! -e "${config_path}" ]]; then
        config_path="${SCRIPT_DIR}/${config}/install.sh"
    fi
    "${config_path}"
done
```

This supports modules as either a single `foo.sh` or a `foo/install.sh` directory. New modules are added by creating the script and appending to the `configs` array in the parent `install.sh`.

## Package Management

| Action | Function | Context |
|---|---|---|
| Install official packages | `pacman_install pkg1 pkg2` | Any (auto-sudos) |
| Install AUR packages | `aur_install pkg` | User phase only (needs yay) |
| Remove package (force) | `pacman_remove pkg` | Swap conflicting packages |
| Remove package + deps | `pacman_remove_all pkg` | Clean unneeded defaults |
| Manual AUR build | `manual_aur_install <git_url>` | Bootstrap yay itself |
| Local PKGBUILD | `pushd dir && makepkg --noconfirm -sri && popd` | Custom font packages in `user/fonts/` |

Import GPG keys before AUR installs: `gpg_import_key <fingerprint>` (user keyring) or `pacman_import_key <fingerprint>` (pacman keyring).

## Config File Writing

- **Root file from root context:** `cat > /path <<EOF` (heredoc redirect)
- **Root file from user context:** `sudo tee /path > /dev/null <<'EOF'` (suppress echo)
- **Single line to root file:** `echo "line" | sudo tee -a /path > /dev/null`
- **User home file:** `cat > "${HOME}/.config/..." <<'EOF'`
- **Static file from repo:** `cp -f "${SCRIPT_DIR}/file" /destination`
- **In-place edit:** `sed -i 's/old/new/' /path` (often `sed` delete + `echo >>` append to replace a line)
- Use `<<'EOF'` (quoted) when no variable expansion is needed; `<<EOF` (unquoted) when expanding shell variables.

## Systemd Services

- **Chroot phase:** `systemctl enable <service>` (no `--now`; services can't start in chroot)
- **User phase:** `sudo systemctl enable --now <service>` (enable and start immediately)
- Custom units are created via heredocs written to `/etc/systemd/system/`.

## Error Handling

- `die "message"` for fatal errors with descriptive context.
- `warn "message"` for non-fatal warnings.
- Validate inputs early: check block device existence, partition existence, required arguments.
- Use `|| true` to suppress expected failures (e.g., `killall process || true`).
- Retry loops with `sleep 1s` for device nodes that appear asynchronously.
- Idempotency guards: `grep -q` checks before appending, `[[ ! -e ]]` before creating.
