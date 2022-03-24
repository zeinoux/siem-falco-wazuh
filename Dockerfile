FROM debian:buster

LABEL maintainer="cncf-falco-dev@lists.cncf.io"

LABEL usage="docker run -i -t --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro -v /etc:/host/etc --name NAME IMAGE"


# default version is latest trying to change old version
ARG FALCO_VERSION=0.31.0
ARG VERSION_BUCKET=deb
ENV VERSION_BUCKET=${VERSION_BUCKET}

ENV FALCO_VERSION=${FALCO_VERSION}
ENV HOST_ROOT /host
ENV HOME /root

RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	bash-completion \
	bc \
	bison \
	clang-7 \
	ca-certificates \
	curl \
	dkms \
	flex \
	gnupg2 \
	gcc \
	jq \
	libc6-dev \
	libelf-dev \
	libmpx2 \
	libssl-dev \
	llvm-7 \
	netcat \
	xz-utils \
	&& rm -rf /var/lib/apt/lists/*

# gcc 6 is no longer included in debian stable, but we need it to
# build kernel modules on the default debian-based ami used by
# kops. So grab copies we've saved from debian snapshots with the
# prefix https://snapshot.debian.org/archive/debian/20170517T033514Z
# or so.

RUN curl -L -o cpp-6_6.3.0-18_amd64.deb https://download.falco.org/dependencies/cpp-6_6.3.0-18_amd64.deb \
	&& curl -L -o gcc-6-base_6.3.0-18_amd64.deb https://download.falco.org/dependencies/gcc-6-base_6.3.0-18_amd64.deb \
	&& curl -L -o gcc-6_6.3.0-18_amd64.deb https://download.falco.org/dependencies/gcc-6_6.3.0-18_amd64.deb \
	&& curl -L -o libasan3_6.3.0-18_amd64.deb https://download.falco.org/dependencies/libasan3_6.3.0-18_amd64.deb \
	&& curl -L -o libcilkrts5_6.3.0-18_amd64.deb https://download.falco.org/dependencies/libcilkrts5_6.3.0-18_amd64.deb \
	&& curl -L -o libgcc-6-dev_6.3.0-18_amd64.deb https://download.falco.org/dependencies/libgcc-6-dev_6.3.0-18_amd64.deb \
	&& curl -L -o libubsan0_6.3.0-18_amd64.deb https://download.falco.org/dependencies/libubsan0_6.3.0-18_amd64.deb \
	&& curl -L -o libmpfr4_3.1.3-2_amd64.deb https://download.falco.org/dependencies/libmpfr4_3.1.3-2_amd64.deb \
	&& curl -L -o libisl15_0.18-1_amd64.deb https://download.falco.org/dependencies/libisl15_0.18-1_amd64.deb \
	&& dpkg -i cpp-6_6.3.0-18_amd64.deb gcc-6-base_6.3.0-18_amd64.deb gcc-6_6.3.0-18_amd64.deb libasan3_6.3.0-18_amd64.deb libcilkrts5_6.3.0-18_amd64.deb libgcc-6-dev_6.3.0-18_amd64.deb libubsan0_6.3.0-18_amd64.deb libmpfr4_3.1.3-2_amd64.deb libisl15_0.18-1_amd64.deb \
	&& rm -f cpp-6_6.3.0-18_amd64.deb gcc-6-base_6.3.0-18_amd64.deb gcc-6_6.3.0-18_amd64.deb libasan3_6.3.0-18_amd64.deb libcilkrts5_6.3.0-18_amd64.deb libgcc-6-dev_6.3.0-18_amd64.deb libubsan0_6.3.0-18_amd64.deb libmpfr4_3.1.3-2_amd64.deb libisl15_0.18-1_amd64.deb

# gcc 5 is no longer included in debian stable, but we need it to
# build centos kernels, which are 3.x based and explicitly want a gcc
# version 3, 4, or 5 compiler. So grab copies we've saved from debian
# snapshots with the prefix https://snapshot.debian.org/archive/debian/20190122T000000Z.

RUN curl -L -o cpp-5_5.5.0-12_amd64.deb https://download.falco.org/dependencies/cpp-5_5.5.0-12_amd64.deb \
	&& curl -L -o gcc-5-base_5.5.0-12_amd64.deb https://download.falco.org/dependencies/gcc-5-base_5.5.0-12_amd64.deb \
	&& curl -L -o gcc-5_5.5.0-12_amd64.deb https://download.falco.org/dependencies/gcc-5_5.5.0-12_amd64.deb \
	&& curl -L -o libasan2_5.5.0-12_amd64.deb	https://download.falco.org/dependencies/libasan2_5.5.0-12_amd64.deb \
	&& curl -L -o libgcc-5-dev_5.5.0-12_amd64.deb https://download.falco.org/dependencies/libgcc-5-dev_5.5.0-12_amd64.deb \
	&& curl -L -o libisl15_0.18-4_amd64.deb https://download.falco.org/dependencies/libisl15_0.18-4_amd64.deb \
	&& curl -L -o libmpx0_5.5.0-12_amd64.deb https://download.falco.org/dependencies/libmpx0_5.5.0-12_amd64.deb \
	&& dpkg -i cpp-5_5.5.0-12_amd64.deb gcc-5-base_5.5.0-12_amd64.deb gcc-5_5.5.0-12_amd64.deb libasan2_5.5.0-12_amd64.deb libgcc-5-dev_5.5.0-12_amd64.deb libisl15_0.18-4_amd64.deb libmpx0_5.5.0-12_amd64.deb \
	&& rm -f cpp-5_5.5.0-12_amd64.deb gcc-5-base_5.5.0-12_amd64.deb gcc-5_5.5.0-12_amd64.deb libasan2_5.5.0-12_amd64.deb libgcc-5-dev_5.5.0-12_amd64.deb libisl15_0.18-4_amd64.deb libmpx0_5.5.0-12_amd64.deb

# Since our base Debian image ships with GCC 7 which breaks older kernels, revert the
# default to gcc-5.
RUN rm -rf /usr/bin/gcc && ln -s /usr/bin/gcc-5 /usr/bin/gcc

RUN rm -rf /usr/bin/clang \
	&& rm -rf /usr/bin/llc \
	&& ln -s /usr/bin/clang-7 /usr/bin/clang \
	&& ln -s /usr/bin/llc-7 /usr/bin/llc

RUN curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add - \
	&& echo "deb https://download.falco.org/packages/${VERSION_BUCKET} stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list \
	&& apt-get update -y \
	&& if [ "$FALCO_VERSION" = "latest" ]; then apt-get install -y --no-install-recommends falco; else apt-get install -y --no-install-recommends falco=${FALCO_VERSION}; fi \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Change the falco config within the container to enable ISO 8601
# output.
RUN sed -e 's/time_format_iso_8601: false/time_format_iso_8601: true/' < /etc/falco/falco.yaml > /etc/falco/falco.yaml.new \
	&& mv /etc/falco/falco.yaml.new /etc/falco/falco.yaml

# Some base images have an empty /lib/modules by default
# If it's not empty, docker build will fail instead of
# silently overwriting the existing directory
RUN rm -df /lib/modules \
	&& ln -s $HOST_ROOT/lib/modules /lib/modules

# debian:stable head contains binutils 2.31, which generates
# binaries that are incompatible with kernels < 4.16. So manually
# forcibly install binutils 2.30-22 instead.
RUN curl -L -o binutils_2.30-22_amd64.deb https://download.falco.org/dependencies/binutils_2.30-22_amd64.deb \
	&& curl -L -o libbinutils_2.30-22_amd64.deb https://download.falco.org/dependencies/libbinutils_2.30-22_amd64.deb \
	&& curl -L -o binutils-x86-64-linux-gnu_2.30-22_amd64.deb https://download.falco.org/dependencies/binutils-x86-64-linux-gnu_2.30-22_amd64.deb \
	&& curl -L -o binutils-common_2.30-22_amd64.deb https://download.falco.org/dependencies/binutils-common_2.30-22_amd64.deb \
	&& dpkg -i *binutils*.deb \
	&& rm -f *binutils*.deb

#COPY ./docker-entrypoint.sh /

#ENTRYPOINT ["/docker-entrypoint.sh"]

#CMD ["/usr/bin/falco"]


# added wazuh-agent setup section

RUN sleep 2 && echo "# Wazuh-agent setup section"

RUN apt -y update && \
    apt --fix-broken install -y && \
    apt -y install \
    #added proto test
    sudo \
    # 
    build-essential \
    tzdata \
    lsb-release \
    gnupg2 \
    python3-pip \
    python3 \
    gettext \
    gzip \
    unzip \
    zip \
    bzip2 \
    awscli \
    locales \
    curl \
    telnet \
    netcat \
    vim \
    systemd \
    apt-transport-https \
    ca-certificates \
    gcc \
    git \
    libpq-dev \
    make \
    python\
    cmake \
    python-dev \
    software-properties-common

RUN python --version


RUN apt-get install apt-file -y && \
    apt-file update && \
    # install setup tools & pip
    curl https://raw.githubusercontent.com/pypa/setuptools/bootstrap/ez_setup.py | python - && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python -

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && \
    # add repo to repolist.
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list


RUN apt update && \
    #installing pip for docker.
    pip install --upgrade pip && \
    pip install --no-cache-dir docker docker-py && \
    pip3 install --no-cache-dir docker docker-py && \
    apt-get install docker-ce-cli wazuh-agent -y && \
    apt-get clean && \
    apt autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*



COPY agent /agent
COPY agent/falco.yaml  /etc/falco/
COPY agent/falcolog /etc/logrotate.d/falcolog

ENTRYPOINT ["/agent/entrypoint.sh"]
