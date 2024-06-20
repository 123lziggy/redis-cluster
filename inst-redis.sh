#!/bin/sh
cd ~
WERSJA=redis-7.2.5
IP=$(hostname -I)
PORTY=('6379' '6380')

if [ "$1" == "inst" ]
then 
cd ~
if [ -f "$WERSJA.tar.gz" ]; then
    echo "PLIK $WERSJA.tar.gz istnieje "
else 
  wget https://download.redis.io/releases/$WERSJA.tar.gz
fi
tar -zxvf $WERSJA.tar.gz
mkdir ~/$WERSJA-SRV ~/$WERSJA-SLAVE
cd ~/$WERSJA/src
make && make install
echo "################################################"
echo "Zainstalowano REDIS w wersji $WERSJA"
redis-server -v
rm ~/$WERSJA-SRV/redis-${PORTY[0]}.conf ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
echo "bind 127.0.0.1 $IP" >> ~/$WERSJA-SRV/redis-${PORTY[0]}.conf
#echo "masterauth redishaslo" >> ~/$WERSJA-SRV/redis-${PORTY[0]}.conf
#echo "masteruser redisusr" >> ~/$WERSJA-SRV/redis-${PORTY[0]}.conf
echo "protected-mode no" >> ~/$WERSJA-SRV/redis-${PORTY[0]}.conf
echo "port ${PORTY[0]}" >> ~/$WERSJA-SRV/redis-${PORTY[0]}.conf
echo "cluster-enabled yes" >> ~/$WERSJA-SRV/redis-${PORTY[0]}.conf

echo "bind 127.0.0.1 $IP" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
#echo "masterauth redishaslo" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
#echo "masteruser redisusr" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
#echo "replicaof $IP ${PORTY[0]}" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
echo "protected-mode no" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
echo "port ${PORTY[1]}" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
echo "cluster-enabled yes" >> ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf
pkill -f redis-server
sleep 3
cd ~/$WERSJA-SRV/
rm dump.rdb nodes.conf
redis-server ~/$WERSJA-SRV/redis-${PORTY[0]}.conf --logfile ${PORTY[0]}.log --daemonize yes
cd ~/$WERSJA-SLAVE/
rm dump.rdb nodes.conf
redis-server ~/$WERSJA-SLAVE/redis-${PORTY[1]}.conf --logfile ${PORTY[1]}.log --daemonize yes
exit 0
fi

if [ "$1" == "inst-rmt" ]
then 
cd ~
echo "##################################################"
echo "Podaj hasło do serwera $2"
ssh root@$2 'bash -s' < ~/rmt-inst-redis.sh
echo "##################################################"
echo "Podaj hasło do serwera $3"
ssh root@$3 'bash -s' < ~/rmt-inst-redis.sh
exit 0
fi

if [ "$1" == "create-cluster" ]
then 
cd ~
redis-cli --cluster create $2:${PORTY[0]} $2:${PORTY[1]} $3:${PORTY[0]} $3:${PORTY[1]} $4:${PORTY[0]} $4:${PORTY[1]}  --cluster-replicas 1
echo "#####################################"
echo "CLUSTER NODES"
redis-cli -c -p ${PORTY[0]} CLUSTER NODES
sleep 5
exit 0 
fi


if [ "$1" == "show" ]
then 
cd ~
#redis-cli --cluster create $2:${PORTY[0]} $2:${PORTY[1]} $3:${PORTY[0]} $3:${PORTY[1]} $4:${PORTY[0]} $4:${PORTY[1]}  --cluster-replicas 1
echo "#####################################"
echo "CLUSTER NODES"
redis-cli -c -p ${PORTY[0]} CLUSTER NODES
sleep 2
exit 0 
fi


if [ "$1" == "clean" ]
then
cd ~
cd ~/$WERSJA-SRV/
    echo "Cleaning *.log"
    rm -rf *.log
    echo "Cleaning appendonlydir-*"
    rm -rf appendonlydir-*
    echo "Cleaning dump-*.rdb"
    rm -rf dump-*.rdb
    echo "Cleaning nodes-*.conf"
    rm -rf nodes-*.conf
cd ~/$WERSJA-SLAVE/
echo "Cleaning *.log"
    rm -rf *.log
    echo "Cleaning appendonlydir-*"
    rm -rf appendonlydir-*
    echo "Cleaning dump-*.rdb"
    rm -rf dump-*.rdb
    echo "Cleaning nodes-*.conf"
    rm -rf nodes-*.conf


    exit 0
fi

    
#echo "Usage: $0 [start|create|stop|watch|tail|tailall|clean|clean-logs|call]"
echo "Kolejnosc wykonywania 1-> inst, 2-> inst-rmt 3->create-cluster 4->show"
echo "Sposób wywołania skryptu:"
echo "./inst-redis.sh inst				-- kasuje, pobiera zródła, kompiluje, i instaluje od nowa na LOKALNYM IP po jednym server i jednym slave"
echo "./inst-redis.sh inst-rmt IP1 IP2			 -- kasuje, pobiera zródła, kompiluje, i instaluje od nowa na ZDALNYM IP po jednym server i jednym slave"
echo "./inst-redis.sh create-cluster IP1 IP2 IP3	-- Tworzy klaster z podanych  IP , nr portu server ${PORTY[0]}, nr portu slave ${PORTY[1]}"
echo "./inst-redis.sh show				 -- pokazuje stan klastra "
#echo "stop        -- Stop Redis Cluster instances."
#echo "watch       -- Show CLUSTER NODES output (first 30 lines) of first node."
#echo "tail <id>   -- Run tail -f of instance at base port + ID."
#echo "tailall     -- Run tail -f for all the log files at once."
echo "./inst-redis.sh clean       -- usuwa *.log, *.rdb, nodes*.conf w katalogu server i slave"

#echo "clean-logs  -- Remove just instances logs."
#echo "call <cmd>  -- Call a command (up to 7 arguments) on all nodes."
