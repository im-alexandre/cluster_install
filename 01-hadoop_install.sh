# Criando usuários e configurando o SSH

# Facilitar a vida:
yum update -y && yum install -y wget vim net-tools git


# Criando usuários (nos 3 servidores do cluster)
useradd -m hadoop
passwd hadoop


# Configurando o SSH (nos 3 servidores do cluster)
vi /etc/ssh/sshd_config

# incluir os nós nos arquivos /etc/hosts (ambiente local) ou incluir os endereços diretamente no arquivo workers (à frente)
sudo vim /etc/hosts
#incluir:
xxx.xxx.xxx.xxx hdpslv1
yyy.yyy.yyy.yyy hdpslv2

# Descomentar as seguintes linhas

Port 22  ###
#AddressFamily any
ListenAddress 0.0.0.0  ###
ListenAddress ::  ###


PubkeyAuthentication yes  ###


# Restart do SSH
systemctl restart sshd.service


# Cria a chave de segurança SSH (apenas no node master)
su hadoop
cd ~
ssh-keygen


# Copia a chave
# Caso não seja utilizado o nome/caminho padrão (id_rsa), deve ser passada a opção "-i /caminho/para/a/chave"
ssh-copy-id -i ~/.ssh/hdp-key.pub hadoop@hdpslv1
ssh-copy-id -i ~/.ssh/hdp-key.pub hadoop@hdpslv2
ssh-copy-id -i ~/.ssh/hdp-key.pub hadoop@localhost


# Testa a conexão
# Do master para o slave
ssh hadoop@hdpslv1 -i ~/.ssh/hdp-key



###########################################################################################################
###########################################################################################################

# Instalando e Configurando o Java JDK (nos 3 servidores do cluster)
# Acesso como usuário hadoop
su - hadoop


# Acessa o diretório
cd /opt


#Baixar java 1.8 e enviar via scp para os nós
# Descompacta o arquivo
sudo tar -xvf jdk-8u171-linux-x64.tar.gz

# Renomeia o diretório
sudo mv jdk1.8.0_171 /opt/jdk

# Ajusta os privilégios
cd /opt
sudo chown -R root:root jdk


# Configurando as variáveis de ambiente

cd ~
vi .bash_profile

# Java JDK 1.8
export JAVA_HOME=/opt/jdk
export JRE_HOME=/opt/jdk/jre
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

source .bash_profile


# Verifica a versão
java -version



########################################################################################################
########################################################################################################

# Instalação Data Lake
# Instalando e Configurando o Hadoop

# # # APENAS NO NODE MASTER (por enquanto)

# Acessa o diretório
cd /opt

# Faz download do Hadoop
sudo wget http://www-us.apache.org/dist/hadoop/common/hadoop-3.1.0/hadoop-3.1.0.tar.gz

# Descompacta o arquivo
tar -xvf hadoop-3.1.0.tar.gz

# Muda o proprietário
chown -R hadoop:hadoop /opt/hadoop


# Testando a instalação
su hadoop
cd /opt/hadoop/bin
./hadoop version


# Variáveis de ambiente do usuário Hadoop (configurar em todos os servidores)
vi .bash_profile

# Java JDK 1.8
export JAVA_HOME=/opt/jdk
export JRE_HOME=/opt/jdk/jre
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

# Hadoop
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

source .bash_profile

#TESTANDO
hadoop version


#########################################################################################################
#########################################################################################################


# Instalando e Configurando o Hadoop no NameNode

# Editar o arquivo hadoop-env.sh e adicionar as linhas:
vim /opt/hadoop/etc/hadoop/hadoop-env.sh

#incluir linhas:
export HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
export PATH="${PATH}:${HADOOP_HOME}/bin"
export HADOOP_SSH_OPTS="-i ~/.ssh/hdp-key"

#descomentar e alterar linhas:
export JAVA_HOME=/opt/jdk
.
.
export HADOOP_HOME=/opt/hadoop



# Editar o arquivo core-site.xml e adicionar as linhas:
vim $HADOOP_CONF_DIR/core-site.xml

#incluir os parâmetros e verificar nome/endereço do node master
<configuration>
   <property>
     <name>fs.default.name</name>
     <value>hdfs://hdpmaster:19000</value>
   </property>

# as seguintes configurações permitem que os usuários hadoop, hiveuser e hueuser se identifiquem como outros usuários
# permite o acesso das aplicações ao HDFS

	<property>
		<name>hadoop.proxyuser.hadoop.hosts</name>
		<value>*</value>
	</property>

	<property>
		<name>hadoop.proxyuser.hadoop.groups</name>
		<value>*</value>
	</property>

</configuration>

# Cria os diretórios abaixo
mkdir -p /opt/hadoop/dfs/data
mkdir -p /opt/hadoop/dfs/namespace_logs


# Editar o arquivo hdfs-site.xml e adicionar as linhas:
vim $HADOOP_CONF_DIR/hdfs-site.xml

#incluir os parâmetros
<configuration>
    <property>
      <name>dfs.replication</name>
      <value>2</value>
    </property>
    <property>
      <name>dfs.namenode.name.dir</name>
      <value>/opt/hadoop/dfs/namespace_logs</value>
    </property>
    <property>
      <name>dfs.datanode.data.dir</name>
      <value>/opt/hadoop/dfs/data</value>
    </property>
</configuration>


# Editar o arquivo workers e adicionar as linhas:
vim $HADOOP_CONF_DIR/workers

#deletar localhost e incluir os endereços ou nomes dos workers (verificar arquivo /etc/hosts)
hdpslv1
hdpslv2


# Editar o arquivo mapred-site.xml e adicionar as linhas:
vim $HADOOP_CONF_DIR/mapred-site.xml

