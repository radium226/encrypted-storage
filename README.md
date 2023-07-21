# `encrypted-storage`

## Goal

The goal of this project is to simplify mounting and unmounting encrypted storage. 

## Configuration

To define the `YOUR_STORAGE` storage, you should add in `/etc/encrypted-storage`: 
 * A `YOUR_STORAGE.medium` file which should contain:
    * A `setup` function to mount it (the `${KEY_FILE_PATH}` and `${MOUNT_POINT}` environment variable will be provided) 
    * A `teardown` function to unmount it (the `${MOUNT_POINT}` environment variable will be provided)
 * A `YOUR_STORAGE.key` key file


## Usage

### CLI

```
# List all media
encrypted-storage list-media

# Mount YOUR_STORAGE to /mnt/YOUR_STORAGE
encrypted-storage mount "/mnt/YOUR_STORAGE"

# Unmount YOUR_STORAGE from /mnt/YOUR_STORAGE
encrypted-storage unmount "/mnt/YOUR_STORAGE"
```

### Through systemd's `.automount` units

When the `encrypted-storage.target` is started, an `.automount` unit is automatically created for each of the configured storage.

It's then possible to go directly to the `/mnt/YOUR_STORAGE` folder and your storage will mounted on-the-fly automatically 


## Install

### Generic

```
make PREFIX="/usr/local" build
sudo make DESTDIR="/usr/local" install
sudo systemctl enable --now "encrypted-storage.target" 
```


### Arch Linux

```
make package
pacman -U "./dist/encrypted-storage-0.0.1-1-any.pkg.tar.zst"
sudo systemctl enable --now "encrypted-storage.target"
```
