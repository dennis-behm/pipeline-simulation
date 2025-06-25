#!/bin/env bash

# Location of the configured CBS scripts on USS - https://github.com/IBM/dbb/tree/main/Templates/Common-Backend-Scripts
export PIPELINE_SCRIPTS=/u/dbehm/git/dbb/Templates/Common-Backend-Scripts

# Pipeline Workspace
export PIPELINE_WORKSPACE=/u/dbehm/git/june-engagement-workspace/ts1_change_base_delete

# Adding pipeline scripts to PATH of the user running this script
export PATH=$PIPELINE_SCRIPTS:$PATH
export TMPHLQ="DBEHM"

gitRepository=https://github.com/dennis-behm/base.git
buildImplementation=dbb
branchName="main"
application="base"

# Additional notes
####################
# * demonstrates the flow for deleting a file
# * See required setup of processing deletions in
# * https://www.ibm.com/docs/en/developer-for-zos/17.0.x?topic=deployment-static-python-translator#wd_gettingstarted_static_python__delete_title
# * in zAppBuild/build-conf/defaultzAppBuildConf.properties on line set documentDeleteRecords=true 
 

# Using a timestamp to simulate the buildIdentifier
timestamp=$(date +%F_%H-%M-%S)
rc=0

mkdir -p $PIPELINE_WORKSPACE

# This script simulates the entire pipeline process (clone, build, package & deploy)
if [ $rc -eq 0 ]; then
    gitClone.sh -w $application/$branchName/${buildImplementation}build_$timestamp -r $gitRepository -b $branchName
    rc=$?
fi


if [ $rc -eq 0 ]; then
    dbbBuild.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a $application -b $branchName -p build -v -t '--fullBuild'
    rc=$?
fi

if [ $rc -eq 0 ]; then
    packageBuildOutputs.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a $application -b main -p release -i $timestamp -r rel-1.0.0 -t ${application}-rel-1.0.0-${timestamp}.tar
    rc=$?
fi

if [ $rc -eq 0 ]; then
    wazideploy-generate.sh -w  $application/$branchName/${buildImplementation}build_$timestamp -a $application -b $branchName -i ${application}-rel-1.0.0-${timestamp}.tar
    rc=$?
fi
if [ $rc -eq 0 ]; then
    wazideploy-deploy.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a ${application} -e EOLEB7-Integration.yml -i ${application}-rel-1.0.0-${timestamp}.tar
    rc=$?
fi

if [ $rc -eq 0 ]; then
    wazideploy-evidence.sh -w $application/$branchName/${buildImplementation}build_$timestamp -o deploy/deployment-report.html
    rc=$?
fi

echo "ts1_baseline_build_deploy completed with $rc"

echo "ts1_baseline_change_files starting"

# A new tar file name is used to collect the delete information

if [ $rc -eq 0 ]; then
    git -C $PIPELINE_WORKSPACE/$application/$branchName/${buildImplementation}build_$timestamp/$application status
    rm -Rf $PIPELINE_WORKSPACE/$application/$branchName/${buildImplementation}build_$timestamp/$application/src/jcl/BAB1.jcl
    git -C $PIPELINE_WORKSPACE/$application/$branchName/${buildImplementation}build_$timestamp/$application status
    git -C $PIPELINE_WORKSPACE/$application/$branchName/${buildImplementation}build_$timestamp/$application add src/jcl/BAB1.jcl
    git -C $PIPELINE_WORKSPACE/$application/$branchName/${buildImplementation}build_$timestamp/$application status
    git -C $PIPELINE_WORKSPACE/$application/$branchName/${buildImplementation}build_$timestamp/$application commit -m "delete BAB1"
    #rc=$?
fi

if [ $rc -eq 0 ]; then
    dbbBuild.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a $application -b $branchName -p build -v -t '--impactBuild'
    rc=$?
fi

if [ $rc -eq 0 ]; then
    packageBuildOutputs.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a $application -b main -p release -i $timestamp -r rel-1.0.0 -t ${application}-rel-1.0.0-${timestamp}_delete.tar
    rc=$?
fi

if [ $rc -eq 0 ]; then
    wazideploy-generate.sh -w  $application/$branchName/${buildImplementation}build_$timestamp -a $application -b $branchName -i ${application}-rel-1.0.0-${timestamp}_delete.tar
    rc=$?
fi
if [ $rc -eq 0 ]; then
    wazideploy-deploy.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a ${application} -e EOLEB7-Integration.yml -i ${application}-rel-1.0.0-${timestamp}_delete.tar
    rc=$?
fi

if [ $rc -eq 0 ]; then
    wazideploy-evidence.sh -w $application/$branchName/${buildImplementation}build_$timestamp -o deploy/deployment-report.html
    rc=$?
fi