#!/usr/bin/env bash
set -e

ACCEPT_TYPE="Accept: application/json"
SERVER_API_URI="https://circleci.com/api/v1/project/demisto/server"
TOKEN_ATTR="circle-token=$SERVER_CI_TOKEN"

echo "Getting latest build num"
TEMP=$(curl -s -H "$ACCEPT_TYPE" "$SERVER_API_URI/tree/master?limit=5&filter=successful&$TOKEN_ATTR")

ARTIFACTS_BUILD_NUM=
for i in `seq 0 4`; do
    echo "build $i:"
    echo $(echo "$TEMP" | jq ".[$i]")
    echo here
    if [[ $(echo "$TEMP" | jq ".[$i].build_parameters") == "null" ]]; then
        echo here2
        ARTIFACTS_BUILD_NUM=$(echo "$TEMP" | jq ".[$i].build_num")
        echo here3
        break
    fi
done

# ARTIFACT_BUILD_NUM=$(echo "$TEMP" | jq '.[0].build_num')
echo $ARTIFACTS_BUILD_NUM

TEMP=$(curl -s -H "$ACCEPT_TYPE" ${SERVER_API_URI}/${ARTIFACT_BUILD_NUM}/artifacts?${TOKEN_ATTR})
echo "$TEMP"
SERVER_DOWNLOAD_LINK=$(echo "$TEMP" | jq '.[].url' -r | grep demistoserver | grep /0/)

echo "Getting server artifact for build: ${ARTIFACT_BUILD_NUM}"
echo "SERVER_DOWNLOAD_LINK = ${SERVER_DOWNLOAD_LINK}"

curl -o demistoserver.sh ${SERVER_DOWNLOAD_LINK}?${TOKEN_ATTR}

echo "Done!"