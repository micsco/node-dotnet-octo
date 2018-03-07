FROM node:9

# OPTIONAL: Install dumb-init (Very handy for easier signal handling of SIGINT/SIGTERM/SIGKILL etc.)
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb
ENTRYPOINT ["dumb-init"]

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable
RUN google-chrome --version


CMD ["google-chrome-stable", "google-chrome"]

# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

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
RUN yarn global add puppeteer@1.1