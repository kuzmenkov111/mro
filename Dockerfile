FROM ubuntu:trusty

ARG DEBIAN_FRONTED='noninteractive'

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8



## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
        wget \
	&& rm -rf /var/lib/apt/lists/*


WORKDIR /home/docker

# Download, valiate, and unpack and install Micrisift R open
RUN wget  https://www.dropbox.com/s/xrkzdhm1cq0ll1q/microsoft-r-open-3.3.2.tar.gz?dl=1 -O microsoft-r-open-3.3.2.tar.gz \
&& echo "817aca692adffe20e590fc5218cb6992f24f29aa31864465569057534bce42c7 microsoft-r-open-3.3.2.tar.gz" > checksum.txt \
	&& sha256sum -c --strict checksum.txt \
	&& tar -xf microsoft-r-open-3.3.2.tar.gz \
	&& cd /home/docker/microsoft-r-open \
	&& ./install.sh -a -u \
	&& ls logs && cat logs/*

