FROM node:9.2

RUN apt-get update -qq

# Install libunwind
RUN apt-get install libunwind8 -y

# Dotnet and Octo Script
ADD install_dotnet_and_octo.sh /root/install_dotnet_and_octo.sh
RUN chmod +x /root/install_dotnet_and_octo.sh
RUN /root/install_dotnet_and_octo.sh

# Install gulp globally
RUN npm install -g gulp@4 --unsafe-perm