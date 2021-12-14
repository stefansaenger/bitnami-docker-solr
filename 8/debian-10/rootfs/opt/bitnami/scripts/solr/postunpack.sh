#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libsolr.sh
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/libos.sh


# Load solr environment variables
. /opt/bitnami/scripts/solr-env.sh

ensure_user_exists "$SOLR_DAEMON_USER" --group "$SOLR_DAEMON_GROUP"
for dir in "$SOLR_TMP_DIR" "$SOLR_VOLUME_DIR" "$SOLR_LOGS_DIR" "$SOLR_BASE_DIR"; do
    ensure_dir_exists "$dir"
    configure_permissions_ownership "$dir" -d "775" -u "$SOLR_DAEMON_USER" -g "root"
done

# Create basic solr configuration
replace_in_file "$SOLR_BIN_DIR"/solr.in.sh "#SOLR_JAVA_HOME=\"\"" "SOLR_JAVA_HOME=$SOLR_JAVA_HOME"
replace_in_file "$SOLR_BIN_DIR"/solr.in.sh "#SOLR_PID_DIR=" "SOLR_PID_DIR=$SOLR_PID_DIR"
replace_in_file "$SOLR_BIN_DIR"/solr.in.sh "#SOLR_LOGS_DIR=logs" "SOLR_LOGS_DIR=$SOLR_LOGS_DIR"
echo "SOLR_OPTS=\"\$SOLR_OPTS -Dlog4j2.formatMsgNoLookups=true\"" >> "$SOLR_BIN_DIR"/solr.in.sh
