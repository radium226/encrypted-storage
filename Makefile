SHELL := bash
.SHELLFLAGS := -euEo pipefail -c

.ONESHELL:


.PHONY: test
test:
	@

	trap "echo Failed! >&2" ERR

	declare CONFIG_FOLDER_PATH
	CONFIG_FOLDER_PATH="./etc"
	export CONFIG_FOLDER_PATH

	declare RUNTIME_FOLDER_PATH
	RUNTIME_FOLDER_PATH="./test/run"
	export RUNTIME_FOLDER_PATH

	echo " ==> Listing media... " >&2
	./bin/encrypted-storage list-media
	echo " --> Done! " >&2
	echo >&2

	echo " ==> Mounting TEST medium... " >&2
	./bin/encrypted-storage mount-medium "./test/mnt/TEST"
	test -f "./test/mnt/TEST/secrets.txt" && cat "./test/mnt/TEST/secrets.txt"
	echo " --> Done !" >&2
	echo >&2

	echo " ==> Unmounting TEST medium... " >&2
	./bin/encrypted-storage unmount-medium "./test/mnt/TEST"
	! test -f "./test/mnt/TEST/secrets.txt"
	echo " --> Done !" >&2
	echo >&2

	ln -s \
		"$(shell pwd)/bin/mount.encrypted-storage" "$(shell pwd)/bin/umount.encrypted-storage" "$(shell pwd)/bin/encrypted-storage" \
		"/usr/local/bin" || true

	echo " ==> Mounting TEST medium using mount" >&2
	mount -v -t encrypted-storage TEST "./test/mnt/TEST"
	test -f "./test/mnt/TEST/secrets.txt" && cat "./test/mnt/TEST/secrets.txt"
	mount -v | grep "TEST"
	echo " --> Done !" >&2
	echo >&2


	echo " ==> Unmounting TEST medium using umount" >&2
	umount -v "./test/mnt/TEST"
	! test -f "./test/mnt/TEST/secrets.txt"
	echo " --> Done !" >&2
	echo >&2

	rm "/usr/local/bin/mount.encrypted-storage" "/usr/local/bin/umount.encrypted-storage" "/usr/local/bin/encrypted-storage" || true
	
