# Firewalla-NUT
NUT client for Firewalla

### Summary

A NUT client is the software responsible for watching the UPS status over a network and gracefully shutting down the host machine before the battery runs out. This provides instructions for running a NUT client on Firewalla to have it safely shutdown before it runs out of power after a blackout. 


### About NUT
NUT operates on a server-client architecture. While the server (upsd) is physically connected to the Uninterruptible Power Supply (UPS) via USB or Serial, the client (upsmon) is the software that listens for updates.

| Component | Role | Analogous To... |
| :--- | :--- | :--- |
| **UPS** | The Battery | The physical hardware. |
| **NUT Server** | The Reporter | Polls the UPS and broadcasts its status. |
| **NUT Client** | The Executor | Watches the status and triggers actions (like a shutdown). |

Basic actions of each component includes: 
1. **Monitoring:** The *NUT Server* monitores the UPS and notifies *NUT clients* when the UPS is on wall power or battery power as well as battery level, etc. 
1. **Triggering Actions:**  If the power fails, the client waits until a specific threshold is met (e.g., "Battery Critical") and then initiates a safe system shutdown to prevent data corruption.
1. **Notifying Users:** It can send alerts via wall messages, emails, or scripts to let you know the power status has changed.

### Why Use a NUT Client?
The beauty of this system is that one UPS can protect multiple devices. If you have one UPS powering a NAS, a PC, and a secondary server, you only connect the UPS to the NAS (the Server). You then install NUT Clients on the PC and the secondary server. Over the network, the NAS tells both machines, "Hey, the battery is dying—save your work and shut down now!"

### How this set up works
This configuration runs a lightwaeight NUT client on Firewalla. It assumes that you have a UPS connected to a NUT server and that the NUT server is configured and has network connectivity. 

### Configuration Example


In my excample,I'm using a UPS like this one. 
![UPS](https://github.com/user-attachments/assets/9cd7a8cb-6349-4d1c-be70-bc27b05e426c)

My UPS server is on a Synolgy NAS. There are many ways to run the NUT Server--that's left as an exercise for the reader.



### Configuration instructions

For now I haven't created an install script. Rather, here are example files and instructions are provided. You will need to modify the settings based on your UPS and your NUT server.

1. [SSH to your firewalla]([url](https://help.firewalla.com/hc/en-us/articles/115004397274-How-to-access-Firewalla-using-SSH)).
2. Create a directory for the docker. 
```
mkdir /home/pi/.firewalla/run/docker/nut
cd /home/pi/.firewalla/run/docker/nut
```
3. Save the files in this project to that directory. You can use `vi` or 
