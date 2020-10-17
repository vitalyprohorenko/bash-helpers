#!/bin/bash
echo "Load library"
source "../menu-creator/menu-creator.2b.shlib" 

echo "Configuring menu"
menuSet color ef 1
menuSet color eb 10
menuSet align right
menuSet shift cols -2
menuSet spaces "                 "
echo "Add header"
menuAdd header "#################"
menuAdd header "#################"
menuAdd header "#################"
echo "Edit header"
menuAdd header @1 "#     HEADER    #"
echo "Add menu"
menuAdd "Test 0"
menuAdd "Test 1"
menuAdd "Test 2"
menuAdd "Test 3"
menuAdd "Test 4"
menuAdd "Test 5"
menuAdd "Test 6"
echo "Edit menu"
menuAdd @3 "#Test unavailable"
menuAdd @4 "#Test unavailable"

while  true; do
  read -n1 -t0.01 line
  case "$line" in
    "A") menuNavi up;;
    "B") menuNavi down;;
    "q") menuClear; exit;;
  esac
  menuRefresh
  sleep 0.2
done

