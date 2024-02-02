FROM debian:12-slim
LABEL maintainer="melroy.bouwes@outlook.com"
LABEL version="2.2"

WORKDIR /hak5c2

# Update and install Packages
RUN apt-get -y update && apt-get install wget sudo unzip curl -y --no-install-recommends
RUN apt-get install ca-certificates -y
RUN apt-get autoremove -y && apt-get clean -y 

# Download latest version
RUN curl -L https://downloads.hak5.org/api/devices/cloudc2/firmwares/latest --output c2.zip 
RUN unzip -qq c2.zip

# Download cracked binary
RUN wget https://github.com/Pwn3rzs/HAK5-C2-License-Toolkit/releases/download/v3.3.0/c2-3.3.0_amd64_linux -O cc2_linux 
RUN chmod +x cc2_linux

# Download Toolkit
RUN wget https://github.com/Pwn3rzs/HAK5-C2-License-Toolkit/releases/download/v3.3.0/HAK5-C2-Toolkit-lin-amd64 -O c2_toolkit
RUN chmod +x c2_toolkit


# Copy file to standard name
RUN find / -type f -name "*_amd64_linux" -exec cp {} /hak5c2/c2_linux \;
RUN echo "#!/bin/bash" > start.sh
RUN echo 'chmod 776 $database' >> start.sh
RUN echo './$c2executable -hostname $c2hostname -listenip $listenip -listenport $listenport -db $database -sshport $sshport -reverseProxyPort $reverseProxyPort $additional' >> start.sh
RUN chmod +x start.sh

EXPOSE 8080/tcp 2022/tcp

ENV c2executable c2_linux
ENV c2hostname c2.example.com
ENV listenip 0.0.0.0
ENV listenport 8080
ENV sshport 2022
ENV database /data/c2.db
ENV reverseProxyPort 443
ENV additional "-https -debug -reverseProxy"

VOLUME ["/data"]

CMD ["/hak5c2/start.sh"]
