# Prepare the base environment.
FROM ubuntu:20.04 as builder_base_docker
MAINTAINER itadmin@digitalreach.com.au 
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Perth
ENV PRODUCTION_EMAIL=True
ENV SECRET_KEY="ThisisNotRealKey"
RUN apt-get clean
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install --no-install-recommends -y curl wget git libmagic-dev gcc binutils libproj-dev gdal-bin tzdata cron rsyslog net-tools 
RUN apt-get install --no-install-recommends -y postfix dovecot-imapd libsasl2-modules syslog-ng syslog-ng-core mailutils postfix-pcre postfix-policyd-spf-python
RUN apt-get install --no-install-recommends -y opendkim opendkim-tools
RUN apt-get install -y vim telnet
# Example Self Signed Cert
RUN apt-get install -y openssl
RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj  "/C=AU/ST=Western Australia/L=Perth/O=Digital Reach Insight/OU=IT Department/CN=example.com"  -keyout /etc/ssl/private/selfsignedssl.key -out /etc/ssl/private/selfsignedssl.crt
# Install Python libs from requirements.txt.
FROM builder_base_docker as python_libs_docker
WORKDIR /app
# Install the project (ensure that frontend projects have been built prior to this step).
FROM python_libs_docker
# Set  local perth time
RUN gpasswd -a postfix opendkim
RUN mkdir /var/spool/postfix/opendkim
RUN chown opendkim:postfix /var/spool/postfix/opendkim

COPY timezone /etc/timezone
ENV TZ=Australia/Perth
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN touch /app/.env
COPY boot.sh /
RUN touch /etc/cron.d/dockercron
RUN cron /etc/cron.d/dockercron
RUN chmod 755 /boot.sh
EXPOSE 25
#HEALTHCHECK --interval=5s --timeout=2s CMD ["wget", "--timeout=15", "--tries=3", "-q", "-O", "-", "http://localhost:80/"]
CMD ["/boot.sh"]
