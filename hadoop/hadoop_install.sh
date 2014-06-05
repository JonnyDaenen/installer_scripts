
# ask settings
read -p "install dir: (e.g. ~/hadoop):" INSTALL_DIR
eval INSTALL_DIR=$INSTALL_DIR
read -p "hadoop username: " USERNAME
read -p "address of the resource manager: " RES_MANAGER_ADDR
read -p "Is this the master? (y/n): " response
if printf "%s\n" "$response" | grep -Eq "$(locale yesexpr)"; then
	MASTER=1
else
	MASTER=0
fi



# get script location
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ENVFILE=$INSTALL_DIR/env/hadoop-2.2.0_env.sh

echo "Creating directory structure in " $INSTALL_DIR
mkdir -p $INSTALL_DIR/env/scripts
HDFS_NAMENODE_DIR=$INSTALL_DIR/hdfs/namenode
HDFS_DATANODE_DIR=$INSTALL_DIR/hdfs/datanode
mkdir -p $HDFS_NAMENODE_DIR
mkdir -p $HDFS_DATANODE_DIR

cd $INSTALL_DIR 

# fetch hadoop package
read -p "Download? (y/n): " response
if printf "%s\n" "$response" | grep -Eq "$(locale yesexpr)"; then
	echo "Retrieving Hadoop..."
	curl http://apache.mirrors.spacedump.net/hadoop/common/stable/hadoop-2.2.0.tar.gz > hadoop-2.2.0.tar.gz
else
	cp $INSTALLER_DIR/hadoop-2.2.0.tar.gz . 
fi

echo "Extracting..."
tar xf hadoop-2.2.0.tar.gz --gzip

echo "Setting environment"
touch $ENVFILE
chmod +x $ENVFILE
:>$ENVFILE
echo "# Hadoop variables" >> $ENVFILE
echo 'export HADOOP_HOME="'`pwd`'/hadoop-2.2.0"' >> $ENVFILE
echo 'export HADOOP_PREFIX=$HADOOP_HOME' >> $ENVFILE
echo 'export HADOOP_ENV="'$ENVFILE'"' >> $ENVFILE
echo 'export HADOOP_USER_NAME='$USERNAME >> $ENVFILE
echo 'export JAVA_HOME="'`/usr/libexec/java_home -v1.7`'"' >> $ENVFILE
echo 'export PATH=$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:$PATH' >> $ENVFILE
echo 'export PATH='$INSTALL_DIR'/env/scripts:$PATH' >> $ENVFILE
echo "" >> $ENVFILE

cat $INSTALL_DIR/hadoop_console.sh >> $ENVFILE
echo "" >> $ENVFILE

echo "Loading environment"
source $ENVFILE


echo "Copying HDFS settings"

HDFS_CONFIG=$HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
cp $INSTALLER_DIR/hdfs-site.xml $HDFS_CONFIG
sed -i .bak 's:${HDFS_NAMENODE_DIR}:'$HDFS_NAMENODE_DIR':g' $HDFS_CONFIG
sed -i .bak 's:${HDFS_DATANODE_DIR}:'$HDFS_DATANODE_DIR':g' $HDFS_CONFIG


echo "Copying CORE settings"
CORE_CONFIG=$HADOOP_PREFIX/etc/hadoop/core-site.xml
cp $INSTALLER_DIR/core-site.xml $CORE_CONFIG
sed -i .bak 's:${RESOURCEMANAGER_ADDRESS}:'$RES_MANAGER_ADDR':g' $CORE_CONFIG


echo "Copying YARN settings"
YARN_CONFIG=$HADOOP_PREFIX/etc/hadoop/yarn-site.xml
cp $INSTALLER_DIR/yarn-site.xml $YARN_CONFIG
sed -i .bak 's:${RESOURCEMANAGER_ADDRESS}:'$RES_MANAGER_ADDR':g' $YARN_CONFIG

echo "Copying MAPREDUCE settings"
MAPRED_CONFIG=$HADOOP_PREFIX/etc/hadoop/mapred-site.xml
cp $INSTALLER_DIR/mapred-site.xml $MAPRED_CONFIG
sed -i .bak 's:${RESOURCEMANAGER_ADDRESS}:'$RES_MANAGER_ADDR':g' $MAPRED_CONFIG

echo "Copying startup script"
STARTUP_SCRIPT=$INSTALL_DIR/env/scripts/start_hadoop_daemons.sh
cp $INSTALLER_DIR/start_hadoop_daemons.sh $STARTUP_SCRIPT
chmod +x $STARTUP_SCRIPT

echo "Copying stop script"
STOP_SCRIPT=$INSTALL_DIR/env/scripts/stop_hadoop_daemons.sh
cp $INSTALLER_DIR/stop_hadoop_daemons.sh $STOP_SCRIPT
chmod +x $STOP_SCRIPT


if [[ $MASTER -eq 1 ]]; then
	
	# master flag ON
	sed -i .bak 's:${MASTER_FLAG}:1:g' $STARTUP_SCRIPT
	sed -i .bak 's:${MASTER_FLAG}:1:g' $STOP_SCRIPT

	# Format the namenode directory (DO THIS ONLY ONCE, THE FIRST TIME)
	# ONLY ON THE NAMENODE NODE
	echo "Formatting namenode"
	$HADOOP_PREFIX/bin/hdfs namenode -formatda
else
	# master flag OFF
	sed -i .bak 's:${MASTER_FLAG}:0:g' $STARTUP_SCRIPT
	sed -i .bak 's:${MASTER_FLAG}:0:g' $STOP_SCRIPT
fi

# add scripts to path?
read -p "Add 'hadoopenv' executable to .bashrc? (y/n): " response

if printf "%s\n" "$response" | grep -Eq "$(locale yesexpr)"; then
	echo "# HADOOP ENVIRONMENT" >> ~/.bashrc
	echo "alias hadoopenv='bash -c \"source "$ENVFILE";bash\"'" >> ~/.bashrc
	echo "executable added."
fi


echo "Done."


