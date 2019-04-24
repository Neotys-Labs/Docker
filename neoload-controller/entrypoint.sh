#!/bin/sh

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


if [[ "${MODE}" == "Managed" ]]; then
    source /home/neoload/controller-agent-entrypoint.sh
    runAgent
else
    source /home/neoload/controller-entrypoint.sh
    runController
fi
