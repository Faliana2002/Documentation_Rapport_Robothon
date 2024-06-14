FROM ubuntu:22.04

# install packages
# note : need ca-certificates to use wget and curl (https://stackoverflow.com/questions/58338266/curl-certificate-fail-in-docker-container)
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    build-essential \
    nano \
    wget \
    curl \
    zsh \
    bash \
    ca-certificates \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# install sphinx
RUN python3 -m pip install -U sphinx
COPY ./requirements.txt /
RUN python3 -m pip install -r /requirements.txt

# for mermaid diagrams
# https://github.com/mermaid-js/mermaid-cli/issues/587
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @mermaid-js/mermaid-cli

# https://stackoverflow.com/questions/66070860/puppeteer-error-error-while-loading-shared-libraries-libgobject-2-0-so-0
# car pb : "error while loading shared libraries: libgobject-2.0.so.0: cannot open shared object file: No such file or directory"
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# RUN apt-get update && \
#     curl -fsSL https://deb.nodesource.com/setup_20.x | apt install -y nodejs \
#     && rm -rf /var/lib/apt/lists/*

# RUN apt-get update && apt-get install -q -y --no-install-recommends \
#     npm \
#     && rm -rf /var/lib/apt/lists/*

# RUN npm install -g @mermaid-js/mermaid-cli

# install zsh and oh-my-zsh (https://gist.github.com/MichalZalecki/4a87880bbe7a3a5428b5aebebaa5cd97)
ENV TERM xterm
ENV ZSH_THEME agnoster 
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# zsh
COPY ./setup.zsh /
RUN echo "source /setup.zsh">>/root/.zshrc

CMD [ "zsh" ]
