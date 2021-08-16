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
   echo "Directory Exists $shared_dir/postfix-mail"
else
   mkdir "$shared_dir/postfix-mail"
fi

#if [ -d "$shared_dir/postfix-queues" ]
#then
#   echo "Directory Exists $shared_dir/postfix-queues"
#else
#   mkdir "$shared_dir/postfix-queues"
#fi
## queue sub dirs
#if [ -d "$shared_dir/postfix-queues/maildrop" ]
#then
#   echo "exists";
#else
#   mkdir $shared_dir/postfix-queues/maildrop;
#fi
#
#
#if [ -d "$shared_dir/postfix-queues/hold" ]
#then
#   echo "exists";
#else
#   mkdir $shared_dir/postfix-queues/hold;
#fi
#
#if [ -d "$shared_dir/postfix-queues/incoming" ]
#then
#   echo "exists";
#else
#   mkdir $shared_dir/postfix-queues/incoming;
#fi
#
#if [ -d "$shared_dir/postfix-queues/active" ]
#then
#   echo "exists";
#else
#   mkdir $shared_dir/postfix-queues/active;
#fi
#
#if [ -d "$shared_dir/postfix-queues/deferred" ]
#then
#   echo "exists";
#else
#   mkdir $shared_dir/postfix-queues/deferred;
#fi
#
#if [ -d "$shared_dir/postfix-queues/corrupt" ]
#then
#   echo "exists";
#else
#   mkdir $shared_dir/postfix-queues/corrupt;
#fi
#
#chown -R postfix.root /shared-mount/postfix-queues/active
#chown -R postfix.root /shared-mount/postfix-queues/corrupt
#chown -R postfix.root /shared-mount/postfix-queues/deferred
#chown -R postfix.root /shared-mount/postfix-queues/hold
#chown -R postfix.root /shared-mount/postfix-queues/incoming
#chown -R postfix.postdrop /shared-mount/postfix-queues/maildrop

if [ -d "$shared_dir/queue_dir" ]
then
   echo "exists";
else
   mkdir $shared_dir/queue_dir;
fi

mv /var/spool/postfix /var/spool/postfix-container
ln -s $shared_dir/queue_dir /var/spool/postfix

if [ -d "$shared_dir/queue_dir/opendkim" ]
then
   echo "exists";
else
   mkdir $shared_dir/queue_dir/opendkim;
fi


chown opendkim.postfix $shared_dir/queue_dir/opendkim

mv /etc/dovecot/conf.d /etc/dovecot/conf.d-docker-container
ln -s /shared-mount/dovecot-conf /etc/dovecot/conf.d
mv /var/mail /var/mail-container
ln -s $shared_dir/postfix-mail /var/mail
service syslog-ng start 
status=$?
if [ $status -ne 0 ]; then
    echo "Failed to start syslog-ng: $status"
    exit $status
fi



# Start the first process
env > /etc/.cronenv
rm /etc/cron.d/dockercron
#ln -s /shared-mount/postfix-conf/dockercron /etc/cron.d/dockercron
cp /shared-mount/postfix-conf/dockercron /etc/cron.d/dockercron

service cron start 
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

# queue directory
#mv /var/spool/postfix/maildrop /var/spool/postfix/maildrop-container
#mv /var/spool/postfix/hold /var/spool/postfix/hold-container
#mv /var/spool/postfix/incoming /var/spool/postfix/incoming-container
#mv /var/spool/postfix/active /var/spool/postfix/active-container
#mv /var/spool/postfix/deferred /var/spool/postfix/deferred-container
#mv /var/spool/postfix/corrupt /var/spool/postfix/corrupt-container
#ln -s $shared_dir/postfix-queues/maildrop /var/spool/postfix/maildrop
#ln -s $shared_dir/postfix-queues/hold /var/spool/postfix/hold
#ln -s $shared_dir/postfix-queues/incoming /var/spool/postfix/incoming
#ln -s $shared_dir/postfix-queues/active /var/spool/postfix/active
#ln -s $shared_dir/postfix-queues/deferred /var/spool/postfix/deferred
#ln -s $shared_dir/postfix-queues/corrupt /var/spool/postfix/corrupt



#


chown -R opendkim.opendkim $shared_dir/opendkim
chown -R www-data.www-data $shared_dir/postfix-conf
chown -R www-data.www-data $shared_dir/run.container
chown -R www-data.www-data $shared_dir/sync_relays.sh
chown -R www-data.www-data $shared_dir/account_manager.sh
chown -R www-data.www-data $shared_dir/accounts.txt
chown -R www-data.www-data $shared_dir/dovecot-conf
chown -R www-data.www-data $shared_dir/keys
chmod -R 0600 $shared_dir/keys
# queue dir
chmod 777 $shared_dir/queue_dir
chown -R postfix $shared_dir/queue_dir/active
chmod 0700 $shared_dir/queue_dir/active
chown -R postfix $shared_dir/queue_dir/bounce
chmod 0700 $shared_dir/queue_dir/bounce
chown -R postfix $shared_dir/queue_dir/corrupt
chmod 0700 $shared_dir/queue_dir/corrupt
chown -R postfix $shared_dir/queue_dir/defer
chmod 0700 $shared_dir/queue_dir/defer
chown -R postfix $shared_dir/queue_dir/deferred
chmod 0700 $shared_dir/queue_dir/deferred
chown -R postfix $shared_dir/queue_dir/flush
chmod 0700 $shared_dir/queue_dir/flush
chown -R postfix $shared_dir/queue_dir/hold
chmod 0700 $shared_dir/queue_dir/hold
chown -R postfix $shared_dir/queue_dir/incoming
chmod 0700 $shared_dir/queue_dir/incoming
chown -R postfix.postdrop $shared_dir/queue_dir/maildrop
chmod 0730 $shared_dir/queue_dir/maildrop
chown -R opendkim.postfix $shared_dir/queue_dir/opendkim
chmod 0755  $shared_dir/queue_dir/opendkim
chown -R postfix $shared_dir/queue_dir/private
chmod 0700 $shared_dir/queue_dir/private
chown -R postfix.postdrop $shared_dir/queue_dir/public
chmod 0710 $shared_dir/queue_dir/public
chown -R postfix $shared_dir/queue_dir/saved
chmod 0700 $shared_dir/queue_dir/saved
chown -R postfix $shared_dir/queue_dir/trace
chmod 0700 $shared_dir/queue_dir/trace

# queue directory


echo mail-relay-container > /etc/mailname
#postmap /etc/postfix/sasl/sasl_passwd

service opendkim start 
status=$?
if [ $status -ne 0 ]; then
          echo "Failed to start opendkim: $status"
    exit $status
fi

service postfix start 
status=$?
if [ $status -ne 0 ]; then
	  echo "Failed to start postfix: $status"
    exit $status
fi

# Start the second process
service dovecot start 
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start dovecot: $status"
  exit $status
fi


/etc/init.d/ssh start
ssh_status=$?
if [ $ssh_status -ne 0 ]; then
  echo "Failed to start ssh: $ssh_status"
  exit $ssh_status
fi

/etc/init.d/fail2ban start 
fail2ban_status=$?
if [ $fail2ban_status -ne 0 ]; then
  echo "Failed to start fail2ban: $fail2ban_status"
  exit $fail2ban_status
else
   sleep 10;
   fail2ban-client add dovevot
   fail2ban-client add postfix
fi


bash
