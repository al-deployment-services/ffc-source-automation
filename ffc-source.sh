#!/usr/bin/env bash
# Create Alert Logic FFC source based on an existing policy

error(){
  log "ERROR: $1"
  exit 1
}

codeCheck(){
  RESPONSE="$1"
  MESSAGE="$2"

  CODE=${RESPONSE/* /}
  [[ $CODE =~ 20. ]] || error "AlertLogic API $MESSAGE (HTTP $CODE)\n$RESPONSE" \
                                 && log "$MESSAGE (HTTP $CODE)"
}

log(){
  DT=$(date +%Y%m%d-%H:%M:%S)
  echo -e "$DT $1"
}

### Main Program ###
. ~/.alertlogic/publicapi || error "can not source credentials"

HOSTNAME=$1
FFC_POLICY=$2

CURL_OPTS=" -w \" %{http_code}\" -u ${API_KEY}: -H \"Accept: application/json\" "
CURL_DEST="https://publicapi.alertlogic.net/api"
CURL_OUT="2>/dev/null"

# Check if FFC source already exists
RESPONSE=$( eval "curl $CURL_OPTS ${CURL_DEST}/lm/v1/$ACCOUNT/sources?name=${HOSTNAME}_${FFC_POLICY} $CURL_OUT" )
codeCheck "$RESPONSE" "$HOSTNAME check for existing source"
SOURCE_COUNT=$(echo -e "$RESPONSE" |  jq -r '.total_count' 2>/dev/null )
if [ "$SOURCE_COUNT" !=  "0" ]; then
  log "$HOSTNAME $FFC_POLICY source already exists"
  exit 0
else
  #Get Host ID
  RESPONSE=$(eval "curl $CURL_OPTS ${CURL_DEST}/lm/v1/$ACCOUNT/sources?name=$HOSTNAME $CURL_OUT" )
  codeCheck "$RESPONSE" "$HOSTNAME Get syslog source host id"
  HOST_ID=$(echo -e "$RESPONSE" |  jq -r '.[] | .[].syslog.agent.host_id' 2>/dev/null )
  test "$HOST_ID" = "null" && error "Failed to get host ID"
  test "$HOST_ID" = "" && error "Host $HOSTNAME does not exist in AlertLogic UI"
fi

# Get Policy ID
RESPONSE=$( eval "curl $CURL_OPTS ${CURL_DEST}/lm/v1/$ACCOUNT/policies?search=$FFC_POLICY $CURL_OUT" )
codeCheck "$RESPONSE" "$HOSTNAME get flatfile policy"
POLICY_ID=$(echo -e "$RESPONSE" |  jq -r '.[] | .[].flatfile.id ' 2>/dev/null )
test "$POLICY_ID" = "null" && error "Failed to get flatfile policy ID"

# Create FFC Source
BODY=$( cat << EOF
{
  "flatfile": {
    "name": "${HOSTNAME}_${FFC_POLICY}",
    "method": "agent",
    "agent": {
      "host_id": "${HOST_ID}"
    },
    "enabled": true,
    "policy_id": "${POLICY_ID}"
  }
}
EOF
)

RESPONSE=$(eval "curl $CURL_OPTS  -X POST --data '$BODY' -H 'Content-Type: application/json' ${CURL_DEST}/lm/v1/$ACCOUNT/sources/flatfile $CURL_OUT" )
codeCheck "$RESPONSE" "Create flatfile source ${HOSTNAME}_${FFC_POLICY}"
