# baixando e instalando o hadoop
cd /opt
sudo wget https://www-us.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz

# Descompacta o arquivo
tar -xvf hadoop-3.2.1.tar.gz

# Muda o proprietário
chown -R brainiac:brainiac /opt/hadoop


vi .bashrc

# Hadoop
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
#muda o usuário de acesso para "hadoop"
export HADOOP_USER_NAME=hadoop

source .bashrc

#TESTANDO
hadoop version

#copiando os arquivos de configuração
scp hdpmaster:/opt/hadoop/etc/hadoop/* /opt/hadoop/etc/hadoop/

############ Multihomed Networks ############
# o namenode fornece o endereço dos datanodes para que o cliente escreva,
# só que o namenode pode trabalhar com nomes/IPs privados da rede do cluster.
vim /opt/hadoop/etc/hadoop/hdfs-site.xml

#incluir as linhas:
<property>
  <name>dfs.client.use.datanode.hostname</name>
  <value>true</value>
  </description>
</property>

###### MAPEAR OS DNS PRIVADOS DOS DATANODES PARA OS DNS PÚBLICOS
sudo vim /etc/hosts

# lista de comandos do HDFS:
https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html
#procurar por HDFSCommands no google


# testando tudo
cd
hdfs dfs -ls "/"

# atenção ao Rack Awareness. Saber em que hack os nós estão podem aumentar a
#disponibilidade e o desempenho.
