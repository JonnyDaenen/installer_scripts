# CONSOLE

# load pig icon when utf-8 is enabled
CHARMAP=`locale charmap`
ICON='PIG ' 
if [ $CHARMAP = "UTF-8" ]; then 
	ICON=`echo -e "\xF0\x9F\x90\xB7 "`
fi

# set prompt
export PS1="$ICON[\\@ \\u@\\H \\W]\\$ "
export PS1="\e[0;35m$PS1\e[m"