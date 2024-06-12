#!/bin/sh

runController() {
    : ${PROJECT_NAME?"Need to set PROJECT_NAME"}
    : ${SCENARIO?"Need to set SCENARIO"}
    : ${VU_MAX?"Need to set VU_MAX"}
    : ${DURATION_MAX?"Need to set DURATION_MAX"}
    : ${PUBLISH_RESULT?"Need to set PUBLISH_RESULT"}
    : ${COLLAB_URL?"Need to set COLLAB_URL"}

    PARAMS="-noGUI -checkoutProject "${PROJECT_NAME}" -launch \"${SCENARIO}\""


    if [[ "${LEASE_SERVER:-NTS}" == "NTS" ]]; then
        : ${LICENSE_ID?"Need to set LICENSE_ID"}
        : ${NTS_URL?"Need to set NTS_URL"}
        : ${NTS_LOGIN?"Need to set NTS_LOGIN"}

        PARAMS="$PARAMS -leaseServer NTS -NTS ${NTS_URL} -NTSLogin ${NTS_LOGIN} -leaseLicense ${LICENSE_ID}:${VU_MAX}:${DURATION_MAX}"
    else
        : ${NEOLOADWEB_TOKEN?"Need to set NEOLOADWEB_TOKEN"}
        PARAMS="$PARAMS -leaseServer NLWeb -leaseLicense ${VU_MAX}:${DURATION_MAX}"
    fi

    if [ "${PROJECT_PASSWORD}" ]; then
         PARAMS="$PARAMS -projectPassword ${PROJECT_PASSWORD}"
    fi

    if [ "${COLLAB_URL}" ]; then
        PARAMS="$PARAMS -Collab ${COLLAB_URL}"
    fi
    if [ "${COLLAB_LOGIN}" ]; then
        PARAMS="$PARAMS -CollabLogin ${COLLAB_LOGIN}"
    fi
    if [[ ${PUBLISH_RESULT} == "NTS" || ${PUBLISH_RESULT} == "ALL" ]]; then
        PARAMS="$PARAMS -publishTestResult"
    fi
    if [ "${RESULT_NAME}" ]; then
        PARAMS="$PARAMS -testResultName ${RESULT_NAME}"
    fi
    if [ "${DESCRIPTION}" ]; then
        PARAMS="$PARAMS -description ${DESCRIPTION}"
    fi
    if [[ ${PUBLISH_RESULT} == "WEB" || ${PUBLISH_RESULT} == "ALL" ]]; then
        PARAMS="$PARAMS -nlweb"
    fi
    if [ "${NEOLOADWEB_URL}" ]; then
        PARAMS="$PARAMS -nlwebAPIURL ${NEOLOADWEB_URL}"
    fi
    if [ "${NEOLOADWEB_TOKEN}" ]; then
        PARAMS="$PARAMS -nlwebToken ${NEOLOADWEB_TOKEN}"
    fi
    if [ "${NEOLOADWEB_PROXY}" ]; then
        PARAMS="$PARAMS -nlwebProxy ${NEOLOADWEB_PROXY}"
    fi
    if [ "${NEOLOADWEB_WORKSPACE}" ]; then
        PARAMS="$PARAMS -nlwebWorkspace ${NEOLOADWEB_WORKSPACE}"
    fi
    if [ "${NEOLOADWEB_TEST}" ]; then
        PARAMS="$PARAMS -nlwebTest ${NEOLOADWEB_TEST}"
    fi
    if [ "${CERTIFICATE_PATH}" ]; then
        PARAMS="$PARAMS -certificatePath ${CERTIFICATE_PATH}"
    fi
    if [ "${CERTIFICATE_PASSWORD}" ]; then
        PARAMS="$PARAMS -certificatePassword ${CERTIFICATE_PASSWORD}"
    fi
    if [ "${OTHER_ARGS}" ]; then
        PARAMS="$PARAMS ${OTHER_ARGS}"
    fi
    if [[ ! "${CONTROLLER_XMX}" || ! "${LOADGENERATOR_XMX}" ]]; then
        init_limit_env_vars
        #Use default ratio 50%
        mmemory=$(calc 'round($1*$2/100/1048576)' "${CONTAINER_MAX_MEMORY}" "50")
        if [[ ! "${CONTROLLER_XMX}" && $mmemory -gt 0 ]]; then
            CONTROLLER_XMX="-Xmx${mmemory}m"
        fi
        if [[ ! "${LOADGENERATOR_XMX}" && $mmemory -gt 0 ]]; then
            LOADGENERATOR_XMX="-Xmx$(($mmemory / 2))m"
        fi
    fi

    echo $CONTROLLER_XMX >> /home/neoload/neoload/bin/NeoLoadCmd.vmoptions
    sed -i "s/lg.launcher.vm.parameters=-server/lg.launcher.vm.parameters=$LOADGENERATOR_XMX -server/g" /home/neoload/neoload/conf/agent.properties

    echo "Launching NeoLoad with following parameters "${PARAMS}

    exec /home/neoload/neoload/bin/NeoLoadCmd ${PARAMS}
}