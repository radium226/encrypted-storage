SHELL := bash
.SHELLFLAGS := -euEo pipefail -c

.ONESHELL:


SRCDIR := ./src
BUILDDIR := ./build
DESTDIR := /usr/local


SOURCE_FOLDER := $(SRCDIR)
BUILD_FOLDER := $(BUILDDIR)
INSTALL_FOLDER := $(DESTDIR)


SOURCE_FILES := $(shell find "$(SOURCE_FOLDER)/scripts" "$(SOURCE_FOLDER)/functions" "$(SOURCE_FOLDER)/systemd-units" -type "f")
BUILD_FILES := $(SOURCE_FILES:$(SOURCE_FOLDER)/%=$(BUILD_FOLDER)/%)


build: $(BUILD_FILES)


$(BUILD_FOLDER)/scripts/%: $(SOURCE_FOLDER)/scripts/%
	mkdir -p "$(BUILD_FOLDER)/scripts"
	sed \
		-r\
		-e "s,%\{INSTALL_FOLDER\},$(INSTALL_FOLDER),g" \
		"$<" >"$@"


$(BUILD_FOLDER)/%: $(SOURCE_FOLDER)/%
	mkdir -p "$(shell dirname "$@" )"
	cp "$<" "$@"


.PHONY: install
install:
	# Install functions
	find "$(BUILD_FOLDER)/functions" -type "f" -exec install \
		-D \
		-m "u=rw,g=r,o=" \
		-t "$(INSTALL_FOLDER)/lib/encrypted-storage/functions" \
			"{}" \;

	# Install binaries
	install \
		-D \
		-m "u=rwx,g=rx,o=x" \
		-t "$(INSTALL_FOLDER)/bin" \
			"$(BUILD_FOLDER)/scripts/encrypted-storage" \
			"$(BUILD_FOLDER)/scripts/mount.encrypted-storage" \
			"$(BUILD_FOLDER)/scripts/umount.encrypted-storage"

	# Install systemd generator
	install \
		-D \
		-m "u=rwx,g=rx,o=x" \
		-t "$(INSTALL_FOLDER)/lib/systemd/system-generators" \
			"$(BUILD_FOLDER)/scripts/systemd-encrypted-storage-generator"

	# Install systemd units
	install \
		-D \
		-m "u=rw,g=r,o=" \
		-t "$(INSTALL_FOLDER)/lib/systemd/system" \
			"$(BUILD_FOLDER)/systemd-units/encrypted-storage.target"


.PHONY: uninstall
uninstall:
	rm "$(INSTALL_FOLDER)/lib/systemd/system/encrypted-storage.target"
	rm "$(INSTALL_FOLDER)/lib/systemd/system-generators/systemd-encrypted-storage-generator"
	rm "$(INSTALL_FOLDER)/bin/umount.encrypted-storage"
	rm "$(INSTALL_FOLDER)/bin/mount.encrypted-storage"
	rm "$(INSTALL_FOLDER)/bin/encrypted-storage"
	rm -Rf "$(INSTALL_FOLDER)/lib/encrypted-storage"


.PHONY: enable
enable:
	systemctl daemon-reload
	systemctl enable --now "encrypted-storage.target"


.PHONY: clean
clean:
	trash "$(BUILD_FOLDER)"


# .PHONY: test
# test:
# 	@

# 	trap "echo Failed! >&2" ERR

# 	declare CONFIG_FOLDER_PATH
# 	CONFIG_FOLDER_PATH="./etc"
# 	export CONFIG_FOLDER_PATH

# 	declare RUNTIME_FOLDER_PATH
# 	RUNTIME_FOLDER_PATH="./test/run"
# 	export RUNTIME_FOLDER_PATH

# 	echo " ==> Listing media... " >&2
# 	./bin/encrypted-storage list-media
# 	echo " --> Done! " >&2
# 	echo >&2

# 	echo " ==> Mounting TEST medium... " >&2
# 	./bin/encrypted-storage mount-medium "./test/mnt/TEST"
# 	test -f "./test/mnt/TEST/secrets.txt" && cat "./test/mnt/TEST/secrets.txt"
# 	echo " --> Done !" >&2
# 	echo >&2

# 	echo " ==> Unmounting TEST medium... " >&2
# 	./bin/encrypted-storage unmount-medium "./test/mnt/TEST"
# 	! test -f "./test/mnt/TEST/secrets.txt"
# 	echo " --> Done !" >&2
# 	echo >&2

# 	ln -s \
# 		"$(shell pwd)/bin/mount.encrypted-storage" "$(shell pwd)/bin/umount.encrypted-storage" "$(shell pwd)/bin/encrypted-storage" \
# 		"/usr/local/bin" || true

# 	echo " ==> Mounting TEST medium using mount" >&2
# 	mount -v -t encrypted-storage TEST "./test/mnt/TEST"
# 	test -f "./test/mnt/TEST/secrets.txt" && cat "./test/mnt/TEST/secrets.txt"
# 	mount -v | grep "TEST"
# 	echo " --> Done !" >&2
# 	echo >&2


# 	echo " ==> Unmounting TEST medium using umount" >&2
# 	umount -v "./test/mnt/TEST"
# 	! test -f "./test/mnt/TEST/secrets.txt"
# 	echo " --> Done !" >&2
# 	echo >&2

# 	rm "/usr/local/bin/mount.encrypted-storage" "/usr/local/bin/umount.encrypted-storage" "/usr/local/bin/encrypted-storage" || true
	
