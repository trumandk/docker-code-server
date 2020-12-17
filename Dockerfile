FROM ghcr.io/linuxserver/baseimage-ubuntu:focal
RUN apt-get update
RUN apt-get install software-properties-common -y
RUN add-apt-repository universe
RUN apt-get update
RUN apt-get install python2 -y

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV HOME="/config"


RUN \
 echo "**** install node repo ****"
RUN apt-get update
RUN apt-get install -y \
	gnupg 
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - 
RUN echo 'deb https://deb.nodesource.com/node_12.x focal main' > /etc/apt/sources.list.d/nodesource.list
RUN curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - 
RUN echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN echo "**** install build dependencies ****"
RUN apt-get update
RUN apt-get install -y \
	build-essential \
	docker.io \
	docker-compose \
	wget \
	golang \
	vim \
	libx11-dev \
	libxkbfile-dev \
	libsecret-1-dev \
	pkg-config
RUN echo "**** install runtime dependencies ****" 
RUN apt-get install -y \
	git \
	jq \
	nano \
	net-tools \
	nodejs \
	sudo \
	yarn 
RUN echo "**** install code-server ****" && \
 if [ -z ${CODE_RELEASE+x} ]; then \
	CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/cdr/code-server/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
 yarn config set network-timeout 600000 -g && \
 yarn --production --verbose --frozen-lockfile global add code-server@"$CODE_VERSION" && \
 yarn cache clean && \
 echo "**** clean up ****" 
RUN apt-get purge --auto-remove -y \
	build-essential \
	libx11-dev \
	libxkbfile-dev \
	libsecret-1-dev \
	pkg-config && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root /
#ARG HOME='/config'
RUN wget https://github.com/microsoft/vscode-cpptools/releases/download/1.1.0/cpptools-linux-aarch64.vsix
RUN code-server --install-extension cpptools-linux-aarch64.vsix --extensions-dir /config/extensions/

RUN wget https://github.com/golang/vscode-go/releases/download/v0.18.1/go-0.18.1.vsix
RUN code-server --install-extension go-0.18.1.vsix --extensions-dir /config/extensions/

RUN wget https://github.com/microsoft/vscode-docker/releases/download/v1.7.0/vscode-docker-1.7.0.vsix
RUN code-server --install-extension vscode-docker-1.7.0.vsix --extensions-dir /config/extensions/

RUN wget https://github.com/microsoft/vscode-python/releases/download/2020.10.332292344/ms-python-release.vsix
RUN code-server --install-extension ms-python-release.vsix --extensions-dir /config/extensions/

RUN wget https://github.com/eamodio/vscode-gitlens/releases/download/v10.2.3/gitlens-10.2.3.vsix
RUN code-server --install-extension gitlens-10.2.3.vsix --extensions-dir /config/extensions/

RUN wget https://github.com/ChristianKohler/PathIntellisense/releases/download/v2.3.0/path-intellisense-2.3.0.vsix
RUN code-server --install-extension path-intellisense-2.3.0.vsix






# ports and volumes
EXPOSE 8443
