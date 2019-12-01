#instalar as dependências:

sudo yum install -y postgresql-dev # dependência para instalar o psycopg2

sudo yum install ant gcc g++ make python-devel.x86-64 -y
sudo yum groupinstall "Development Tools"
sudo yum install -y krb5-devel \
libxslt-devel libxml2-devel \
mysql-devel.x86_64 \
mysql-devel \
ncurses-devel zlib-devel texinfo gtk+-devel gtk2-devel \
qt-devel tcl-devel tk-devel kernel-headers kernel-devel \
gmp-devel.x86_64 \
sqlite-devel.x86_64 \
cyrus-sasl.x86_64 \
postfix system-switch-mail \
cyrus-imapd cyrus-plain \
cyrus-md5 cyrus-utils postfix \
system-switch-mail cyrus-imapd \
cyrus-plain cyrus-md5 cyrus-utils \
memcached-devel.x86_64 \
libevent libevent-devel \
postfix \
cyrus-sasl \
cyrus-imapd \
openldap-devel


### instalação maven
### O maven compila códigos java (não pesquisei a fundo)

cd /opt
sudo  wget http://mirror.nbtelecom.com.br/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
sudo tar -xf apache-maven-3.5.4-bin.tar.gz
sudo mv apache-maven-3.5.4 maven
sudo rm apache-maven-3.5.4-bin.tar.gz
sudo chown -R hadoop:hadoop maven

cd
vim .bash_profile


#MAVEN_HOME

export MAVEN_HOME=/opt/maven
export PATH=$PATH:$MAVEN_HOME/bin

. .bash_profile


### testando
mvn -version


# MAIS DEPENDÊNCIAS:
sudo yum install -y asciidoc cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain \
krb5-devel libffi-devel libxml2-devel libxslt-devel openldap-devel gmp-devel sqlite-devel \
python-devel \
mysql mysql-devel openssl-devel

# a libtidy estava no tutorial inicial, mas não está no repositório oficial,
# logo, baixar e instalar
wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64/libtidy-5.4.0-1.sdl7.x86_64.rpm
sudo rpm -Uvh libtidy-5.4.0-1.sdl7.x86_64.rpm


# Baixar e instalar o HUE
# Verificar outra fonte (pode ser baixado e compilado a partir do github) --- TESTAR ---
cd /opt
sudo wget https://www.dropbox.com/s/0rhrlnjmyw6bnfc/hue-4.2.0.tgz
sudo tar -xf hue-4.2.0.tgz
sudo rm -rf hue-4.2.0.tgz
pushd hue-4.2.0
sudo make install
popd

# o HUE fica em um subdiretório de /var/local ou /usr/local ---- VRF
vim ~/.bash_profile


# IMPORTANTE !!!!!!!
# O hue é o único que rodamos como sudo, para usar o "nohup", é melhor que ele seja executado sem senha
# Editar o arquivo sudoers
sudo vim /etc/sudoers

# ATENÇÃO!!!
#incluir a linha:
hadoop  ALL=(ALL)   NOPASSWD: "HUE_HOME"/build/env/bin/supervisor  ##verificar o path do "HUE_HOME" e substituir pelo path absoluto

#inicializar HUE
sudo $HUE_HOME/build/env/bin/supervisor

#acessar via browser:
hdpmaster:8888

#interromper o HUE:
# localizar o processo PAI, matar e depois matar o filho:
ps -f -u hue
kill "PID DO PAI"

ps -f -u hue
kill "PID QUE RESTOU"


#migrar os metadados para o Postgresql
#diretório de configurações:
$HUE_HOME/desktop/conf

sudo -u postgres psql
    # no console do PSQL:
    CREATE USER hueuser WITH password 'huepass';
    CREATE DATABASE hue;
    GRANT ALL PRIVILEGES ON DATABASE hue TO hueuser;
    \q


#criar diretório de backup e efetuar dump do arquivo de configurações do hue
mkdir /home/hadoop/bkp_conf
sudo $HUE_HOME/build/env/bin/hue dumpdata > ~/bkp_conf/hue_db_dump.json
sudo cp $HUE_HOME/desktop/conf/hue.ini  ~/bkp_conf/

#configuração HUE
sudo vim $HUE_HOME/desktop/conf/hue.ini


#Editar o arquivo core-site.xml
vim $HADOOP_CONF_DIR/core-site.xml

#incluir os parâmetros:
<property>
  <name>hadoop.proxyuser.hueuser.hosts</name>
  <value>*</value>
</property>

<property>
  <name>hadoop.proxyuser.hueuser.groups</name>
  <value>*</value>
</property>


# INCLUIR/ALTERAR/DESCOMENTAR AS LINHAS:
# O ARQUIVO É GRANDE: USAR "/" PARA PESQUISAR NO VIM
    [[database]]

        engine=postgresql_psycopg2
        host=localhost
        port=5432
        user=hueuser
        password=huepass

        name=hue

    [[hdfs_clusters]]
        [[[default]]]
            fs_defaultfs=hdfs://localhost:8020
            webhdfs_url=http://localhost:9870/webhdfs/v1


    [[yarn_clusters]]

        [[[default]]]
            # Enter the host on which you are running the ResourceManager
            resourcemanager_host= hdpmaster  #nome ou endereço do nodemaster

            resourcemanager_port=8032  #Porta em que o ResourceManager ouve (YARN)

            submit_to=True  #Whether to submit jobs to this cluster

            resourcemanager_api_url=http://hdpmaster:8088    #URL da API do ResourceManager YARN


    default_hdfs_superuser=hadoop

    hive_conf_dir=/opt/hive/conf

#alterar /var/lib/psql/data/pg_hba.conf
host    hue   hueuser   0.0.0.0/0   md5


sudo passwd hue
su - hue
source /opt/hue/build/env/bin/activate
sudo pip install psycopg2 psycopg2-binary


# Execute os seguintes comandos abaixo (Importante que o HUE esteja com os serviços interrompidos!)
# DEVE DAR PROBLEMA COM A AUTENTICAÇÃO IDENT DO POSTGRESQL, VERIFICAR O ARQUIVO /var/lib/pgsql/data/pg_hba.conf

sudo $HUE_HOME/build/env/bin/hue syncdb --noinput
sudo $HUE_HOME/build/env/bin/hue migrate
sudo $HUE_HOME/build/env/bin/hue loaddata ~/bkp_conf/hue_db_dump.json


#Reinicie tudo e Inicie novamente o Hue pelo supervisor
stop-yarn.sh && stop-dfs.sh && start-dfs.sh && start-yarn.sh
nohup hive --service hiveserver2 &
sudo nohup $HUE_HOME/build/env/bin/supervisor &


# testar o HIVE pelo HUE. Verificar o campo "administration"


#HUE_HOME
export HUE_HOME="VERIFICAR O LOCAL"
export PATH=$PATH:$HUE_HOME/bin

. ~/.bash_profile
