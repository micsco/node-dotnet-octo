FROM node:9

# Install libunwind
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libunwind8  \
    && rm -rf /var/lib/apt/lists/*

# Dotnet and Octo Script
ADD install_dotnet_and_octo.sh /root/install_dotnet_and_octo.sh
RUN chmod +x /root/install_dotnet_and_octo.sh
RUN /root/install_dotnet_and_octo.sh

ENV PATH="/root/.octo:${PATH}"
ENV PATH="/root/.dotnet:${PATH}"

# Install gulp globally
RUN yarn global add gulp@4 && \
    yarn cache clean && \
    rm -rf /tmp/*