## Ubuntu 14.04 CloudStack image

Scripts to modify standard [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/) for deployment on CloudStack/Xen.

Based on [Bootstrap your QCOW Images for the Rackspace Public Cloud](https://developer.rackspace.com/blog/bootstrap-your-qcow-images-for-the-rackspace-public-cloud/).

## Usage

Start Vagrant
```
vagrant up
vagrant ssh
```

Inside Vagrant VM:
```
sudo -s
cd /vagrant
wget http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
./mkvhd.sh
```
