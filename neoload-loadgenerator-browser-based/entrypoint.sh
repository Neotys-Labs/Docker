#!/bin/bash


#https://github.com/fabric8io-images/java/blob/master/images/alpine/openjdk8/jre/run-java.sh
max_memory() {
  # High number which is the max limit until which memory is supposed to be unbounded.
  local mem_file="/sys/fs/cgroup/memory/memory.limit_in_bytes"
  if [ -r "${mem_file}" ]; then
    local max_mem_cgroup="$(cat ${mem_file})"
    local max_mem_meminfo_kb="$(cat /proc/meminfo | awk '/MemTotal/ {print $2}')"
    local max_mem_meminfo="$(expr $max_mem_meminfo_kb \* 1024)"
    if [ ${max_mem_cgroup:-0} != -1 ] && [ ${max_mem_cgroup:-0} -lt ${max_mem_meminfo:-0} ]
    then
      echo "${max_mem_cgroup}"
    fi
  fi
}

init_limit_env_vars() {
  local mem_limit="$(max_memory)"
  if [ -n "${mem_limit}" ]; then
    export CONTAINER_MAX_MEMORY="${mem_limit}"
  fi
}

# Generic formula evaluation based on awk
calc() {
  local formula="$1"
  shift
  echo "$@" | awk '
    function ceil(x) {
      return x % 1 ? int(x) + 1 : x
    }
    function log2(x) {
      return log(x)/log(2)
    }
    function max2(x, y) {
      return x > y ? x : y
    }
    function round(x) {
      return int(x + 0.5)
    }
    {print '"int(${formula})"'}
  '
}

if [ `id -u` -ge 10000 ]; then
	cat /etc/passwd | sed -e "s/^neoload:/builder:/" > /tmp/passwd
	echo "neoload:x:`id -u`:`id -g`:,,,:/home/neoload:/bin/bash" >> /tmp/passwd
	cat /tmp/passwd > /etc/passwd
	rm /tmp/passwd
fi

if [[ ! "${LOADGENERATOR_XMX}" ]]; then
    init_limit_env_vars
    mmemory=$(calc 'round($1*$2/100/1048576)' "${CONTAINER_MAX_MEMORY}" "50")
    if [[ $mmemory -gt 0 ]]; then
        LOADGENERATOR_XMX="-Xmx$(($mmemory))m"
    fi
fi

if [[ "${AGENT_XMX}" ]]; then
    sed -i "s/-Xmx512m/${AGENT_XMX}/g" /home/neoload/neoload/bin/LoadGeneratorAgent.vmoptions
fi

if [ "${NEOLOADWEB_URL}" ]; then
    export NLWEB_API_URL=${NEOLOADWEB_URL}
fi
if [ "${NEOLOADWEB_TOKEN}" ]; then
    export NLWEB_TOKEN=${NEOLOADWEB_TOKEN}
fi
if [ "${NEOLOADWEB_PROXY}" ]; then
    export NLWEB_PROXY=${NEOLOADWEB_PROXY}
fi
if [ "${ACCEPT_ONLY}" ]; then
    export ACCEPT_ONLY=${ACCEPT_ONLY}
fi


sed -i "s/lg.launcher.vm.parameters=-server/lg.launcher.vm.parameters=$LOADGENERATOR_XMX -server/g" /home/neoload/neoload/conf/agent.properties

exec /home/neoload/neoload/bin/LoadGeneratorAgent -d
