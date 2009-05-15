#!/bin/sh

if [ $1 = 'upper' ]
then
	echo $2 | tr '[a-z]' '[A-Z]'
elif [ $1 = 'check_gcc' ]
then
	n1=`echo $2 | cut -d. -f1`
	n2=`echo $2 | cut -d. -f2`
	if [ $n1 > 4 ]
	then
		echo "ok"
	elif [ $n1 = 4 -a $n2 >= 3 ]
	then
		echo "ok"
	fi
fi

