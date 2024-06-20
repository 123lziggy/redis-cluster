#!/bin/sh
cd ~
WERSJA=redis-7.2.5
IP=$(hostname -I)
PORTY=('6379' '6380')
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
