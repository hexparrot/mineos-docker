FROM ubuntu:hirsute-20210522

LABEL org.opencontainers.image.authors="William Dizon <wdchromium@gmail.com>, Jez Tucker <jez@tucks.org.uk>"
LABEL description="Dockerised mineos-node"

# Install the base OS without user interaction
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  supervisor \
  rdiff-backup \
  screen \
  openjdk-16-jre-headless \
  rsync \
  git \
  curl \
  rlwrap \
  build-essential \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the local timezone
RUN ln -snf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Download mineos-node from github
RUN mkdir -p /usr/games \
  && cd /usr/games \
  && git clone https://github.com/hexparrot/mineos-node.git minecraft \
  && cd minecraft \
  && git config core.filemode false \
  && chmod +x service.js mineos_console.js generate-sslcert.sh webui.js \
  && npm install --unsafe-perm \
  && ln -s /usr/games/minecraft/mineos_console.js /usr/local/bin/mineos \
  && cp mineos.conf /etc/mineos.conf 

# Ensure mineos-node node.js server starts up on boot
# Ubuntu requires privileged containers to use systemd, so we use supervisor instead
RUN cp /usr/games/minecraft/init/supervisor_conf /etc/supervisor/conf.d/mineos.conf 
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

# Generate a self-signed untrusted SSL cert
RUN cd /usr/games/minecraft \
  && ./generate-sslcert.sh

# Remove no longer required packages and cache files to shrink the image 
RUN apt-get remove --purge -y build-essential \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Entrypoint allowing for setting of mc password
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose port 8443 for web management, 25565-25570 for Minecraft servers
EXPOSE 8443 25565-25570
VOLUME /var/games/minecraft

# Defaults for startup
ENV USER_PASSWORD=random_see_log USER_NAME=mc USER_UID=1000 USE_HTTPS=true SERVER_PORT=8443

# EOF

