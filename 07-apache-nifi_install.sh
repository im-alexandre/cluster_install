#download
cd /opt
sudo wget https://www-us.apache.org/dist/nifi/1.10.0/nifi-1.10.0-bin.tar.gz
sudo tar -xf nifi-1.10.0-bin.tar.gz
sudo rm nifi-1.10.0-bin.tar.gz
sudo mv nifi-1.10.0-bin nifi
sudo chown -R hadoop:hadoop nifi

# iniciando o nifi
cd /opt/nifi
bin/nifi.sh run

#iniciando no background
bin/nifi.sh start

#verificando o status caso esteja rodando no background:
bin/nifi.sh status

#parar o nifi no background
bin/nifi.sh stop

# acessar através do browser
htto://hdpmaster:8080/nifi

# instalar como serviço: 
bin/nifi.sh install "nome do serviço"  #se o nome não for passado, o serviço vai se chamar nifi
# o comando acima inclui o nifi no systemctl. Ex: sudo service nifi start/stop etc

