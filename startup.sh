#!/bin/bash
read -p "Run in PRODUCTION mode? [y/n] -> " answer

while true
do
  case $answer in
   [yY]* ) meteor --settings settings.json --production
           break;;

   [nN]* ) meteor --settings settings.json
           exit;;

   * )     echo "Dude, just enter Y or N, please."; break ;;
  esac
done
