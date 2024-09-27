The Pi acts like an Wireless AP.  You can connect to the Internet via an
Ethernet port or a 4G/5G connection.  Even fancy, if you have a Starlink
connected to the Ethernet port.

                                         Android
                                    +---   USB  ---- 4G/5G ---- Internet
                                    |   Tethering
                                    |     (usb0)
                        +---------+ |                +--- ADSL ---- Internet
   WiFi   ---- WLAN ----|  Pi AP  |-+--- Ethernet ---+    modem
  device                +---------+      adapter     |
                                          (eth0)     +--- Starlink --- Internet
                                                          modem


Verified with the following images:

  - 2021-12-02-raspios-buster-armhf-lite.img
  - 2024-07-04-raspios-bookworm-armhf-lite.img

