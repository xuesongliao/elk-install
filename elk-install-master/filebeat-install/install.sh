#!/bin/bash

base_data_dir=/data
base_install_dir=/opt
xpack=x-pack-6.0.0.zip

base_name=
link_name=

current_pwd=`pwd`


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

_init() {
    base_name=`echo $1 | awk -F '.tar.gz' '{print $1}'`
    link_name=`echo $1 | awk -F- '{print $1}'`

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
}

filebeat_install() {
    echo "++++++++++ filebeat install +++++++++++"
    cd packets

    tar_version=`ls filebeat-*`

    _init $tar_version

    usermod -G adm $link_name

    cp -r $current_pwd/configure/$link_name $base_data_dir
    cp $current_pwd/configure/service/$link_name.service /lib/systemd/system/

    chown $link_name: /$base_install_dir/$base_name/ -R && chown $link_name: $base_data_dir/$link_name -R
    systemctl daemon-reload && systemctl enable $link_name && systemctl start $link_name

    echo "======= success install filebeat ======"
    cd - > /dev/null
}

es_install() {
    echo "++++++++++ elasticsearch install +++++++++++"
    cd packets

    tar_version=`ls elasticsearch-*`

    _init $tar_version

    echo 262144 > /proc/sys/vm/max_map_count 
    cp $current_pwd/configure/etc_sysctl.d_71-elasticsearch.conf /etc/sysctl.d/elasticsearch.conf

    cp $current_pwd/configure/$link_name/$link_name $base_data_dir/$link_name
    cp $current_pwd/configure/$link_name/config/$link_name.yml $base_install_dir/$link_name/config
    cp $current_pwd/configure/service/$link_name.service /lib/systemd/system/

    $base_install_dir/$link_name/bin/elasticsearch-plugin install file://$current_pwd/packets/$xpack
    chown $link_name: /$base_install_dir/$base_name/ -R && chown $link_name: $base_data_dir/$link_name -R
    systemctl daemon-reload && systemctl enable $link_name && systemctl start $link_name
    echo "waiting for es start ..."
    sleep 30
    $base_install_dir/$link_name/bin/x-pack/setup-passwords interactive

    echo "======= success install elasticsearch ======"
    cd - > /dev/null
}

logstash_install(){
    echo "+++++++++++++ logstash install +++++++++++++"
    cd packets

    tar_version=`ls logstash-*`

    _init $tar_version

    echo $base_install_dir $link_name $base_data_dir
    cp -a $base_install_dir/$link_name/config $base_data_dir/$link_name
    cp -a $current_pwd/configure/$link_name/config/conf.d $base_data_dir/$link_name/config
    cp $current_pwd/configure/$link_name/config/{logstash.yml,startup.options,pipelines.yml} $base_data_dir/$link_name/config

    /opt/logstash/bin/system-install $base_data_dir/$link_name/config/startup.options

    $base_install_dir/$link_name/bin/$link_name-plugin install file://$current_pwd/packets/$xpack
    chown $link_name: /$base_install_dir/$base_name/ -R && chown $link_name: $base_data_dir/$link_name -R
    systemctl daemon-reload && systemctl enable $link_name

    echo "========= success install logstash ========="
    cd - > /dev/null
}

kibana_install() {
    echo "++++++++++++++ kibana install ++++++++++++++"
    cd packets

    tar_version=`ls kibana-*`

    _init $tar_version

    cp $current_pwd/configure/$link_name/$link_name $base_data_dir/$link_name
    cp $current_pwd/configure/$link_name/config/$link_name.yml $base_install_dir/$link_name/config
    cp $current_pwd/configure/service/$link_name.service /lib/systemd/system/

    $base_install_dir/$link_name/bin/$link_name\-plugin install file://$current_pwd/packets/$xpack
    chown $link_name: /$base_install_dir/$base_name/ -R && chown $link_name: $base_data_dir/$link_name -R
    systemctl daemon-reload && systemctl enable $link_name && systemctl start $link_name

    echo "========== success install kibana =========="
    cd - > /dev/null
}

kafka_install() {
    echo "++++++++++++++ kafka install +++++++++++++++"
    cd packets

    tar_version=`ls kafka_*`
    base_name=`echo $tar_version | awk -F '.tgz' '{print $1}'`
    link_name=`echo $tar_version | awk -F_ '{print $1}'`

    useradd -r -m -d $base_data_dir/$link_name -s /sbin/nologin $link_name
    mkdir -pv $base_data_dir/$link_name/logs > /dev/null

    tar xf $tar_version -C /opt/
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
        Usage:  ./elk_install.sh -j install jdk  

                ./elk_install.sh -c install filebeat
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
        e)  es_install
            exit 0;;
        l)  logstash_install
            exit 0;;
        s)  kibana_install
            exit 0;;
        k)  kafka_install
            exit 0;;
        c)  filebeat_install
            exit 0;;
        *)  help_info
            exit 1;;
    esac
done
