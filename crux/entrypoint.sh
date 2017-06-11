#!/bin/bash
set -eo pipefail

if [ -z "$ACCEPT_ORACLE_LICENSE" ]; then
  echo >&2 'You need to include ACCEPT_ORACLE_LICENSE=true in order to start this container.'
  echo >&2 'Visit http://www.oracle.com/technetwork/java/javase/terms/license/index.html'
  exit 1
fi

if [ -z "$USER_PASSWORD" ]; then
  echo >&2 'You need to specify USER_PASSWORD'
  exit 1
fi

if [ "$USER_NAME" ]; then
  # username specifically provided, will overwrite 'mc'
  if [[ "$USER_NAME" =~ [^a-zA-Z0-9] ]]; then
    echo >&2 'USER_NAME must contain only alphanumerics [a-zA-Z0-9]'
    exit 1
  fi
else
  echo >&2 'USER_NAME not provided; defaulting to "mc"'
  USER_NAME=mc
fi

if [ "$USER_UID" ]; then
  # uid specifically provided, will overwrite 1000 default
  if [[ "$USER_UID" =~ [^0-9] ]]; then
    echo >&2 'USER_UID must contain only numerics [0-9]'
    exit 1
  fi
else
  USER_UID=1000
fi

useradd -Ums /bin/false -u $USER_UID $USER_NAME
echo "$USER_NAME:$USER_PASSWORD" | chpasswd
echo >&2 "Created user: $USER_NAME"

if [ ! -f /etc/ssl/certs/mineos.crt ]; then
  echo >&2 "Generating Self-Signed SSL..."
  sh /usr/games/minecraft/generate-sslcert.sh
fi

cd /usr/games/minecraft && git fetch && git merge origin/master

#download and install oracle java
mkdir /root/java
cd /root/java
wget -c --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u74-b02/server-jre-8u74-linux-x64.tar.gz
tar -xf server-jre-8u74-linux-x64.tar.gz
mv /root/java/jdk1.8.0_74 /usr/java
cd /root
rm -rf /root/java
ln -s /usr/java/jre/bin/java /usr/bin/java

exec "$@"
