#!/usr/bin/bash

source ../loadLibraries.sh

#set -x

#declare -A OPTS=([host]='drmcyc-ballab1-1-01.cec.lab.emc.com')
#environ.getHostIp "${OPTS[host]}"
#grafana.HOST

#grafana.GetHomeDashboard
grafana.GetAllDataSources
#grafana.GetAllFolders
#grafana.GetDashboardByUid
#grafana.GetDashboardVersion
#grafana.GetDataSourceIdByName
#grafana.GetFolderById
#grafana.GetFolderByUid
#grafana.GetSingleDataSourceById
#grafana.GetSingleDataSourceByName
#grafana.GetSingleDataSourceByUid
#grafana.GetStatus
echo
