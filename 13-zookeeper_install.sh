#Instalação
wget https://www-us.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
tar -xf zookeeper-3.4.14.tar.gz
sudo mv zookeeper-3.4.14 /opt/zookeeper

#Configuração:
sudo mkdir /var/lib/zookeeper
sudo chown -R hadoop:hadoop /var/lib/zookeeper

cd /opt/zookeeper/conf
cp zoo_sample.cfg zoo.cfg
vim zoo.cfg

#incluir os parâmetros correspondentes aos servidores
#depois do IP está o range de portas que o serviço vai ouvir
server.1=192.168.0.10:2888:3888
server.2=192.168.0.80:2888:3888
server.3=192.168.0.79:2888:3888

#Preparar os nodes escravos
cd /opt
sudo mkdir zookeeper
sudo chown -R hadoop:hadoop zookeeper

sudo mkdir /var/lib/zookeeper
sudo chown -R hadoop:hadoop /var/lib/zookeeper

#copiar o zookeeper para os slaves
cd /opt
scp -rv zookeeper hdpslv1:/opt
scp -rv zookeeper hdpslv2:/opt

#criar arquivo para localizar o zookeeper (saber qual máquina está executando)
vim /var/lib/zookeeper/myid
#digitar o número correspondente ao servidor. Ex.: 192.168.0.10 receberá 1 no arquivo
echo '1' >> /var/lib/zookeeper/myid

#iniciar o zookeeper - executar o comando em todas as máquinas
/opt/zookeeper/bin/zkServer.sh start
