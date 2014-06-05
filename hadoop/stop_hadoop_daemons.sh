

MASTER=${MASTER_FLAG}

## Stop HDFS daemons

if [[ $MASTER -eq 1 ]]; then
	# Stop the namenode daemon
	# ONLY ON THE NAMENODE NODE
	echo "Namenode stop"
	$HADOOP_PREFIX/sbin/hadoop-daemon.sh stop namenode
	
else
	echo "Skipping namenode stop"
fi

# stop the datanode daemon
# ON ALL SLAVES
echo "Datanode stop"
$HADOOP_PREFIX/sbin/hadoop-daemon.sh stop datanode 

## Stop YARN daemons
if [[ $MASTER -eq 1 ]]; then
	# Stop the resourcemanager daemon
	# ONLY ON THE RESOURCEMANAGER NODE
	echo "Yarn ResourceManager stop"
	$HADOOP_PREFIX/sbin/yarn-daemon.sh stop resourcemanager
else
	echo "Skipping Yarn ResourceManager stop"
fi


# Stop the nodemanager daemon
# ON ALL SLAVES
echo "Nodemanager stop"
$HADOOP_PREFIX/sbin/yarn-daemon.sh stop nodemanager




echo "System stopped."