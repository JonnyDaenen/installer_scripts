

## Start HDFS daemons
MASTER=${MASTER_FLAG}

if [[ $MASTER -eq 1 ]]; then
	# Start the namenode daemon
	# ONLY ON THE NAMENODE NODE
	echo "Namenode startup"
	$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
	
else
	echo "Skipping namenode startup"
fi

# Start the datanode daemon
# ON ALL SLAVES
echo "Datanode startup"
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode 


## Start YARN daemons
if [[ $MASTER -eq 1 ]]; then
	# Start the resourcemanager daemon
	# ONLY ON THE RESOURCEMANAGER NODE
	echo "Yarn ResourceManager startup"
	$HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager
else
	echo "Skipping Yarn ResourceManager startup"
fi

# Start the nodemanager daemon
# ON ALL SLAVES
echo "Nodemanager startup"
$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager

echo "System ready."