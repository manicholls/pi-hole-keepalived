## pi-hole-keepalived

Instructions and configuration examples to use keepalived with Pi-Hole to ensure high availability DNS at a single IP.

These instructions assume use of debian/ubuntu or derivatives and 2 or more Pi-Hole VMs.

Setup Pi-Hole (not covered here).

The only configuration change in Pi-Hole you'll want to make for this is to ensure that "Listen on all interfaces" is selected in your DNS settings tab on each Pi-Hole installation.

Pick one Pi-Hole to be your primary/master 

Install Keepalived via Apt
```
sudo apt install keepalived
```

create your keepalived config in /etc/keepalived.   You may need to change the interface to match the interface on your system.  Ex. use eth0 instead of ens18.
```
vrrp_instance VI_1 {
  interface ens18 # interface to monitor
  state MASTER # MASTER or BACKUP
  virtual_router_id 51
  priority 201 #
  notify /etc/keepalived/notify_script.sh 
  virtual_ipaddress {
    x.x.x.x # virtual ip address
  }
}
```

You'll also need to create the notify script, which will restart the pi-hole's dns server in order for it to see the new interface whenever it takes over.

```
sudo vi /etc/keepalived/notify_script.sh
```
```
#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
        "MASTER") pihole restartdns
                  exit 0
                  ;;
        "BACKUP") pihole restartdns
                  exit 0
                  ;;
        "FAULT")  pihole restartdns
                  exit 0
                  ;;
        *)        echo "unknown state"
                  exit 1
                  ;;
esac
```
You may wish to add commands to execute under each case, such as posting a webhook to slack so you're notified when the tasks execute and their status.  Keepalived can also be configured natively to send emails on state change.   I have not included these here as they aren't necessary for functionality.

Once these are in place start/restart keepalived and ensure that your new shared IP is pingable on the Master node.


Now you'll need to do the same on the second (and subsequent) nodes but you'll need to make sure that the **priority** and **state** are set accordingly in keepalived.conf.

```
vrrp_instance VI_1 {
  interface ens18 # interface to monitor
  state BACKUP # MASTER or BACKUP
  virtual_router_id 51
  priority 100 #
  notify /etc/keepalived/notify_script.sh 
  virtual_ipaddress {
    x.x.x.x # virtual ip address
  }
}
```

Now enable keepalived on the second node and test failing back and forth to ensure they are properly working!
