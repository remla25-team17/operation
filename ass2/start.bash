#!/usr/bin/expect -f
#have to install expect
#sudo apt-get install expect


set timeout -1
set password "vagrant"

spawn ./run.bash

expect "password:"
send "$password\r"

interact