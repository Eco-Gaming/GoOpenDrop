cd /home/pi/nexmon/
source setup_env.sh
cd /home/pi/nexmon/patches/bcm43430a1/7_45_41_46/nexmon/
make install-firmware
sleep 5s
iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor
sleep 5s
ifconfig mon0 up
nexutil -k6
