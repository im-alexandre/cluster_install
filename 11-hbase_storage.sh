# baixar o hbase - bin (não o client)
cd
wget https://www-us.apache.org/dist/hbase/2.2.2/hbase-2.2.2-bin.tar.gz
tar -xf hbase-2.2.2-bin.tar.gz
sudo mv hbase-2.2.2 /opt/hbase

#variáveis de ambiente
vim .bash_profile

#incluir as linhas
#HBASE
export HBASE_HOME=/opt/hbase
export PATH=$PATH:$HBASE_HOME/bin
export CLASSPATH=$CLASSPATH:/opt/hbase/lib/*:.

. .bash_profile

# o HBASE pode apontar para um namenode, conversando com outro cluster, ou pode ser
# configurado nas mesmas máquinas (evitando problemas de latência)
vim /opt/hbase/conf/hbase-env.sh

#descomentar/alterar as linhas:
export JAVA_HOME=/opt/jdk
export HBASE_MANAGES_ZK=true

#configurar o hbase
vim /opt/hbase/conf/hbase-site.xml

#Incluir
<configuration>

     <property>
           <name>hbase.rootdir</name>
           <value>hdfs://hdpslv2:19000/hbase</value>
     </property>
     <property>
           <name>hbase.cluster.distributed</name>
           <value>true</value>
      </property>
      <property>
           <name>hbase.zookeeper.property.dataDir</name>
           <value>/home/hadoop/zookeeper</value>
      </property>
      <property>
           <name>hbase.zookeeper.quorum</name>
           <value>hdpslv2</value>
      </property>
     <property>
           <name>hbase.zookeeper.property.clientPort</name>
           <value>2181</value>
     </property>
     <property>
           <name>hbase.unsafe.stream.capability.enforce</name>
           <value>false</value>
     </property>

</configuration>


#configurar os regionservers
vim regionservers
#incluir os endereços dos escravos

########copiar a pasta hbase nos nós escravos
########configurar as variáveis de ambiente nos escravos
#########o Hbase depende de ssh sem senha, assim como o HDFS

#copiar dependências - hbase master não inicia sem elas:
cp $HBASE_HOME/lib/client-facing-thirdparty/htrace-core4-4.2.0-incubating.jar $HBASE_HOME/lib/
cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar /opt/hbase/lib/

#testando
hbase shell

#no shell hbase:
status

###################utilizando o shell
create 'cdr', 'index', 'customer', 'type', 'timing', 'usage', 'correspondent', 'network'
list
put 'cdr', '010', 'index:customerindex', '0'
scan 'cdr'
