FROM node:9.2

RUN apt-get update -qq

# Install libunwind
RUN apt-get install libunwind8 -y

ADD install_dotnet_and_octo.sh /root/install_dotnet_and_octo.sh
RUN chmod +x /root/install_dotnet_and_octo.sh
RUN /root/install_dotnet_and_octo
