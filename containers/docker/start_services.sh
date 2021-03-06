#!/bin/bash

# The PUBLIC_HOSTNAME and PUBLIC_IP is not known at the time the docker
# image is built. On the first run of the container, re-run the start
# script with actual values. That will also ask the user for their first
# email user account.
if grep "^PUBLIC_IP=192.168.200.1" /etc/mailinabox.conf > /dev/null; then
  echo "Configuring container on first run..."

  # Get the public IP address of the host machine.
  export PUBLIC_IP=`curl -s icanhazip.com`
  echo Your IP address is $PUBLIC_IP.

  # Get the reverse DNS of that IP address.
  export PUBLIC_HOSTNAME=`host $PUBLIC_IP | sed -e "s/.* //" | sed -e "s/\.$//"`
  echo Your hostname is $PUBLIC_HOSTNAME.

  # Start configuration again.
  cd /usr/local/mailinabox
  scripts/start.sh
fi

echo "Starting Mail-in-a-Box services..."

service nsd start
service postfix start
dovecot # it's integration with Upstart doesn't work in docker
service opendkim start
service nginx start
service php-fastcgi start

if [ -t 0 ]
then
  # This is an interactive shell. You get a command prompt within
  # the container.
  #
  # You get here by running 'docker run -i -t'.

  echo "Welcome to your Mail-in-a-Box."
  bash

else
  # This is a non-interactive shell. It loops forever to prevent
  # the docker container from stopping.
  #
  # You get here by omitting '-t' from the docker run arguments.

  echo "Your Mail-in-a-Box is running..."
  while true; do sleep 10; done
fi
