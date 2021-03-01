# FROM python:3.7.9-buster
FROM python

LABEL maintainer="chefbc"

RUN mkdir -p /opt/mysql-shell/
# COPY ./requirements.txt /opt/mysql-shell/

WORKDIR /opt/mysql-shell/

RUN pip --no-cache-dir install --upgrade pip
# RUN pip install -r requirements.txt

# RUN apt-get update
# RUN apt-get install -y dnsutils
# RUN apt-get install -y default-mysql-client

# RUN apt-get update && apt-get install -y --no-install-recommends gnupg libaio1 vim dnsutils netcat

RUN apt-get update && apt-get -y --no-install-recommends install \
	gnupg \
	libaio1 \
	vim \
	dnsutils \
	netcat \
	python3-requests \
	locales \
	locales-all \
	&& rm -rf /var/lib/apt/lists/*

# https://leimao.github.io/blog/Docker-Locale/
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN set -ex; \
# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	apt-key list > /dev/null

ENV MYSQL_MAJOR 8.0
ENV MYSQL_VERSION 8.0.23-1debian10

RUN echo "deb http://repo.mysql.com/apt/debian/ buster mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list
RUN echo "deb http://repo.mysql.com/apt/debian/ buster mysql-tools" > /etc/apt/sources.list.d/mysql-tools.list
#RUN echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-apt-config" > /etc/apt/sources.list.d/mysql.list
#RUN echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
# also, we set debconf keys to make APT a little quieter
RUN apt-get update && apt-get install -y mysql-common && apt-get install -y mysql-community-client="${MYSQL_VERSION}" && apt-get install -y mysql-shell="${MYSQL_VERSION}"

# make the nicer mysql prompt
# RUN mkdir ~/.mysqlsh && cp /usr/share/mysqlsh/prompt/prompt_256pl+aw.json ~/.mysqlsh/prompt.json

RUN mkdir -p ~/.mysqlsh/plugins
RUN git clone https://github.com/lefred/mysqlshell-plugins.git ~/.mysqlsh/plugins

# COPY config/prompt_256.json /root/.mysqlsh/prompt.json # update this file
RUN cp /usr/share/mysqlsh/prompt/prompt_256.json ~/.mysqlsh/prompt.json

COPY config/options.json /root/.mysqlsh/.
#COPY config/mysqlshrc.py /root/.mysqlsh/.

COPY docker-entrypoint.sh /entrypoint.sh

