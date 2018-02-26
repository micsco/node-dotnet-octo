FROM node:9

# Install libunwind
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libunwind8  \
        libnss3 \
        libxss1 \
        libasound2 \
        libpangocairo-1.0-0 \
        libx11-xcb-dev \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxi6 \
        libxtst6 \
        libcups2 \
        libxrandr-dev \
        libgconf-2-4 \
        libatk1.0-0 \
        libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y 

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

# Install puppeteer (no delete cache)
RUN yarn global install puppeteer@1.1