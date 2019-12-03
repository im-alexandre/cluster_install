# baixando e instalando o kafka

cd /opt
sudo wget https://archive.apache.org/dist/kafka/1.1.0/kafka_2.11-1.1.0.tgz
sudo tar -xf kafka_2.11-1.1.0.tgz
sudo rm kafka_2.11-1.1.0.tgz
sudo mv kafka_2.11-1.1.0/ kafka
sudo chown -R hadoop:hadoop kafka

cd
vim .bash_profile

#incluir linhas:

#KAFKA_HOME
export KAFKA_HOME=/opt/kafka
export PATH=$PATH:$KAFKA_HOME/bin

. .bash_profile


#iniciando o zookeper
cd /opt/kafka
bin/zookeeper-server-start.sh config/zookeeper.properties

#testar a conexão (depois disso, remover o telnet)
sudo yum install -y telnet
telnet localhost 2181
#no console telnet:
stat

sudo yum remove -y telnet

#INICIANDO O BROKER
bin/kafka-server-start.sh config/server.properties

#CRIANDO TÓPICO
#IMPORTANTE: O TÓPICO APONTA PARA O ZOOKEEPER, QUE ENVIA A COORDENA O(S) BROKER(S)
bin/kafka-topics.sh --create --topic topico1 --zookeeper localhost:2181 --replication-factor 1 --partitions 1

#abrindo o console do producer (conecta no broker, pois o zookeper já criou o tópico nele)
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic topico1

#abrindo console consumer (conecta no zookeper, que vai buscar nos brokers o tópico especificado.
#Além disso, define o offset - quais mensagens ler)
bin/kafka-console-consumer.sh --zookeper localhost:2181 --topic topica1 --from-beginning

#CRIANDO MULTI-BROKER cluster

cd /opt/kafka/conf
cp server.properties server-0
cp server.properties server-1
cp server.properties server-2

vim server-1
#editar as seguintes linhas:
broker.id=1
log.dirs=/tmp/kafka-logs1
listeners=PLAINTEXT://:9093

#iniciando o broker - executar o comando para os 3 brokers
cd /opt/kafka
bin/kafka-server-start.sh config/server-1

#criando topico para os 3 brokers
bin/kafka-topics.sh --create --topic topico3 --zookeeper localhost:2181 --replication-factor 3 --partitions 1

#VERIFICAR COMO O ZOOKEEPER DISTRIBUIU O topico
bin/kafka-topics.sh --describe --topic topico3 --zookeeper localhost 2181

#criar produer - o kafka sabe que existem varios brokers mas ele conecta no selecionado
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic topico2

#CRIANDO O consumer
cd /opt/kafka
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic topico2 --from-beginning

#O consumer e o producer podem ser classes java. VRF códigos-fonte
