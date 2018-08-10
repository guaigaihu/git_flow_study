#!/bin/bash

# -----------------------------------------------------------------------------
# SHL2280_backupBatchTraceLog.sh
#
# Environment Variable
#
#     TARGET_YM    Represents the elapsed time.
#                  default value is 2 month ago
#                  format is 'yyyy-MM'
#
#     BATCH_ID     According to batchID  to find the LOGNAME
# -----------------------------------------------------------------------------

######################
# Environments
######################
BATCH_HOME=`dirname $0`/..

# set environment
. ${BATCH_HOME}/bin/setenv.sh

if [ -z ${LOG_ROOT_DIR} ]; then

    LOG_ROOT_DIR="/var/log/iai/iai-batch"

fi

if [ -z ${BACKUP_ROOT_DIR} ]; then

    BACKUP_ROOT_DIR="/mnt/trans/backup"

fi

if [ ! -d ${LOG_ROOT_DIR}/trace ];then

mkdir -p ${LOG_ROOT_DIR}/trace

fi

if [ ! -d ${LOG_ROOT_DIR}/cdi/trace ];then

mkdir -p ${LOG_ROOT_DIR}/cdi/trace

fi

if [ ! -d ${BACKUP_ROOT_DIR}/trace ];then

mkdir -p ${BACKUP_ROOT_DIR}/trace

fi


BATCH_ID=$1

TARGET_YM=$2

CURTIME=$((`date +%Y%m%d%H%M%S`))

MOVE_DESTINATION_BACKUP_DIR=${BACKUP_ROOT_DIR}/trace

if [ -z ${TARGET_YM} ]; then
    TARGET_YM=`date --date '2 month ago' +%Y-%m`
fi

LOG_NAME=iai-batch-${BATCH_ID}"_*.log."

TAR_NAME=${BATCH_ID}-${TARGET_YM}-${CURTIME}.tar.gz

######################
# Run
######################
cd ${LOG_ROOT_DIR}


if [ -z "${BATCH_ID}" ] || ( [[ ${BATCH_ID} != SHL* ]] && [[ ${BATCH_ID} != SHT* ]] ) || [ ${#BATCH_ID} != 7 ]; then
    # ログ出力
    log "ERROR" "target BATCH ID is not correct."
    exit 9
fi

target_files=`find ./ -type f -name "${LOG_NAME}${TARGET_YM}-[0-3][0-9]*"`

if [ -z "${target_files}" ]; then
    # ログ出力
    log "WARN" "target file does not exist."
    exit 8
fi

TARGET_YM=${CURTIME}

tar czf ${TAR_NAME} ${target_files} || \
    { log "WARN" "${target_files} compress failed."; exit 8;}

mv ${TAR_NAME} ${MOVE_DESTINATION_BACKUP_DIR}/ 2>/dev/null || \
    { log "WARN" "${TAR_NAME} move failed."; exit 8;}

rm -rf ${target_files} || \
    { log "WARN" "${target_files} remove failed."; exit 8;}
