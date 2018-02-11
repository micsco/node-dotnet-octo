FROM node:9.2

RUN apt-get update -qq

# Install libunwind
RUN apt-get install libunwind8 -y

ADD install_dotnet_and_octo.sh /
RUN chmod +x /install_dotnet_and_octo.sh
RUN /install_dotnet_and_octo
