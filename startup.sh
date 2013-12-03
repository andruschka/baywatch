#!/bin/bash
read -p "Run in production mode? [y/n] -> " answer

while true
do
  case $answer in
   [yY]* ) mrt --settings settings.json --production
           break;;

   [nN]* ) mrt --settings settings.json
           exit;;

   * )     echo "Dude, just enter Y or N, please."; break ;;
  esac
done