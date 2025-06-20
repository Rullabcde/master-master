#!/bin/bash

# Tunggu Container UP
sleep 30

# Setup Master 1
echo "Konfigurasi Master 1"
docker exec -i mysql-master1 mysql -uroot -psiswa -e "
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
  MASTER_HOST='mysql-master2',
  MASTER_USER='replication',
  MASTER_PASSWORD='siswa',
  MASTER_AUTO_POSITION=1;
START SLAVE;
"

# Setup Master 2
echo "Konfigurasi Master 2"
docker exec -i mysql-master2 mysql -uroot -psiswa -e "
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
  MASTER_HOST='mysql-master1',
  MASTER_USER='replication',
  MASTER_PASSWORD='siswa',
  MASTER_AUTO_POSITION=1;
START SLAVE;
"

# Setup Slave 1 Replication Master 1
echo "Konfigurasi Slave 1"
docker exec -i mysql-slave1 mysql -uroot -psiswa -e "
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='mysql-master1',
    MASTER_USER='replication',
    MASTER_PASSWORD='siswa',
    MASTER_AUTO_POSITION=1;
START SLAVE;
CREATE USER 'rullabcd'@'%' IDENTIFIED BY 'rullabcd';
GRANT SELECT ON *.* TO 'rullabcd'@'%';
FLUSH PRIVILEGES;
"

# Setup Slave 2 Replication Master 2
echo "Konfigurasi Slave 2"
docker exec -i mysql-slave2 mysql -uroot -psiswa -e "
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='mysql-master2',
    MASTER_USER='replication',
    MASTER_PASSWORD='siswa',
    MASTER_AUTO_POSITION=1;
START SLAVE;
CREATE USER 'rullabcd'@'%' IDENTIFIED BY 'rullabcd';
GRANT SELECT ON *.* TO 'rullabcd'@'%';
FLUSH PRIVILEGES;
"

# Cek status replikasi
echo "Status Replikasi Master 1"
docker exec -i mysql-master1 mysql -uroot -psiswa -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master)"

echo "Status Replikasi Master 2"
docker exec -i mysql-master2 mysql -uroot -psiswa -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master)"

echo "Status Replikasi Slave 1"
docker exec -i mysql-slave1 mysql -uroot -psiswa -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master)"

echo "Status Replikasi Slave 2"
docker exec -i mysql-slave2 mysql -uroot -psiswa -e "SHOW SLAVE STATUS\G" | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master)"
