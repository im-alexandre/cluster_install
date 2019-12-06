### Download Hive
cd /opt
sudo wget https://www-us.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
sudo tar -xf apache-hive-3.1.2-bin.tar.gz
sudo mv apache-hive-3.1.2-bin hive
sudo chown -R hadoop:hadoop hive


# Variáveis de ambiente
cd
vim ~/.bash_profile

#Adicionar as seguintes variaveis:

#HIVE_HOME
export HIVE_HOME=/opt/hive
export PATH=$PATH:$HIVE_HOME/bin
export CLASSPATH=$CLASSPATH:$HADOOP_HOME/lib/*:.
export CLASSPATH=$HIVE_HOME/lib/*:.

. .bash_profile


### ----- PARTE PROBLEMÁTICA ------ ###
# VRF A VERSÃO MAIS NOVA E COPIAR PARA O OUTRO DIRETÓRIO
#Não esquecer de apagar o arquivo mais antigo após copiar:
ls $HIVE_HOME/lib | grep guava
ls $HADOOP_HOME/share/hadoop/common/lib/ | grep guava


#testando
hive --version

### driver jdbc
cd $HIVE_HOME/lib
wget https://jdbc.postgresql.org/download/postgresql-42.2.4.jre6.jar


### Criar o metastore DataBase
sudo -u postgres psql
    # no terminal do psql
    CREATE USER hiveuser WITH PASSWORD 'hivepass';
    CREATE DATABASE metastore;
    GRANT ALL PRIVILEGES ON DATABASE metastore to hiveuser;
    \q

########### ------- PARTE PROBLEMÁTICA, TALVEZ ROLE UM TROUBLE SHOOTING LÁ NA FRENTE COM O BEELINE -----------############
### editar o arquivo pg_hba.conf
sudo vim /var/lib/pgsql/data/pg_hba.conf

# incluir a linha (procurar uma linha parecida - IPV4):
host	    all		all        0.0.0.0/0		 md5
host		  hive	hiveuser   0.0.0.0/0		 md5
#alterar a seguinte linha
host      all   all        127.0.0.1/32  md5



### editar o arquivo postgresql.conf
sudo vim /var/lib/pgsql/data/postgresql.conf

#incluir a linha:

listen_addresses = '*'

#reiniciar o postgresql
sudo systemctl restart postgresql



### editar o arquivo hive-site.xml
vim /opt/hive/conf/hive-site.xml

#incluir parâmetros:
<configuration>
	<property>
		<name>javax.jdo.option.ConnectionURL</name>
        #verificar o nome/endereço do servidor do metastore
		<value>jdbc:postgresql://hdpmaster:5432/metastore</value>
	</property>

	<property>
		<name>javax.jdo.option.ConnectionDriverName</name>
		<value>org.postgresql.Driver</value>
	</property>

	<property>
    		<name>javax.jdo.option.ConnectionUserName</name>
		<value>hiveuser</value>
	</property>

	<property>
		<name>javax.jdo.option.ConnectionPassword</name>
		<value>hivepass</value>
	</property>

	<property>
		<name>hive.server2.thrift.port</name>
		<value>10000</value>
		<description>TCP port number to listen on, default 10000</description>
	</property>

	<property>
		<name>hive.server2.thrift.bind.host</name>
		<value>localhost</value>
		<description>HiveServer2 bind host</description>
	</property>

	<property>
		<name>datanucleus.autoCreateSchema</name>
		<value>false</value>
	</property>

	<property>
		<name>hive.metastore.schema.verification</name>
		<value>true</value>
	</property>

    #Habilitar a conexão para o HUE
    <property>
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
    </property>

</configuration>


### Iniciar o hadoop-yarn
start-dfs.sh && start-yarn.sh

# testando
hive -version


### iniciando o schematool
###----------PARTE PROBLEMÁTICA-------------###
### DEVE ROLAR UM TROUBLE SHOOTING
schematool -dbType postgres -initSchema

### iniciando o hiveserver2
#nohup desvincula o processl do tty atual, apertar enter para continuar o trabalho

#verificar se está tudo rodando:
jps

#deve retornar RunJar

### Configurações do HADOOP
# verificar os parâmetros hadoop.proxyuser core-site.xml
vim $HADOOP_CONF_DIR/core-site.xml

# Incluir os parâmetros:
  <property>
    <name>hadoop.proxyuser.<user_connected_to_hdfs>.hosts</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.<user_connected_to_hdfs>.groups</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.hduser.hosts</name>
    <value>*</value>
  </property>
  <property>
    <name>hadoop.proxyuser.hduser.groups</name>
    <value>*</value>
  </property>

# devem conter o usuário do hive no nome do parâmetro

### REINICIAR TUDO
stop-yarn.sh && stop-dfs.sh && start-dfs.sh && start-yarn.sh
nohup hive --service hiveserver2 &

### testando o beeline (e orando)
### ------------ PARTE PROBLEMÁTICA -----------###
### IR EM /var/lib/pgsql/data/ E VRF OS ARQUIVOS postgresql.conf e pg_hba.conf
beeline

#no console beeline
!connect jdbc:hive2://localhost:10000 hiveuser hivepass org.apache.hive.jdbc.HiveDriver


############### ---- PODE SER QUE SEJA NECESSÁRIO: ---------- ################
# se o beeline não conectar:
sudo -u postgres psql
    # no console do psql:
    DROP DATABASE metastore;
    CREATE DATABASE metastore;

schematool -dbType postgres -initSchema


#Entrando no shell hive
#iniciar o hdfs
hive

#testando no console hive
create table datalake (nome string, outro string);

#verificando o metastore
sudo -u postgres psql

#no console psql
\c metastore
SELECT * FROM "TBLS";

#acessando arquivos do HDFS
vim teste.txt

######teste.txt #######
1000;user1
2000;user2
#######################

hdfs dfs -mkdir "/teste"
hdfs dfs -put teste.txt "/teste"
hive

#no console do hive
create external table tb_teste(
id int,
name string
)
row format delimited
fields delimited by ';'
location '/teste';
##############################
