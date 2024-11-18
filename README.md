# overlay-fs - Modify system files seamlessly without altering the root filesystem

<small>GitHub repository: [mr-manuel/venus-os_overlay-fs](https://github.com/mr-manuel/venus-os_overlay-fs)</small>

## Index

1. [Supporting/Sponsoring this project](#supportingsponsoring-this-project)
1. [Purpose](#purpose)
1. [Config](#config)
1. [Install / Update / Enable](#install--update--enable)
1. [Disable](#disable)
1. [Uninstall](#uninstall)
1. [Compatibility](#compatibility)
1. [How does it exactly work?](#how-does-it-exactly-work)


## Supporting/Sponsoring this project

You like the project and you want to support me?

[<img src="https://github.md0.eu/uploads/donate-button.svg" height="50">](https://www.paypal.com/donate/?hosted_button_id=3NEVZBDM5KABW)


## Purpose

This script adds one or more overlay filesystems to the system, allowing changes without making the root filesystem read/write. By unmounting the overlay filesystems, you can revert to a clean state, and changes remain persistent after an upgrade.

An overlay filesystem is a type of filesystem that allows you to layer one filesystem on top of another, making it possible to make changes without altering the original files.

In first place it was developed for Venus OS, but could be adapted for other Linux systems.


## Config

Modify the `overlay-fs.conf` in the `overlay-fs` folder as you need it. Just uncomment the absolute path you need or add a new one.


## Install / Update / Enable

1. Login to your Venus OS device via SSH. See [Venus OS:Root Access](https://www.victronenergy.com/live/ccgx:root_access#root_access) for more details.

2. Execute this commands to download and copy the files:

    ```bash
    wget -O /tmp/install_overlay-fs.sh https://raw.githubusercontent.com/mr-manuel/venus-os_overlay-fs/master/install.sh

    bash /tmp/install_overlay-fs.sh
    ```

### Extra steps for your first installation

3. Edit the config file to fit your needs.

    ```bash
    nano /data/apps/overlay-fs/overlay-fs.conf
    ```

4. Run the install script.

    ```bash
    bash /data/apps/overlay-fs/enable.sh
    ```

## Disable

To disable the overlay-fs mount on boot, unmount the overlays and restore the previous state, run this command:

```bash
bash /data/etc/overlay-fs/disable.sh
```

## Uninstall

To disable the overlay-fs mount on boot, unmount the overlays, restore the previous state and remove everything from the system, run this command:

```bash
bash /data/etc/overlay-fs/unenable.sh
```

## Compatibility

This software supports the latest three stable versions of Venus OS. It may also work on older versions, but this is not guaranteed.


## How does it exactly work?

1. **Configuration File**:
   - The script reads the configuration file located at `/data/apps/overlay-fs/overlay-fs.conf`.
   - Each line in this file should specify a directory path that needs to be overlaid.

2. **Install script**:
   - The `enable.sh` script reads the configuration file and sets up overlay filesystems based on its contents.
   - For each directory specified in the config file, it creates a corresponding folder under `/data/apps/overlay-fs/data`.
   - It creates three necessary subdirectories: `upper`, `work`, and `merged`.
   - **Mounting Overlay**:<br>
     The script mounts the overlay filesystem to the `merged` directory, combining the original directory with the `upper` and `work` directories.
   - **Binding Overlay**:<br>
     Finally, it binds the `merged` directory to the original directory, making the changes appear seamless.
