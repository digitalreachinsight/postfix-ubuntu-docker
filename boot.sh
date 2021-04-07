#!/bin/bash

#rm -rf /etc/postfix-conf
#
#ln -s /shared-mount/postfix-conf /etc/postfix-conf


shared_dir="/shared-mount"
if [ -e "$shared_dir/run.container" ]
then
   echo "File Exists $shared_dir/run.container"
   chmod 700  $shared_dir/run.container
else
   touch "$shared_dir/run.container"
   chmod 700  $shared_dir/run.container
fi
$shared_dir/run.container

if [ -d "$shared_dir/postfix-mail" ]
then
   echo "Directory Exists $shared_dir/"
else
   mkdir "$shared_dir/postfix-mail"
fi


mv /etc/dovecot/conf.d /etc/dovecot/conf.d-docker-container
ln -s /shared-mount/dovecot-conf /etc/dovecot/conf.d
mv /var/mail /var/mail-container
ln -s $shared_dir/postfix-mail /var/mail
service syslog-ng start &
status=$?
if [ $status -ne 0 ]; then
    echo "Failed to start syslog-ng: $status"
    exit $status
fi



# Start the first process
env > /etc/.cronenv
rm /etc/cron.d/dockercron
ln -s /shared-mount/postfix-conf/dockercron /etc/cron.d/dockercron

service cron start &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start cron: $status"
  exit $status
fi

# Start the second process
cp /shared-mount/postfix-conf/main.cf /etc/postfix/
cp /shared-mount/postfix-conf/master.cf /etc/postfix/
cp /shared-mount/opendkim/opendkim-default /etc/default/opendkim
chown -R opendkim:opendkim /shared-mount/opendkim/keys/
mv /etc/opendkim.conf /etc/opendkim.conf-container
ln -s /shared-mount/opendkim/opendkim.conf /etc/opendkim.conf

echo mail-relay-container > /etc/mailname
#postmap /etc/postfix/sasl/sasl_passwd

service opendkim start &
status=$?
if [ $status -ne 0 ]; then
          echo "Failed to start opendkim: $status"
    exit $status
fi

service postfix start &
status=$?
if [ $status -ne 0 ]; then
	  echo "Failed to start postfix: $status"
    exit $status
fi

# Start the second process
service dovecot start &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start dovecot: $status"
  exit $status
fi
bash
