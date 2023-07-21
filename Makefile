SHELL := bash
.SHELLFLAGS := -euEo pipefail -c

.ONESHELL:


SRCDIR := ./src
BUILDDIR := ./build
DESTDIR := /usr/local
DISTDIR := ./dist
PREFIX := $(DESTDIR)

VERSION := 0.0.1
RELEASE := 1


SOURCE_FILES := $(shell find "$(SRCDIR)/scripts" "$(SRCDIR)/functions" "$(SRCDIR)/systemd-units" -type "f")
BUILD_FILES := $(SOURCE_FILES:$(SRCDIR)/%=$(BUILDDIR)/%)


build: $(BUILD_FILES)


$(BUILDDIR)/scripts/%: $(SRCDIR)/scripts/%
	mkdir -p "$(BUILDDIR)/scripts"
	sed \
		-r\
		-e "s,%\{PREFIX\},$(PREFIX),g" \
		"$<" >"$@"


$(BUILDDIR)/%: $(SRCDIR)/%
	mkdir -p "$(shell dirname "$@" )"
	cp "$<" "$@"


.PHONY: install
install:
	# Install functions
	find "$(BUILDDIR)/functions" -type "f" -exec install \
		-D \
		-m "u=rw,g=r,o=" \
		-t "$(DESTDIR)/lib/encrypted-storage/functions" \
			"{}" \;

	# Install binaries
	install \
		-D \
		-m "u=rwx,g=rx,o=x" \
		-t "$(DESTDIR)/bin" \
			"$(BUILDDIR)/scripts/encrypted-storage" \
			"$(BUILDDIR)/scripts/mount.encrypted-storage" \
			"$(BUILDDIR)/scripts/umount.encrypted-storage"

	# Install systemd generator
	install \
		-D \
		-m "u=rwx,g=rx,o=x" \
		-t "$(DESTDIR)/lib/systemd/system-generators" \
			"$(BUILDDIR)/scripts/systemd-encrypted-storage-generator"

	# Install systemd units
	install \
		-D \
		-m "u=rw,g=r,o=" \
		-t "$(DESTDIR)/lib/systemd/system" \
			"$(BUILDDIR)/systemd-units/encrypted-storage.target"


.PHONY: uninstall
uninstall:
	rm "$(DESTDIR)/lib/systemd/system/encrypted-storage.target"
	rm "$(DESTDIR)/lib/systemd/system-generators/systemd-encrypted-storage-generator"
	rm "$(DESTDIR)/bin/umount.encrypted-storage"
	rm "$(DESTDIR)/bin/mount.encrypted-storage"
	rm "$(DESTDIR)/bin/encrypted-storage"
	rm -Rf "$(DESTDIR)/lib/encrypted-storage"


.PHONY: enable
enable:
	systemctl daemon-reload
	systemctl enable --now "encrypted-storage.target"


.PHONY: clean
clean:
	trash "$(BUILDDIR)"
	trash "encrypted-storage-$(VERSION).tar.gz"

$(DISTDIR)/encrypted-storage-$(VERSION).tar.gz:
	mkdir -p "$(DISTDIR)"
	tar -cf "$(DISTDIR)/encrypted-storage-$(VERSION).tar.gz" "Makefile" "src"

$(DISTDIR)/PKGBUILD: PKGBUILD
	cp "PKGBUILD" "$(DISTDIR)/PKGBUILD"

.PHONY: package
package: $(DISTDIR)/encrypted-storage-$(VERSION).tar.gz $(DISTDIR)/PKGBUILD
	cd "$(DISTDIR)"

	PKGVER="$(VERSION)" \
	PKGREL="$(RELEASE)" \
		makepkg \
			--force \
			--skipchecksums \
			--nodeps

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
	
