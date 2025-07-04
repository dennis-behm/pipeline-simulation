#!/bin/bash

echo " "
echo "Query Wazi Deploy index"
echo "*******************************************"

wdEvidencesIndex="reporting_index"
wdEvidencesRoot="${DESTINATION_FOLDER}"
queryTemplate=cfg/queryTemplate.yaml

# Query parameters
# - "*" returns all entries
# - Specify your criteria 
application="*"
module="*"
type="*"
environment="*"

echo "Query Options"
echo "*******************************************"
echo "*     application = ${application}"
echo "*     module      = ${module}"
echo "*     type        = ${type}"
echo "*     environment = ${environment}"

# Outputs
timestamp=$(date +%F_%H-%M-%S)

outputDir=reports/${timestamp}
#rm -Rf reports
mkdir -p $outputDir

reportFile="${outputDir}/report.html"
renderer="cfg/renderer.html"



CMD="""wazideploy-evidence \
 --indexFolder ${wdEvidencesIndex} \
 --query ${queryTemplate} \
 --output=${reportFile} \
 r \
 app="${application}" env="${environment}" type="${type}" module="${module}"\
 renderer="${renderer}"
 """
echo "[INFO] Executing following query: $CMD"
echo "*******************************************"
${CMD}
rc=$?

# Error Handling
if [ $rc -eq 0 ]; then
    echo "[INFO] - Query Wazi Deploy Query completed. Find output at ${reportFile}."
else
    echo "[WARNING] - Query Wazi Deploy index failed."
    exit 1
fi
