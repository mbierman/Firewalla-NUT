# Firewalla-NUT
Using a NUT client with Firewalla

### Summary
A NUT client is the software responsible for watching the UPS status over a network and gracefully shutting down the host machine before the USP battery runs out. This project provides instructions for running a NUT client on Firewalla to ensure it safely shuts down during a blackout to prevent damage from unexpected power loss. Using a UPS is a good idea with expensive equipment like Firewalla.

### About NUT
NUT operates on a server-client architecture. While the server (`upsd`) is physically connected to the Uninterruptible Power Supply (UPS) via a USB or Serial cable, the client (`upsmon`) is the software that listens for updates over your network.
<img width="600" height="1043" alt="image" src="https://github.com/user-attachments/assets/2237c0e9-0b41-40b2-87d6-9e6efa5149ac" />


| Component | Role | Description |
| :--- | :--- | :--- |
| **UPS** | Hardware | The physical battery unit. |
| **NUT Server** | The Reporter | Polls the UPS and broadcasts status to the network. |
| **NUT Client** | The Executor | Watches the status and triggers local actions (like shutdown). |

**Primary Functions:**
1. **Monitoring:** The *NUT Server* monitors the *UPS* and notifies *NUT Clients* of power status (Wall/Battery) and battery levels.
1. **Triggering Actions:** If power fails, the client waits until a specific threshold is met (e.g., "Battery Critical") and initiates a safe system shutdown.
1. **Notifying Users:** The system can send alerts via wall messages, emails, or scripts regarding power status changes.

### Why Use NUT with Firewalla?
One UPS can protect multiple devices. If you have a UPS powering a NAS, a PC, and a Firewalla, you only physically connect the UPS to one device (the Server) via USB or serial cable. You then install NUT Clients on the other device and the Server tells the Clients over the local network to shut down gracefully and safely before the battery is depleted.

### How this setup works
The configuration described here runs a lightweight NUT client on Firewalla. It assumes that you have a UPS connected to a NUT server and that the server is configured and accessible via your network.

In order to keep the NUT client separate from Firewalla and not interfere in any way with core services, we'll use a secure Docker container. This ensures that the client remains isolated and won't compromise Firewalla.


### Configuration Example
In my example, I am using a UPS like this one:

<div align="center">
  <img src="https://github.com/user-attachments/assets/9cd7a8cb-6349-4d1c-be70-bc27b05e426c" alt="UPS" width="600" >
</div>


### Configure IP reservation for the NUT server
First, create an [IP reservation](https://help.firewalla.com/hc/en-us/articles/115004304054-Device-Management#h_93f11f96-24f3-4181-aa19-d2dac0f16368) for your NUT server. You will need this IP later and you don't want it to change or things will fail down the road. In my example, my NUT server will be my Synology NAS as described below.

<img height="500"  alt="image" src="https://github.com/user-attachments/assets/e9b68635-7d4c-4dcf-903f-999321fe602d" />


### Synology NAS (NUT Server) Setup
My NUT server is hosted on a Synology NAS. There are other ways of doing this which I won't cover here. 
> [!IMPORTANT]
> This guide uses a specific Synology DSM version as an example. Interfaces vary significantly between different NAS manufacturers and even between different versions of Synology DSM. Use these steps as a general logical guide for your specific hardware.

The Synology NAS acts as the "Reporter." Follow these steps to enable the network server using the numbered sequence in the image below:

<img width="800" alt="image" src="https://github.com/user-attachments/assets/79bcf049-43d4-48bc-b091-4abff8e6a304" />

1. **Accessing UPS Settings**
   * **1.1.** Open the `Control Panel` (1).
   * **1.2.** Select `Hardware & Power` (2) from the left-hand menu.
   * **1.3.** Click the `UPS` tab (3) at the top.

2. **Enabling the Server**
   * **2.1.** Check the box to `Enable UPS support` (4).
   * **2.2.** Set the Time before DiskStation enters Safe Mode (5). You need to change this based on your UPS capacity. 
### Default Synology NUT Credentials
Since there are no fields for username or password in the Synology GUI, the system uses hardcoded defaults for access controls. You must use these in your Firewalla `upsmon.conf` file:

* **UPS Name:** `ups`
* **Username:** `monuser`
* **Password:** `secret`

If your NUT server has different cedentials, you will need to change these appropriately in the setting files provided. 

### Configuration Instructions
Currently, these steps are manual. You will need to modify the settings based on your specific UPS name and NUT server IP.

1. [SSH ](https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH) to your Firewalla.
1. Create a directory for the Docker container:
   ```bash
   pi@firewalla:~$ mkdir -p /home/pi/.firewalla/run/docker/nut
   pi@firewalla:~$ cd /home/pi/.firewalla/run/docker/nut
   ```
1. Save all of the files in this project to the directory and check that all the files are in place.
```
pi@firewalla:~$  ls -al 
total 24
drwxrwxr-x 2 pi pi 4096 Feb 26 19:49 .
drwxr-xr-x 6 pi pi 4096 Feb 24 21:12 ..
-rw-rw-r-- 1 pi pi  208 Feb 26 19:49 Dockerfile
-rw-rw-r-- 1 pi pi  199 Feb 26 19:40 README.txt
-rw-rw-r-- 1 pi pi  250 Feb 26 19:39 docker-compose.yml
-rw-rw-r-- 1 pi pi  185 Feb 24 21:49 upsmon.conf
pi@firewalla:~$
```

4. Edit `upsmon.conf` to replace the IP of your NUT server.

5. Build the docker image and Deploy
You need to build the docker container as follows. 
```
pi@firewalla:~$ sudo docker-compose up -d --build
```
6. Test to see if it is working. If you get output like this, it is working. Replace NUT_Server_IP_address below with the IP you reserved for your Synology in the first step (e.g., ups@192.168.0.5)."
```
pi@firewalla:~$  sudo docker exec nut-client upsc ups@NUT_Server_IP_address
Init SSL without certificate database
battery.charge: 100
battery.charge.low: 95
battery.mfr.date: 2001/01/01
battery.runtime: 2001
battery.runtime.low: 120
battery.type: PbAc
battery.voltage: 13.7
battery.voltage.nominal: 12.0
device.mfr: American Power Conversion
device.model: Back-UPS BE1050G3
device.serial: 0B2502P08919
device.type: ups
driver.name: usbhid-ups
driver.parameter.pollfreq: 30
driver.parameter.pollinterval: 5
driver.parameter.port: auto
driver.version: DSM6-2-25510-201118
driver.version.data: APC HID 0.95
driver.version.internal: 0.38
input.sensitivity: medium
input.transfer.high: 139
input.transfer.low: 92
input.transfer.reason: input voltage out of range
input.voltage: 116.0
input.voltage.nominal: 115
ups.beeper.status: enabled
ups.delay.shutdown: 20
ups.firmware: 464401G -495900G 
ups.load: 14
ups.mfr: American Power Conversion
ups.mfr.date: 2025/01/09
ups.model: Back-UPS BE1050G3
ups.productid: 0002
ups.realpower.nominal: 600
ups.serial: 0B2502P08919
ups.status: OL
ups.test.result: Done and passed
ups.timer.reboot: 0
ups.timer.shutdown: -1
ups.vendorid: 051d
```

### Troubleshooting
* Be sure you don't have any rules on your Synology firewall blocking access from the Firewalla. Be sure TCP Port 3493 is open for the Firewalla's IP.
