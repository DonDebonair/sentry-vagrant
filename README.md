# Sentry Vagrant

Sentry Vagrant is a complete, hassle-free way to setup [Sentry](https://github.com/getsentry/sentry) on a Virtual Machine so you can play around with it. It uses [Vagrant](http://www.vagrantup.com/) to assemble the VM and [Puppet](http://puppetlabs.com/) to provision it. What gets installed:

*  Virtual Machine running Ubuntu 12.04 (Precise Pangolin)
*  PostgreSQL database
*  NginX webserver/reverse proxy
*  Python, Pip & VirtualEnv
*  The latest stable version of **Sentry**

## Yeah, that's cool, but how do I run it?!

That's simple! 

First install: [Vagrant](http://www.vagrantup.com/) and a Virtual Machine provider of choice ([VirtualBox](https://www.virtualbox.org/) is free and works out of the box with Vagrant)

Then: 

```
$ git clone https://github.com/DandyDev/sentry-vagrant.git
$ cd /path/to/sentry-vagrant
$ vagrant up
```

Now login to your freshly provisioned VM using `vagrant ssh` and do the following:

```
vagrant@precise32:~$ sudo -i
root@precise32:~# cd /var/sentry
root@precise32:~# . ve/bin/activate
root@precise32:~# sentry --config=sentry_conf.py syncdb
root@precise32:~# sentry --config=sentry_conf.py migrate
root@precise32:~# /etc/init.d/nginx restart
root@precise32:~# supervisorctl reload
```

Now you can navigate to [localhost:4567](localhost:4567) in a browser on your hostmachine and get rollin'!

## Known issues / TODO

* Sentry will sometimes drop the port-number (4567) in links. If that happens, just add the port-number back to the URL
* Mailer doesn't work yet