# Instalação do Anaconda:

#download:
cd
wget https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
chmod +x Anaconda3-2019.10-Linux-x86_64.sh

#fazer um backup do .bash_profile (não custa nada)
cp .bash_profile .bash_profile.bak

# instalar o anaconda:
./Anaconda3-2019.10-Linux-x86_64.sh

# copiar as variáveis de ambiente do .bash_profile e colar no .bashrc
# o centos usa o arquivo .bash_profile, logo, temos que renomear o .bashrc
mv .bashrc .bash_profile
. .bash_profile

# se tudo der certo:
rm .bash_profile.bak


########################################################################################################################
########################################################################################################################


# INSTALAÇÃO DO SPARK
# Caso os serviços ainda não estejam iniciados, inicie-os:
start-dfs.sh && start-yarn.sh

#baixar o SPARK:
cd /opt
sudo wget https://www-us.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
sudo tar -xvf spark-2.3.0-bin-hadoop2.7.tgz
sudo mv spark-2.3.0-bin-hadoop2.7 spark
sudo chown -R hadoop:hadoop spark


# Variáveis de Ambiente:
vim .bash_profile

#Incluir as variáveis:

# Spark
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_HOME=/opt/spark
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH
export PATH=$PATH:$SPARK_HOME/bin

# Aqui é o pulo do gato! Configurar o pyspark com o python 3 e para abrir direto com o jupyter lab
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='lab --no-browser --port=8899'


#salve o arquivo e execute:
source .bash_profile


# O seguinte comando vai gerar um script de configuração:
jupyter notebook --generate-config ## VRF se funciona com
cd .jupyter
vim jupyter_notebook_config.py

# O arquivo é gigante, descomente e altere as seguintes linhas (usar / para pesquisar no vim):
c.NotebookApp.allow_origin = '*'
c.NotebookApp.ip = '0.0.0.0'


# NA MÁQUINA LOCAL (CLIENTE!!!):
cd ~/.bin
vim pyspark

# script pyspark ------------------------

#!/bin/bash
echo "pyspark" |ssh -L 9000:hdpmaster:8899 hadoop@hdpmaster &
sleep 4
google-chrome --new-window 'http://localhost:9000'

# script pyspark ------------------------
#permissão de execução e incluir no path
chmod +x pyspark
ln -sf ./pyspark /usr/local/bin

#testando (verificar se o script está no path)
pyspark  # demora um pouco para garantir que o navegador vai iniciar depois de tudo resolvido

#copiar o TOKEN do console e colar na página que aparecer