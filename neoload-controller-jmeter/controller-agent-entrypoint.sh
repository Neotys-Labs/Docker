#!/bin/sh

runAgent() {
    : ${NEOLOADWEB_TOKEN?"Need to set NEOLOADWEB_TOKEN"}

    if [[ ! "${CONTROLLER_XMX}" ]]; then
        init_limit_env_vars
        mmemory=$(calc 'round($1*$2/100/1048576)' "${CONTAINER_MAX_MEMORY}" "50")
        if [[ $mmemory -gt 0 ]]; then
            CONTROLLER_XMX="-Xmx$(($mmemory))m"
        fi
    fi

    if [[ "${AGENT_XMX}" ]]; then
        sed -i "s/-Xmx512m/${AGENT_XMX}/g" /home/neoload/neoload/bin/ControllerAgent.vmoptions
    fi

    if [ "${NEOLOADWEB_URL}" ]; then
        export NLWEB_API_URL=${NEOLOADWEB_URL}
    fi
    if [ "${NEOLOADWEB_PROXY}" ]; then
        export NLWEB_PROXY=${NEOLOADWEB_PROXY}
    fi

    export NLWEB_TOKEN=${NEOLOADWEB_TOKEN}

    echo $CONTROLLER_XMX >> /home/neoload/neoload/bin/NeoLoadCmd.vmoptions

    exec /home/neoload/neoload/bin/ControllerAgent -d
}
