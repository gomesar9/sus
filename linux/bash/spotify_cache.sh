#!/bin/bash
# gomesar9 2020


function _help {
    echo "Usage: $0 -c <cache_data_path> [-l <log_path>] [-d days]"
    echo "  Clear cache"
    echo "   -c cache Data dir (ex: \"/home/bart/.cache/spotify/Data\")"
    echo "   -l log path (default: /tmp/clean_spotify.log)"
    echo "   -d days (default: 7)"
    exit 1
}

log_path="/tmp/clean_spotify.log"

while getopts ":c:l" opt; do
    case ${opt} in
        c)
            cache_path="$OPTARG"
            ;;
        l)
            log_path="$OPTARG"
            ;;
        d)
            days="${OPTARG-7}"
            ;;
        *)
            _help
            ;;
    esac
done

TOTAL=$(find "$cache_path" -daystart -atime +$days -name '*.file' -print | wc -l)

if [ $TOTAL -eq 0 ]; then
    exit 0
fi

find "$cache_path" -daystart -atime +$days -name '*.file' -delete
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $TOTAL deleted. (Days: $days)" >> $log_path
