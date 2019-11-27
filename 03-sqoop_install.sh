
# Configuração da Camada de Aquisição de Dados com Sqoop

### Instalar o Postgresql e criar banco de exemplo
######### VRF SE OS COMANDOS VÃO FUNCIONAR ############

sudo yum install -y postgresql postgresql-server
sudo systemctl enable postgresql
sudo chown -R postgres:postgres /var/lib/pgsql/data
sudo postgresql-setup initdb
sudo systemctl start postgresql

sudo -u postgres psql
    # NO TERMINAL DO PGSQL:
    ALTER USER postgres PASSWORD 'postgres';
    CREATE DATABASE devdb;
    \c devdb;
    CREATE TABLE customer (nome VARCHAR, outro_nome VARCHAR);
    GRANT ALL PRIVILEGES ON customer TO postgres;
    INSERT INTO customer(nome, outro_nome) VALUES ('alexandre', 'castro');
    \q


# Download do Sqoop, descompactar, mudar o nome e o owner no diretório opt:
cd  /opt
sudo wget "{endereço do link para download}"
sudo tar -xvf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
sudo mv sqoop-1.4.7.bin__hadoop-2.6.0/ sqoop
sudo chown -R hadoop:hadoop sqoop/


# Configura as variáveis de ambiente
vim ~/.bash_profile

#incluir as linhas:

# Sqoop
export SQOOP_HOME=/opt/sqoop
export PATH=$PATH:$SQOOP_HOME/bin


# Testando
. .bash_profile
sqoop help


# Download do driver JDBC do PostgreSQL
cd /opt/sqoop/lib

# Visite https://jdbc.postgresql.org/ e vá em downloads para copiar o link
wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar

# copiar a classe commons-lang mais recente entre hadoop e sqoop para o outro
cp /opt/hadoop/share/hadoop/yarn/timelineservice/lib/commons-lang-2.6.jar /opt/sqoop/lib

# Lista as tabelas
sqoop list-tables --connect jdbc:postgresql://localhost/devdb --username postgres -P

# Importa a tabela
sqoop import --connect jdbc:postgresql://database-1.cho0e3yiegcg.us-east-2.rds.amazonaws.com/devdb --username postgres -P


# Verifica os dados no HDFS
hdfs dfs -ls
hdfs dfs -ls customer
hdfs dfs -cat customer/*

