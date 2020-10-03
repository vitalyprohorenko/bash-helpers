#!/bin/bash
source "menu-creator/$(ls menu-creator --color=never --file-type -tq1 | tail -n1)" 

menuSet header "#################"
menuSet header "#################"
menuSet header "#################"
menuSet header @1 "#     HEADER    #"
menuAdd "Test 0"
menuAdd "Test 1"
menuAdd "Test 2"
menuAdd "Test 3"
menuAdd "Test 4"
menuAdd "Test 5"
menuAdd "Test 6"
menuAdd @3 "#Test unavailable"
menuAdd @4 "#Test unavailable"
menuShow
while  true; do
  read -n1 line
  case "$line" in
    "A") menuNavi up;;
    "B") menuNavi down;;
    "q") menuClear; exit;;
  esac
done

