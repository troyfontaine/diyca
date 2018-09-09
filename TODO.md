# TODO

* Build around the premise of using cloud-init to launch the Pi so hostname is pre-configured
* Build install script to simplify set up
* Assume that local network will provide a domain name
* Assume that local DNS will add entry of hostname based on DHCP request
* Modify names on scripts
* Add nginx proxy with HTTP -> HTTPS redirect
* Add script to generate certificate for host on initialization
* Add firewall rules to limit traffic to local subnet only
* Modify CA cert request to use hostname (grabbing hostname at time of initialization)
* Add clean up that erases certificates stored on server after a configured amount of time
* Add systemd file to handle the launch of the service and automatically restart
