
# ask settings
read -p "install dir: (e.g. ~/pig):" INSTALL_DIR
eval INSTALL_DIR=$INSTALL_DIR

PIGVERSION=pig-0.12.1


# get script location
INSTALLER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ENVFILE=$INSTALL_DIR/env/${PIGVERSION}_env.sh

echo "Creating directory structure in " $INSTALL_DIR
mkdir -p $INSTALL_DIR/env/scripts

cd $INSTALL_DIR 

# fetch pig package
read -p "Download? (y/n): " response
if printf "%s\n" "$response" | grep -Eq "$(locale yesexpr)"; then
	echo "Retrieving Pig..."
	curl http://apache.cu.be/pig/$PIGVERSION/$PIGVERSION.tar.gz > $PIGVERSION.tar.gz
else
	cp $INSTALLER_DIR/$PIGVERSION.tar.gz . 
fi

echo "Extracting..."
tar xf $PIGVERSION.tar.gz --gzip
#rm $PIGVERSION.tar.gz

read -p "Download Jetty? (y/n): " response
if printf "%s\n" "$response" | grep -Eq "$(locale yesexpr)"; then
	echo "Retrieving Jetty..."
	curl http://dist.codehaus.org/jetty/jetty-6.1.26/jetty-6.1.26.zip -O
	mkdir -p  ~/.m2/repository/org/mortbay/jetty/jetty/6.1.26
	mv jetty-6.1.26.zip ~/.m2/repository/org/mortbay/jetty/jetty/6.1.26
fi

echo "Setting environment"
touch $ENVFILE
chmod +x $ENVFILE
:>$ENVFILE
echo "# Pig variables" >> $ENVFILE
echo 'export PIG_HOME="'`pwd`"/$PIGVERSION\"" >> $ENVFILE
echo 'export PATH=$PIG_HOME/bin:$PATH' >> $ENVFILE
echo "" >> $ENVFILE
cat $INSTALL_DIR/pig_console.sh >> $ENVFILE


echo "Loading environment"
source $ENVFILE

echo "Re-compiling for hadoop 2.x.x"
cd $PIGVERSION
ant clean jar-withouthadoop -Dhadoopversion=23
cd ..


# add scripts to path?
read -p "Add 'pigenv' executable to .bashrc? (y/n): " response

if printf "%s\n" "$response" | grep -Eq "$(locale yesexpr)"; then
	echo "# PIG ENVIRONMENT" >> ~/.bashrc
	echo "alias pigenv='bash -c \"source "$ENVFILE";bash\"'" >> ~/.bashrc
	echo "executable added."
fi

echo "Done."


