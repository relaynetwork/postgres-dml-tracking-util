# clean up tables
set -exu

echo "clearing out EXPORT side"
rake postgres:dml:gen_reset[public,consumer_consent]  | sudo -u postgres psql relayzone_development

echo "clearing out IMPORT side"
rake postgres:dml:gen_reset[public,consumer_consent]  | sudo -u postgres psql logging_development

echo "Adding in new db objects"
rake postgres:dml:gen_exporter[public,consumer_consent]  | sudo -u postgres psql relayzone_development
rake postgres:dml:gen_importer[public,consumer_consent]  | sudo -u postgres psql logging_development

echo "Adding in some dml for consumer consents..."
sudo -u postgres psql relayzone_development -c 'TRUNCATE rn_db.dml_export_tracking;'
sudo -u postgres psql relayzone_development -c "UPDATE consumer_consent set ani_phone = '6105551212';";


#rm -rf /tmp/dml-test/*
