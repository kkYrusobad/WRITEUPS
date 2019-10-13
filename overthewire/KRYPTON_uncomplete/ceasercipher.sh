#!/bin/bash

IN="OMQEMDUEQMEK"

for I in $(seq 25); do 
echo $I $IN | tr $(printf %${I}s | tr ' ' '.' )\A-Z A-ZA-Z
done