### Download Flume
cd /opt
sudo wget https://www-us.apache.org/dist/flume/1.9.0/apache-flume-1.9.0-bin.tar.gz
sudo tar -xf apache-flume-1.9.0-bin.tar.gz
sudo rm apache-flume-1.9.0-bin.tar.gz
mv apache-flume-1.9.0 flume
sudo chown -R hadoop:hadoop flume


### variáveis de ambiente:
cd
vim .bash_profile

#incluir as variáveis:
export FLUME_HOME=/opt/flume
export PATH=$PATH:$FLUME_HOME/bin/

#testando:
flume-ng --help

# criando diretório no hdfs para receber o streamming
hdfs dfs -mkdir -p "/user/hadoop/twitter_data/"
hdfs dfs -chmod -R 777 "/user/hadoop/twitter_data"
hdfs dfs -chmod -R 777 "/tmp"


# configurar o agente de conexão do twitter:
        # Nome dos componentes do agente
        TwitterAgent.sources = Twitter
        TwitterAgent.channels = MemChannel
        TwitterAgent.sinks = HDFS

        # Configuração do Source
        TwitterAgent.sources.Twitter.type = org.apache.flume.source.twitter.TwitterSource
        TwitterAgent.sources.Twitter.consumerKey = "token do app"
        TwitterAgent.sources.Twitter.consumerSecret = "token do app"
        TwitterAgent.sources.Twitter.accessToken = "token do app"
        TwitterAgent.sources.Twitter.accessTokenSecret = "token do app"
        TwitterAgent.sources.Twitter.keywords = bigdata, python, java, ai, database, nosql

        # Condiguração do Sink
        TwitterAgent.sinks.HDFS.type = hdfs
        TwitterAgent.sinks.HDFS.hdfs.path = hdfs://hdpmaster:19000/user/hadoop/twitter_data/
        TwitterAgent.sinks.HDFS.hdfs.fileType = DataStream
        TwitterAgent.sinks.HDFS.hdfs.writeFormat = Text
        TwitterAgent.sinks.HDFS.hdfs.batchSize = 1000
        TwitterAgent.sinks.HDFS.hdfs.rollSize = 0
        TwitterAgent.sinks.HDFS.hdfs.rollCount = 10000

        # Configuração do Channel
        TwitterAgent.channels.MemChannel.type = memory
        TwitterAgent.channels.MemChannel.capacity = 10000
        TwitterAgent.channels.MemChannel.transactionCapacity = 100

        # Ligando Source e Sink ao Channel
        TwitterAgent.sources.Twitter.channels = MemChannel
        TwitterAgent.sinks.HDFS.channel = MemChannel


# Streaming do twitter:
cd $FLUME_HOME
bin/flume-ng agent --conf ./conf/ -f conf/twitter.conf -Dflume.root.logger=DEBUG,console -n TwitterAgent