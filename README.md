
# GoOpenDrop


#### a Go Implementation and Enhancement of the Awesome Open Source AirDrop implementation work of seemoo-lab [openairdrop](https://github.com/seemoo-lab/opendrop)
<br/>

<hr>

## This currently doesn't work properly and I don't know why!

<hr>

### Features:

###### - Support Sending/Receiving Multiple Files. Photos/videos are sent as one request, and any other file of the same Apple UType will be sent together

###### - Support for BLE 5.0, using BLUEZ with d-bus interface

###### - Handling all BLE related work, by sending proper Airdrop beacon to intiate Airdrop on Mobiles side, and by capturing BLE beacons to start advertising Zeronconf Service

###### - Pure Go CPIO Archive implementation written for this project, with auto detection of GZipped CPIO

###### - Easy Customization and Integration, All Core Requried functionality in one file with a **"INTEGRATION POINT"** Comment Tag

<br/>

### Patching the Raspberry Pi 3 WiFi interface

**This will only work the Legacy Pi OS version!**

Follow the README [here](https://github.com/seemoo-lab/nexmon/blob/master/README.md) for the Raspberry Pi 3

### Required APT Packages:

###### These the packages required on a Debian based OS
```
sudo apt install libpcap0.8 libev4 bluez
```

### Installing GO on Raspberry Pi (from this [guide](https://www.jeremymorgan.com/tutorials/raspberry-pi/install-go-raspberry-pi/))

Raspberry Pi OS doesn't come with GO out of the box, so you will have to install it manually (the version on apt is too old):

- go to the [GO download page](https://golang.org/dl/) and make note of the newest release for armv6l (currently this is `go1.20.3.linux-armv6l.tar.gz`)

- use wget to download the archive:
  ```
  mkdir ~/src && cd ~/src
  wget https://go.dev/dl/go1.20.3.linux-armv6l.tar.gz
  ```

- extract the package into your local folder:
  ```
  sudo tar -C /usr/local -xzf go1.20.3.linux-armv6l.tar.gz
  ```

- you can now delete the archive again:
  ```
  rm go1.20.3.linux-armv6l.tar.gz
  ```

- now you have to configure GO:
	- open ~/.profile (using nano, vi, etc.)
	  ```
	  nano ~/.profile
	  ```
	- add the following at the bottom:
	  ```
	  PATH=$PATH:/usr/local/go/bin
	  GOPATH=$HOME/go
	  ```
	- configure the shell with your changes:
	  ```
	  source ~/.profile
	  ```

- you can verify that the install worked by checking your GO version:
  ```
  go version
  ```

### Required OWL Binaries:

I've included seemoo-lab Compiled OWL Binaries, you can use it, or build it from source:
https://github.com/seemoo-lab/owl
<br/>

### Extraction of Apple Keys:

You **MUST** do the extraction Step of Keys, GoOpenDrop will not generate self signed certificates.

##### Extraction of the keys benefits:
- this will give the ability to have a verified contact (accept from contact in airdrop settings, and it will show a fixed thumbnail image of type JPEG2000)

- Mobile Configured with Airdrop: Contacts Only Mode, will still accept files from GoOpenDrop


Copy the Extracted keys and validation_record to **"Keys"** Folder, and run the script: RemovePassphraseKey.sh to remove the passphrase

On Mobile Side, you just add a contact with the same email address used for the extracted Apple ID used for extraction

Follow this repo for extraction:

https://github.com/seemoo-lab/airdrop-keychain-extractor

If the instructions in the above repo don't work, try [this](https://github.com/seemoo-lab/airdrop-keychain-extractor/issues/2#issuecomment-1501217586)

##### Example of a verified /Ask post Request:

<img src="verified.png" width="30%" height="30%"></img>

<br/>

### GoOpenDrop Configuration

At the moment, GoOpenDrop Just use a simple json file for configurations

| parameter                   | Type   | Default                    |                                                                                                           |
| --------------------------- | ------ | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| inbox_folder                | string | INBOX                      | This is the folder of the Received File from Mobile                                                       |
| outbox_folder               | string | OUTBOX                     | This is the Folder where GoOpenDrop will check for Sending Files to Mobile                                |
| owl_wlan_dev_name           | string | mon0                       | Wlan Interface Name to used for Owl, set to mon0 for nexmon patched interfaces                            |
| owl_channel_6_44_149        | string | 6                          | wlan Channel to used for Owl, currently always uses 6 no matter what you specify here                       |
| os_downloadedfiles_owner    | string | pi                         | Os Username to change received files owner to                                                             |
| awdl_interface_name         | string | awdl0                      | The Interface name to set Owl to                                                                          |
| thumbnail_picture_jp2       | string | fixed_thumbnail.jp2        | GoOpenDrop will use this file as thumbnail for /Ask requests, file should be of type JP2000, size 540x540 |
| ble_device                  | string | hci0                       | (The Raspberry Pi 3 bluetooth interface)                                                                  |
| airdrop_appleid             | string |                            | The Apple ID Account used in Extracting Keys, this used even for broadcasting proper BLE Beacons          |
| airdrop_email               | string |                            | Can be Same as Apple ID                                                                                   |
| airdrop_phone               | string |                            | any number will do                                                                                        |
| airdrop_server_hostname     | string | GoOpenDrop                 | The device Name that will appear which mobile phone discover GoOpenDrop                                   |
| airdrop_server_model        | string | MacbookPro5.1              | No need to modify this                                                                                    |
| airdrop_server_port         | int    | 8772                       | No need to modify this                                                                                    |
| apple_root_cert             | string | certs/apple_root_ca.pem    | Apple Root Certificate, already included in this repo                                                     |
| extracted_certififcate      | string | keys/certificate.pem       | Extracted Certificate                                                                                     |
| extracted_certkey           | string | keys/key_noenc.pem         | Extracted Certificate Key, after removing the encryption                                                  |
| extracted_validation_recoed | string | keys/validation_record.cms | Extracted Validation Record                                                                               |

<br/>

### Sending/Receving Files:

To Send Files, Create a folder in "OUTBOX" with the device name of the receiver, just drop any files there, they will be sent once the device is discovered.

Receiving, GoOpenDrop will accept any file and will create a folder in INBOX with the device name of the sender. You can customize this functionality by modifying the file:

###### main.go
```
func checkSender(name string) bool {
	// INTEGRATION POINT
	// ADD INTEGRATION HERE IF NEEDED, You can call your own API server to decide accept or reject /Ask request 
	return true 

}
```

### Build

To build simply run the scripts:
```
./Build_Linux64.sh
```
Or
```
./Build_Pi.sh
```

The build scripts will copy all required files along with the binary
to **out** folder

### Running

Before running, nexmon has to be started:
```
sudo iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor
sudo ifconfig mon0 up
sudo nexutil -k6
```

For some reason the firmware patch unapplies on reboot, to fix run this script (as root, eg. using `sudo su`) when starting the pi (also in `./scripts/firmware-patch-boot.sh`):
```
cd /home/pi/nexmon/
source setup_env.sh
cd /home/pi/nexmon/patches/bcm43430a1/7_45_41_46/nexmon/
make install-firmware
sleep 5s
iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor
sleep 5s
ifconfig mon0 up
nexutil -k6
```

At the moment, since GoOpenDrop restart BLE interface, wlan interface, it requires to run as Root. 

run GoOpenDrop compiled
```
sudo ./goopendrop ./config.json
```

### Issues/Limitations and security

* GoOpenDrop Require Running as Root, will try to fix this as soon as I find the correct capabilities to give the binary, or find a better solution to restart BLE and wlan interfaces
* Client Verification, GoOpenDrop Does not verify the client sending the files, this can easily be fixed by writing a custom TLS verification function, which will extract client details and verify it with received apple signature in received validation record
* since GoOpenDrop currently requires running as root, a client can use malicious device name, or malicious cpio archive and escape path or overwrite system files

### Tested Wifi Module :
* Raspberry Pi 3 WiFi module (BCM43430A1), patched with [nexmon](https://github.com/seemoo-lab/nexmon/)

### Tested Hardware/os:
* Raspberry Pi 3
