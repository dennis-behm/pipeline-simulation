#!/bin/env bash

# Location of the configured CBS scripts on USS - https://github.com/IBM/dbb/tree/main/Templates/Common-Backend-Scripts
export PIPELINE_SCRIPTS=/u/dbehm/git/dbb/Templates/Common-Backend-Scripts

# Pipeline Workspace
export PIPELINE_WORKSPACE=/u/dbehm/git/june-engagement-workspace/ts1_change_base

# Adding pipeline scripts to PATH of the user running this script
export PATH=$PIPELINE_SCRIPTS:$PATH
export TMPHLQ="DBEHM"

gitRepository=https://github.com/dennis-behm/base.git
buildImplementation=dbb
branchName="main"
application="base"

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
    packageBuildOutputs.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a $application -b main -p release -i $timestamp -r rel-1.0.0 -u
    rc=$?
fi

if [ $rc -eq 0 ]; then
    wazideploy-generate.sh -w  $application/$branchName/${buildImplementation}build_$timestamp -a $application -b $branchName -P release -R rel-1.0.0 -I $timestamp
    rc=$?
fi
if [ $rc -eq 0 ]; then
    wazideploy-deploy.sh -w $application/$branchName/${buildImplementation}build_$timestamp -a ${application} -x 'hlq=DBEHM.BASETEST' -e EOLEB7-Integration.yml
    rc=$?
fi

if [ $rc -eq 0 ]; then
    wazideploy-evidence.sh -w $application/$branchName/${buildImplementation}build_$timestamp -o deploy/deployment-report.html
    rc=$?
fi


echo "ts1_change_base completed with $rc"