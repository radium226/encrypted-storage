SHELL := bash
.SHELLFLAGS := -euEo pipefail -c

.ONESHELL:


.PHONY: reinstall
reinstall:
	make --no-print-directory uninstall install


.PHONY: install
install:
	@ echo "Install: " >&2
	trap 'echo KO >&2' ERR

	@ echo -en " - Creating state folder... " >&2
	install \
		-D \
		-d \
		-g "root" -o "root" -m "u=rwx,g=rx,o=x" \
			"/var/local/lib/sensitive-storage"
	@ echo "OK" >&2

	@ echo -en " - Copying mount helper scripts... " >&2
	install \
		-D \
		-g "root" -o "root" -m "u=rwx,g=rx,o=x" \
		-t "/usr/local/bin" \
			"mount.sensitive-storage" "umount.sensitive-storage"
	@ echo "OK" >&2

	@ echo -en " - Copying main script... " >&2
	install \
		-D \
		-g "root" -o "root" -m "u=rwx,g=rx,o=x" \
		-t "/usr/local/bin" \
			"sensitive-storage"
	@ echo "OK" >&2

	@ echo -en " - Copying config files... " >&2
	install \
		-D \
		-g "root" -o "root" -m "u=rwx,g=rx,o=x" \
		-t "/etc/sensitive-storages" \
			$(shell find "./sensitive-storages" -name "*.medium" )
	@ echo "OK" >&2

	@ echo -en " - Copying systemd generator... " >&2
	install \
		-D \
		-g "root" -o "root" -m "u=rwx,g=rx,o=x" \
		-t "/usr/local/lib/systemd/system-generators" \
			"./systemd-sensitive-storage-generator"
	@ echo "OK" >&2

	@ echo -en " - Copying systemd units... " >&2
	install \
		-D \
		-g "root" -o "root" -m "u=rw,g=r,o=" \
		-t "/usr/local/lib/systemd/system" \
			"sensitive-storage.target"
	@ echo "OK" >&2

	@ echo -en " - Reloading systemd daemon... " >&2
	systemctl daemon-reload
	@ echo "OK" >&2

	@ echo -en " - Enabling systemd units... " >&2
	systemctl enable "sensitive-storage.target" --now --quiet
	@ echo "OK" >&2


.PHONY: uninstall
uninstall:
	@ echo "Uninstall: " >&2
	trap 'echo KO >&2' ERR
	
	@ echo -en " - Disabling systemd units... " >&2
	systemctl disable "sensitive-storage.target" --now --quiet
	@ echo "OK" >&2
	
	@ echo -en " - Deleting systemd units... " >&2
	rm "/usr/local/lib/systemd/system/sensitive-storage.target"
	@ echo "OK" >&2

	@ echo -en " - Deleting systemd generator... " >&2
	rm "/usr/local/lib/systemd/system-generators/systemd-sensitive-storage-generator"
	@ echo "OK" >&2
	
	@ echo -en " - Deleting mount helper scripts... " >&2
	rm "/usr/local/bin/mount.sensitive-storage" "/usr/local/bin/umount.sensitive-storage"
	@ echo "OK" >&2

	@ echo -en " - Deleting mount main script... " >&2
	rm "/usr/local/bin/sensitive-storage"
	@ echo "OK" >&2
	
	@ echo -en " - Reloading systemd daemon... " >&2
	systemctl daemon-reload
	@ echo "OK" >&2


.PHONY: follow-logs
follow-logs:
	tail -f "/var/log/sensitive-storage.log"


.PHONY: list-files
list-files:
	ls -alrth "/mnt/TEST"