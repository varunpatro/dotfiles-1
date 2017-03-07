#!/bin/bash

if [ -z $@ ]
then
    rg --files --null 2> /dev/null | xargs -0 dirname | uniq
else 
    xdg-open "$@" > /dev/null &
fi
