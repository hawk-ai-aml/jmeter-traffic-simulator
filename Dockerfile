# inspired by https://github.com/justb4/docker-jmeter
FROM alpine:3.15

ARG JMETER_VERSION="5.5"
ARG CMD_RUNNER_VERSION="2.3"
ARG JMETER_PLUGIN_MANAGER_VERSION="1.7"
ARG JMETER_PROMETHEUS_PLUGIN_VERSION="2.3.1"
ENV JMETER_PLUGINMANAGER_PLUGINS="jmeter-prometheus,jpgc-dummy"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_TESTPLAN_LOCATION /jmeter/jmeter-testplan.jmx
ENV JMETER_PROPERTIES_LOCATION /jmeter/jmeter.properties
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV CMD_RUNNER_BIN ${JMETER_HOME}/lib/cmdrunner-${CMD_RUNNER_VERSION}.jar

# Install extra packages
# Set TimeZone, See: https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-612751142
ARG TZ="Europe/Amsterdam"
ENV TZ ${TZ}
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies \
    && rm -rf ${JMETER_HOME}/docs \
    && rm -rf ${JMETER_HOME}/printable_docs \
    && curl -O --output-dir ${JMETER_HOME}/lib https://repo1.maven.org/maven2/kg/apc/cmdrunner/${CMD_RUNNER_VERSION}/cmdrunner-${CMD_RUNNER_VERSION}.jar \
    && curl -O --output-dir ${JMETER_HOME}/lib/ext https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/${JMETER_PLUGIN_MANAGER_VERSION}/jmeter-plugins-manager-${JMETER_PLUGIN_MANAGER_VERSION}.jar \
    && wget -P ${JMETER_HOME}/lib/ext https://github.com/kolesnikovm/jmeter-prometheus-listener/releases/download/${JMETER_PROMETHEUS_PLUGIN_VERSION}/jmeter-prometheus-listener-${JMETER_PROMETHEUS_PLUGIN_VERSION}.jar \
    && java  -jar ${CMD_RUNNER_BIN} --tool org.jmeterplugins.repository.PluginManagerCMD install ${JMETER_PLUGINMANAGER_PLUGINS}

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

COPY files/* /jmeter/files/
COPY jmeter.properties /jmeter
COPY jmeter-testplan.jmx /jmeter

# Entrypoint has same signature as "jmeter" command
COPY entrypoint.sh /

RUN chmod +x entrypoint.sh

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/entrypoint.sh"]