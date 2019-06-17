#!/bin/bash

base_data_dir=/data
base_install_dir=/opt
xpack=x-pack-6.0.0.zip

base_name=
link_name=

current_pwd=`pwd`

set -e

jdk_install() {
    echo "+++++++++++++++ Java install +++++++++++++++"
    cd packets

    jdk=`ls jdk-*`
    tar xf $jdk -C $base_install_dir

    if [ -L $base_install_dir/java ];
    then
        unlink /opt/java
    fi

    jdk_small_version=`echo $jdk | awk -F- '{print $2}' | awk -Fu '{print $2}'`
    jdk_version=`ls -d /opt/jdk1* | grep $jdk_small_version`
    ln -svf $jdk_version /opt/java > /dev/null
    ln -svf /opt/java/bin/java /usr/bin/ > /dev/null
    cp $current_pwd/configure/etc_profile.d_java.sh /etc/profile.d/java.sh
    source /etc/profile.d/java.sh 

    echo "=========== success install java ==========="
    cd - > /dev/null
}




kafka_install() {
    echo "++++++++++++++ kafka install +++++++++++++++"
    cd packets

    tar_version=`ls kafka_*`

    base_name=`echo $tar_version | awk -F '.tgz' '{print $1}'`
    link_name=`echo $tar_version | awk -F_ '{print $1}'`

    if id $link_name &> /dev/null; then
        echo "User: $link_name is exists"
    else
        useradd -r -m -d $base_data_dir/$link_name -s /sbin/nologin $link_name
    fi

    mkdir -p $base_data_dir/$link_name/logs > /dev/null

    tar xf $tar_version -C /opt/

    if [ -L /opt/$link_name ]; then
        unlink /opt/$link_name 
    fi
    ln -svf /opt/$base_name /opt/$link_name > /dev/null


    cp -a $base_install_dir/$link_name/config $base_data_dir/$link_name/
    cp $current_pwd/configure/$link_name/env $base_data_dir/$link_name/
    cp $current_pwd/configure/$link_name/config/{zookeeper.properties,producer.properties,consumer.properties,server.properties,log4j.properties} \
        $base_data_dir/$link_name/config/

    cp $current_pwd/configure/service/$link_name*.service /lib/systemd/system/

    chown $link_name: /$base_install_dir/$base_name/ -R && chown $link_name: $base_data_dir/$link_name -R
    systemctl daemon-reload && systemctl enable $link_name\-zookeeper && systemctl enable $link_name
    echo "========== success install kafka ==========="
    cd - > /dev/null
}

help_info(){                                                                                                                                                                          
    echo "
        Usage:  ./elk_install.sh -s  
                ./elk_install.sh -c 
        "
}

if [ $# -lt 1 ]; then
    help_info
fi

while getopts :jelktsc opt
do
    case $opt in
        j)  jdk_install
            exit 0;;
        k)  kafka_install
            exit 0;;
        *)  help_info
            exit 1;;
    esac
done
