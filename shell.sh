#!/bin/bash
locations=("California, San Francisco" "California, San Jose")
echo "jenkins" | sudo -S $HOME/hma/hma-vpn.sh -p tcp ${locations[$((RANDOM%2))]} > ipinfo.txt 2>ipinfo-error.log &
IFS=$'\n'
echo $IFS
list=($(vboxmanage list vms))
echo $list
length=${#list[*]}
echo $length
echo `vboxmanage list vms`
vm=${list[$((RANDOM%length))]}
vm=$(echo $vm | cut -d "\"" -f2)
~/genymotion/player --vm-name $vm &
sleep 60
export ANDROID_HOME=~/android
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools:$JAVA_HOME/bin
java -jar selendroid-standalone-0.10.0-with-dependencies.jar -app signed_com.yelp.android_5.10.0.apk > server.log 2>server-error.log &
