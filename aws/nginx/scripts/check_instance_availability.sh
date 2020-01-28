#!/bin/bash
##Orginal source https://gitlab.com/korrident/terraform_calculate_ami_by_availability_zone/blob/master/check_subnet_ami.bash

function error_exit(){
	echo "$1" 1>&2
	exit 1
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
    eval "$(jq -r '@sh "export INSTANCE_TYPE=\(.type)  REGION=\(.region)  PROFILE=\(.profile)   "')"

    ([ -z "${INSTANCE_TYPE}" ] || [ "${INSTANCE_TYPE}" == "null" ]) && error_exit "missing INSTANCE_TYPE"
    ([ -z "${REGION}" ] || [ "${REGION}" == "null" ]) && error_exit "missing REGION"
    ([ -z "${PROFILE}" ] || [ "${PROFILE}" == "null" ])  && error_exit "missing PROFILE"
}

function operation(){
    # ok when receving error: "An error occurred (DryRunOperation) when calling the RunInstances operation: Request would have succeeded, but DryRun flag is set."

CMD="aws --region=${REGION} ec2 describe-reserved-instances-offerings \
--no-include-marketplace
--instance-type ${INSTANCE_TYPE} \
--profile ${PROFILE} \
--dry-run"

    # echo `date` >> /tmp/$0_debug.log
    # echo "${CMD}" >> /tmp/$0_debug.log

    RES=`${CMD} 2>&1`
    # echo "${RES}" >> /tmp/$0_debug.log

    echo ${RES} | grep -c "DryRunOperation" > /dev/null
    OP_EXIT_CODE=$?

    # echo "OP_EXIT_CODE=${OP_EXIT_CODE}" >> /tmp/$0_debug.log
}


function return_output() {
  if [[ ${OP_EXIT_CODE} -ne 0 ]]; then
    echo '{}'
    return
  fi
  jq -n \
    --arg type "$INSTANCE_TYPE" \
    '{"type":$type}'
    return
}

 check_deps
 parse_input
 operation
 return_output
