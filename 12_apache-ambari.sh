#Instalação do ambari
#Configurar o ssh sem senha e o arquivo /etc/hosts
#Caso use AWS, escolher o amazon AMI2
#ambari utiliza o HDFS para logs, arquivos de configuracão, etc
#baixa o arquivo de repositório na pasta de repositórios do centos
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum update
#instalação
sudo yum install -y ambari-server

#setup do ambari
ambari-server setup
#configurar ou não o jdk. Verificar se a máquina já tem o jdk

#Iniciar
sudo ambari-server start

#verificar a instalação do python
sudo ambari-server status

#acessar via browser: porta 8080
senha:admin
login:admin

#ao confiurar o ssh, copiar a chave privada e colar no campo do ambari
