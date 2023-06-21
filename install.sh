#!/bin/bash
sudo apt install apt-transport-https
# установка Elasticsearch
echo "deb http://elasticrepo.serveradmin.ru bullseye main" | sudo tee /etc/apt/sources.list.d/elasticrepo.list
wget -qO - http://elasticrepo.serveradmin.ru/elastic.asc | sudo apt-key add -
sudo apt update
sudo apt install elasticsearch | grep "built-in superuser is" | sed 's|.*is : ||g' | sed "s:^:elastic - :g" >> passwords
sudo sed -i "s|#network.host.*|network.host: 127.0.0.1|g" /etc/elasticsearch/elasticsearch.yml
sudo sed -i "s|http.host.*|http.host: 127.0.0.1|g" /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's|#discovery.seed_hosts.*|discovery.seed_hosts: ["127.0.0.1", "[::1]"]|g' /etc/elasticsearch/elasticsearch.yml
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
# установка Kibana
sudo apt install kibana
yes | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system | grep "New value" | sed 's|.*value: ||g' | sed "s:^:kibana_system - :g" >> passwords
#ip_address=`hostname -I | sed`
#sudo sed -i "s|server.host.*|server.host: '$ip_address'|g" /etc/kibana/kibana.yml
sudo sed -i 's|#elasticsearch.username:|elasticsearch.username: "kibana_system"|g' /etc/kibana/kibana.yml
kibana_password=`grep "New" passwords | sed 's|kibana_system -||g'`
sudo sed -i "s|#elasticsearch.password.*|elasticsearch.password: '$kibana_password'|g" /etc/kibana/kibana.yml
sudo sed -i 's|#elasticsearch.ssl.certificateAuthorities.*|elasticsearch.ssl.certificateAuthorities: [ "/etc/kibana/certs/http_ca.crt" ]|g' /etc/kibana/kibana.yml
sudo sed -i 's|#elasticsearch.hosts.*|elasticsearch.hosts: ["https://127.0.0.1:9200"]|g' /etc/kibana/kibana.yml
sudo sed -i 's|#server.publicBaseUrl.*|server.publicBaseUrl: "http://0.0.0.0:5601/"|g' /etc/kibana/kibana.yml
sudo cp -R /etc/elasticsearch/certs /etc/kibana
sudo chown -R root:kibana /etc/kibana/certs
sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
# установка Logstash
sudo apt install logstash
echo 'TimeoutStopSec=180' | sudo tee -a /etc/systemd/system/logstash.service
sudo systemctl enable logstash.service
