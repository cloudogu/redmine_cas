#!/bin/bash
DOGU="${1}"

echo "Plugin-Dir: ${PLUGIN_DIR}"

rm -rf ./redmine_cas
../bundle/bundle_plugin.rb
if [ "${DOGU}" == "redmine" ]; then
  docker exec -it "${DOGU}" rm -rf "/usr/share/webapps/${DOGU}/defaultPlugins/redmine_cas"
  docker exec -it "${DOGU}" rm -rf "/usr/share/webapps/${DOGU}/plugins/redmine_cas"
  docker cp ./redmine_cas "${DOGU}:/usr/share/webapps/${DOGU}/defaultPlugins/"
  docker cp ./redmine_cas "${DOGU}:/usr/share/webapps/${DOGU}/plugins/"
else
  docker exec -it "${DOGU}" rm -rf "/usr/share/webapps/${DOGU}/plugins/redmine_cas"
  docker cp ./redmine_cas "${DOGU}:/usr/share/webapps/${DOGU}/plugins/"
fi
docker restart "${DOGU}"
tail -f "/var/log/docker/${DOGU}.log"
