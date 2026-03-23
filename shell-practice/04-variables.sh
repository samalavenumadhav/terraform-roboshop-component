#!/bin/bash

START_TIME=$(date +%s)

echo "script executed at : $START_TIME"s

sleep 100 

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME-$START_TIME))

echo "script executed in: $TOTAL_TIME"