#incluir linhas
<configuration>
    <property>
       <name>mapreduce.job.user.name</name>
       <value>hadoop</value>
    </property>

   <property>
      <name>yarn.resourcemanager.address</name>
      <value>hdpmaster:8032</value>
   </property>

   <property>
	    <name>mapreduce.framework.name</name>
	    <value>yarn</value>
   </property>

   <property>
     <name>yarn.app.mapreduce.am.env</name>
     <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
   </property>

   <property>
     <name>mapreduce.map.env</name>
     <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
   </property>

   <property>
     <name>mapreduce.reduce.env</name>
     <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
   </property>

</configuration>



# Editar o arquivo yarn-site.xml e adicionar as linhas:
vim $HADOOP_CONF_DIR/yarn-site.xml

#incluir parâmetros:
<configuration>

  <property>
     <name>yarn.resourcemanager.hostname</name>
     <value>hdpmaster</value>
  </property>

  <property>
     <name>yarn.nodemanager.resource.memory-mb</name>
     <value>1536</value>
  </property>

  <property>
     <name>yarn.scheduler.maximum-allocation-mb</name>
     <value>1536</value>
  </property>

  <property>
     <name>yarn.scheduler.minimum-allocation-mb</name>
     <value>128</value>
  </property>

  <property>
     <name>yarn.nodemanager.vmem-check-enabled</name>
     <value>false</value>
  </property>

  <property>
     <name>yarn.server.resourcemanager.application.expiry.interval</name>
     <value>60000</value>
   </property>

  <property>
     <name>yarn.nodemanager.aux-services</name>
     <value>mapreduce_shuffle</value>
   </property>

  <property>
     <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
     <value>org.apache.hadoop.mapred.ShuffleHandler</value>
   </property>

  <property>
     <name>yarn.log-aggregation-enable</name>
     <value>true</value>
   </property>

  <property>
     <name>yarn.log-aggregation.retain-seconds</name>
     <value>-1</value>
   </property>

  <property>
     <name>yarn.application.classpath</name>
   <value>$HADOOP_CONF_DIR,${HADOOP_COMMON_HOME}/share/hadoop/common/*,${HADOOP_COMMON_HOME}/share/hadoop/common/lib/*,${HADOOP_HDFS_HOME}/share/hadoop/hdfs/*,${HADOOP_HDFS_HOME}/share/hadoop/hdfs/lib/*,${HADOOP_MAPRED_HOME}/share/hadoop/mapreduce/*,${HADOOP_MAPRED_HOME}/share/hadoop/mapreduce/lib/*,${HADOOP_YARN_HOME}/share/hadoop/yarn/*,${HADOOP_YARN_HOME}/share/hadoop/yarn/lib/*</value>
   </property>

</configuration>


##### CRIAR O DIRETÓRIO HADOOP NOS DATANODES:
ssh hdpslv1
cd /opt
sudo mkdir hadoop
sudo chown -R hadoop:hadoop hadoop/

# VOLTAR AO NODE MASTER
cd /opt
scp -rv hadoop hdpslv1:/opt
scp -rv hadoop hdpslv2:/opt
# as saídas devem apresentar "exit code: 0"

# Instalando e Configurando o Hadoop
# Como usuário hadoop no Node Master, formatar o NameNode:
hdfs namenode -format


# Iniciar o HDFS e o YARN
start-dfs.sh && start-yarn.sh

# Acesso ao cluster via browser (caso use aws, use o endereço DNS público):
hdpmaster:9870

# (se tiver problema ao conectar, verifique o firewall do servidor: service firewalld status) e pare o serviço assim:
service firewalld stop
#o ideal é configurar o firewalld

# Analisar o cluster:
hdfs dfsadmin -report


#################### TROUBLE SHOOTING ####################

#caso os datanodes não estejam "in service", dê um "refresh"
hdfs dfsadmin -refreshNodes

# uma possibilidade é ir em todos os nodes e deletar os arquivos e diretórios das pastas de dados e logs:
# tentar os comandos  ------- CASO AINDA NÃO HAJA ARQUIVOS IMPORTANTES NO HDFS!!!!

#em todos os nós:
rm -rf $HADOOP_HOME/dfs/data/*
rm -rf $HADOOP_HOME/dfs/namespace_logs/*
# no NameNode
hdfs namenode -format

#################### TROUBLE SHOOTING ####################


# Testando o cluster:
mkdir Downloads
cd Downloads
echo "import this" | python >> zen.txt

# Vários comandos do unix (mkdir, rm, mv, cp, cat, e etc) funcionam no hdfs, sendo passados como opções para o comando "hdfs dfs"
# Preferencialmente passar os caminhos do hdfs entre aspas (evita comportamentos inesperados no ambiente local)
# criar uma pasta HDFS:
hdfs dfs -mkdir "/datasets"

#envia um arquivo para a pasta "datasets" no HDFS
hdfs dfs -put zen.txt "/datasets"

# inspeciona os arquivos presentes na pasta do HDFS
hdfs dfs -ls "/datasets"


# Executando o Job de processamento de MapReduce via YARN (contagem de palavras no arquivo)
# Verificar a versão do arquivo .jar
yarn jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-"versão".jar wordcount "/datasets/zen.txt" output


# Checando a execução do Job:
yarn node -list
yarn application -list

# ver a saída do job:
hdfs dfs -cat "/datasets/output/*"
hdfs dfs -cat "/datasets/output/*" | grep "better"

# Acessar YARN via browser (pode ser útil para verificar jobs não executados):
hdpmaster:8088/cluster

# Parar o cluster:
stop-yarn.sh && stop-dfs.sh
