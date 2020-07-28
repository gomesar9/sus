#!/bin/bash
# Script to update docker-compose via curl
# gomesar9 2020

function _help {
    echo "Usage: $0 [-M | -m | -p]"
    echo "  Choose which parts of the version are relevant, thus able to trigger updates:"
    echo "   -M major"
    echo "   -m minor"
    echo "   -p patch"
    exit 1
}

while getopts "Mmp" opt; do
  case ${opt} in
    M )
        b_major=1
        ;;
    m )
        b_minor=1
        ;;
    p )
        b_patch=1
        ;;
    * )
        _help
        ;;
  esac
done

# Help?
test -z "$b_major" && test -z "$b_minor" && test -z "$b_patch" && _help

# Main
LATEST_VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
current_version=$(docker-compose -v | sed 's/.*version \([0-9]*\.[0-9]*\.[0-9]*\)[-a-zA-Z_,].*/\1/')

current_major=${current_version%%\.*}
current_minor=$(echo ${current_version} | cut -d. -f2)
current_patch=${current_version##*\.}

latest_major=${LATEST_VERSION%%\.*}
latest_minor=$(echo ${LATEST_VERSION} | cut -d. -f2)
latest_patch=${LATEST_VERSION##*\.}

if [ "${current_major}" -lt "${latest_major}" ]; then
    test -n "$b_major" && update=1
else
    if [ "${current_minor}" -lt "${latest_minor}" ]; then
       test -n "$b_minor" && update=1
    else
        test "${current_patch}" -lt "${latest_patch}" && test -n "$b_patch" && update=1
    fi
fi

if [ -n "$update" ]; then
    DESTINATION=/usr/local/bin/docker-compose
    BKP=/tmp/docker-compose.bkp
    TMP=/tmp/docker-compose
    echo "Updating docker-compose V${current_version} to V${LATEST_VERSION} (\"${DESTINATION}\")."
    curl -L "https://github.com/docker/compose/releases/download/${LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o "$TMP" \
    && mv /usr/local/bin/docker-compose "$BKP" \
    && mv "$TMP" "$DESTINATION" \
    && chmod 755 "$DESTINATION"
    docker-compose -v
fi
