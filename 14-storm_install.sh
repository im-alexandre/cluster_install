#baixar e descompactar
wget https://www-us.apache.org/dist/storm/apache-storm-2.1.0/apache-storm-2.1.0.tar.gz
tar -xf apache-storm-2.1.0.tar.gz
sudo mv apache-storm-2.1.0 /opt/storm

#Configuração
cd /opt/storm/conf
vim storm.yaml

#visitar em caso de dúvidas
https://github.com/apache/storm/blob/master/conf/defaults.yaml

#incluir as linhas - incluir mesmo, não vale à pena procurar os parâmetros para descompactar

storm.zookeeper.server:
    - "192.168.0.10"
    - "192.168.0.80"
    - "192.168.0.79"

storm.zookeeper.port: 2181

nimbus.host: "192.168.0.10"

storm.local.dir: "/opt/storm/data"

supervisor.slots.ports:
    - 6700
    - 6701
    - 6702
    - 6703


#criar o diretório em cada escravo
cd /opt
sudo mkdir storm
sudo chown -R hadoop:hadoop storm

# copiar o storm para os escravos
cd /opt
scp -rv storm hdpslv1:/opt
scp -rv storm hdpslv2:/opt

#Inicialização do storm
# no nó master executa o nimbus
# já nnos escravos, executa o supervisor
#pode configurar as variáveis de ambiente
#nó master
/opt/storm/bin/storm nimbus &

#nós escravos
/opt/storm/bin/storm supervisor &

#Iniciando a interface gráfica
# No nó master:
/opt/storm/bin/storm ui &

#acessar
hdpmaster:8080
