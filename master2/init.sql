CREATE USER IF NOT EXISTS 'replication'@'%' IDENTIFIED WITH mysql_native_password BY 'siswa';
GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
FLUSH PRIVILEGES;
