#!/usr/bin/env bash
# Variables
TODAY=`date "+%Y-%m-%d"`
SEQ=`date "+%H%M%S"`
STAMP="${TODAY}-${SEQ}"
INGEST_ID="docs-${STAMP}"
INGEST_FOLDER="bin/${INGEST_ID}"
FILE_PATH="bin/${INGEST_ID}.zip"

echo "Building..."
rm -rf tmp
java -jar site/gtor/saxon9.jar -xi -l:on -s:site/src/site-hippo.xml -xsl:site/gtor/hippo.xslt output-directory=tmp/
echo "Building Jekyll site..."
jekyll build --source "md-docs/" --destination "tmp/jekyll" --config "md-docs/_config.yml,md-docs/_config.swift.yml"
cp -R "tmp/jekyll/ready/guides/couchbase-lite/native-api" "tmp/couchbase-lite/swift/"
cp -R "tmp/jekyll/ready/swift/" "tmp/couchbase-lite/swift/"
cp -R "tmp/jekyll/ready/couchbase-lite/" "tmp/couchbase-lite/"

cp -R "tmp/jekyll/ready/guides/sync-gateway/" "tmp/sync-gateway/guides/"
cp -R "tmp/jekyll/ready/guides/sync-gateway/" "tmp/sync-gateway/guides/"
cp -R "tmp/jekyll/ready/training/" "tmp/training/"

jekyll build --source "md-docs/" --destination "tmp/jekyll" --config "md-docs/_config.yml,md-docs/_config.objc.yml"
cp -R "tmp/jekyll/ready/guides/couchbase-lite/native-api" "tmp/couchbase-lite/objc/"
cp -R "tmp/jekyll/ready/objc/" "tmp/couchbase-lite/objc/"
jekyll build --source "md-docs/" --destination "tmp/jekyll" --config "md-docs/_config.yml,md-docs/_config.java.yml"
cp -R "tmp/jekyll/ready/guides/couchbase-lite/native-api" "tmp/couchbase-lite/java/"
cp -R "tmp/jekyll/ready/java/" "tmp/couchbase-lite/java/"
jekyll build --source "md-docs/" --destination "tmp/jekyll" --config "md-docs/_config.yml,md-docs/_config.c.yml"
cp -R "tmp/jekyll/ready/guides/couchbase-lite/native-api" "tmp/couchbase-lite/c/"
cp -R "tmp/jekyll/ready/c/" "tmp/couchbase-lite/c/"

ditto -c -k --sequesterRsrc --keepParent "tmp" "tmp.zip"

rm -rf tmp

echo "
cd uploads/mobile
put tmp.zip
" > push.sh

sftp -b push.sh -oIdentityFile=~/.ssh/cb_xfer_id_rsa cb_xfer@54.175.181.113

curl -X POST "http://jnocentini:narodnaia@build-ingestion.cbauthx.com/job/CouchbaseDocumentationJobs/job/Mobile/job/IngestStage/build\?delay\=0sec"

#if [[ -e "push.sh" ]]; then
#	rm push.sh
#fi
#
#if [[ "$?" -ne 0 ]]; then
#	echo "rm push.sh failed with code $?"
#	exit "$?"
#fi
#
## Build the SFTP command input script
#echo "
#cd uploads/mobile
#put ${FILE_PATH}
#" > push.sh
#
#if [[ "$?" -ne 0 ]]; then
#	echo "create push.sh failed with code $?"
#	exit "$?"
#fi

# Upload using the command input script
#sftp -b push.sh -oIdentityFile=~/.ssh/cb_xfer_id_rsa cb_xfer@54.175.181.113
#
#if [[ "$?" -ne 0 ]]; then
#	echo "sftp failed with code $?"
#	exit "$?"
#fi
#
#if [[ -e "push.sh" ]]; then
#	rm push.sh
#fi

# Trigger the AuthX Jenkins job to ingest the docset and update the 
# staging environment at http://developer-stage.cbauthx.com/documentation/
#if [[ ${3} = "stage" ]]; then
#	curl http://build-ingestion.cbauthx.com/job/CouchbaseDocumentationJobs/job/Mobile/job/IngestStage/build\?delay\=0sec
#fi

#if [[ ${3} = "qa" ]]; then
#	curl http://build-ingestion.cbauthx.com/job/CouchbaseDocumentationJobs/job/Mobile/job/IngestQA/build\?delay\=0sec
#fi

#if [[ "$?" -ne 0 ]]; then
#	echo "curl failed with code $?"
#	exit "$?"
#fi

# NOTE: we can also do (later) param substitution via the curl command
#       using query params in this form: 
#              "http://JENKINS_HOST/job/MY_JOB_NAME/buildWithParameters?PARAMETER0=VALUE0&PARAMETER1=VALUE1"

exit 0
