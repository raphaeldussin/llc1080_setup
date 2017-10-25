#!/bin/bash

if [ "$NCAR_HOST" = "cheyenne" ]
then
	HOST_MAKEFILE="Makefile.cheyenne"
else
	echo "No makefile for host"
	return 1
fi

cat $HOST_MAKEFILE > Makefile
cat Makefile.template >> Makefile
