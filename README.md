Utility to Flash Raspberry SD Card (with Built-in Applications)
---------------------------------------------------------------

Usages:

  Run the following script for the first time.

    ./envsetup.sh

  Pick up a project under projects/. For example, projects/dummy/:

    projects/dummy/host.sh  /dev/sdX  2021-12-02-raspios-buster-armhf-lite.img

  Then follow the instructions.

  After flashing, insert the SD card to the raspberry Pi board. Plug in a USB Ethernet adapter,
  connect cable to the Internet (so that the system will update itself), then power on the board.
  The system will boot and install necessary packages and shut down itself after completion.
  In the next boot, your Raspberry Pi is ready to use.

Other projects
--------------

* BLE UART (https://github.com/yjlou/ble_uart)

    projects/ble_uart/host.sh  /dev/sdX  2021-12-02-raspios-buster-armhf-lite.img

* WiFi sniffer

  Required hardware: rtl8812au chip (for example, ALFA AWUS036ACH)
  Required RPi OS images: 2022-04-04

    wget https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-04-07/2022-04-04-raspios-buster-armhf-lite.img.xz
    projects/sniffer/host.sh  /dev/sdX  2022-04-04-raspios-buster-armhf-lite.img

  Once it is installed, run the following command on the host to launch a Wireshark for analysis.

    projects/sniffer/host-sniffer.sh
