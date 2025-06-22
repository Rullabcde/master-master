#!/bin/bash

echo "Testing Master-Master Replication..."

# Insert data pada Master 1
echo "Insert data awal di Master 1..."
docker exec -i mysql-master1 mysql -uroot -psiswa -e "
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;
CREATE TABLE IF NOT EXISTS test_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO test_table (name) VALUES ('Data from Master 1');
"

# Insert data pada Master 2
echo "Inserting data on Master 2..."
docker exec -i mysql-master2 mysql -uroot -psiswa testdb -e "
INSERT INTO test_table (name) VALUES ('Data from Master 2');
"

sleep 5

# Cek data pada semua nodes
echo "Data pada Master 1:"
docker exec -i mysql-master1 mysql -uroot -psiswa -e "SELECT * FROM testdb.test_table;"

echo "Data pada Master 2:"
docker exec -i mysql-master2 mysql -uroot -psiswa -e "SELECT * FROM testdb.test_table;"

echo "Data pada Slave 1:"
docker exec -i mysql-slave1 mysql -urullabcd -prullabcd -e "SELECT * FROM testdb.test_table;"

echo "Data pada Slave 2:"
docker exec -i mysql-slave2 mysql -urullabcd -prullabcd -e "SELECT * FROM testdb.test_table;"

# Test read-only pada Slave 1
echo "Coba insert data di Slave 1..."
docker exec -i mysql-slave1 mysql -urullabcd -prullabcd testdb -e "INSERT INTO test_table (name) VALUES ('This should fail');" 2>&1 || echo "Read-only constraint working correctly!"

# Test read-only pada Slave 1
echo "Coba insert data di Slave 2..."
docker exec -i mysql-slave2 mysql -urullabcd -prullabcd testdb -e "INSERT INTO test_table (name) VALUES ('This should fail');" 2>&1 || echo "Read-only constraint working correctly!"
