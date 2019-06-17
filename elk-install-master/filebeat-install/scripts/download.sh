#!/bin/bash

version=6.4.0

wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$version\-linux-x86_64.tar.gz

cd ../packets
mkdir -p pre-tar-file 
pre_tar_files=`find . -maxdepth 1 -name "filebeat-*" -ls | awk '{print $11}'`
for tar_file in $pre_tar_files
do
    mv $tar_file pre-tar-file
done
cd - > /dev/null

mv filebeat-$version\-linux-x86_64.tar.gz ../packets/
