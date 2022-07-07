#!/bin/bash
# Inspired from https://github.com/justb4/docker-jmeter
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#

# Install jmeter plugins available on /plugins volume
java  -jar "${CMD_RUNNER_BIN}" --tool org.jmeterplugins.repository.PluginManagerCMD install "${JMETER_PLUGINMANAGER_PLUGINS}"

# Execute JMeter command
set -e
freeMem=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
s=$((freeMem/10*8/1024/1024)) # 80% in MB
x=$((freeMem/10*8/1024/1024)) # 80% in MB
n=$((freeMem/10*2/1024/1024)) # 20% in MB
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter on $(date)"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$*"

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS="-Dlog4j2.formatMsgNoLookups=true -n -j /dev/stdout -t ${JMETER_TESTPLAN_LOCATION} -q ${JMETER_PROPERTIES_LOCATION}"
echo "jmeter ALL ARGS=${EXTRA_ARGS} $*"
jmeter ${EXTRA_ARGS} "$@"

echo "END Running Jmeter on $(date)"
