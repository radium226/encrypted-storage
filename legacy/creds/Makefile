SHELL := bash
.SHELLFLAGS := -euEo pipefail -c

.ONESHELL:


.PHONY: install-key
install-key:
	@ echo "Install: " >&2
	trap 'echo KO >&2' ERR

	mkdir -p "/etc/systemd/system/mnt-TEST.mount.d"
	echo "[Mount]" >"/etc/systemd/system/mnt-TEST.mount.d/key.conf"
	systemd-creds encrypt --name="key" --pretty "./TEST.key" - >>"/etc/systemd/system/mnt-TEST.mount.d/key.conf"
	systemctl daemon-reload