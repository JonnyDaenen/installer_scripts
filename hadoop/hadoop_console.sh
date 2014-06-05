# CONSOLE

# load elephant icon when utf-8 is enabled
CHARMAP=`locale charmap`
ICON='HDP ' 
if [ $CHARMAP = "UTF-8" ]; then 
	ICON=`echo -e "\xF0\x9F\x90\x98  "`
fi

# set prompt
export PS1="$ICON[\\@ \\u@\\H \\W]\\$ "
export PS1="\e[0;35m$PS1\e[m"