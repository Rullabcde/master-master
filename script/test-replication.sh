#!/bin/bash

GREEN="\033[0;32m"
NC="\033[0m"

# Insert data pada Master 1
echo -e "${GREEN}Insert data di Master 1${NC}"
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
echo -e "${GREEN}Insert data di Master 2${NC}"
docker exec -i mysql-master2 mysql -uroot -psiswa -e "
USE testdb;
INSERT INTO test_table (name) VALUES ('Data from Master 2');
"

sleep 5

# Cek data pada semua nodes
echo -e "${GREEN}Data pada Master 1:${NC}"
docker exec -i mysql-master1 mysql -uroot -psiswa -e "SELECT * FROM testdb.test_table;"

echo -e "${GREEN}Data pada Master 2:${NC}"
docker exec -i mysql-master2 mysql -uroot -psiswa -e "SELECT * FROM testdb.test_table;"

echo -e "${GREEN}Data pada Slave 1:${NC}"
docker exec -i mysql-slave1 mysql -urullabcd -prullabcd -e "SELECT * FROM testdb.test_table;"

echo -e "${GREEN}Data pada Slave 2:${NC}"
docker exec -i mysql-slave2 mysql -urullabcd -prullabcd -e "SELECT * FROM testdb.test_table;"

# Test read-only pada Slave 1
echo -e "${GREEN}Coba insert data di Slave 1${NC}"
docker exec -i mysql-slave1 mysql -urullabcd -prullabcd testdb -e "INSERT INTO test_table (name) VALUES ('This should fail');" 2>&1 || echo -e "${GREEN}Read-only constraint working correctly!${NC}"

# Test read-only pada Slave 2
echo -e "${GREEN}Coba insert data di Slave 2...${NC}"
docker exec -i mysql-slave2 mysql -urullabcd -prullabcd testdb -e "INSERT INTO test_table (name) VALUES ('This should fail');" 2>&1 || echo -e "${GREEN}Read-only constraint working correctly!${NC}"
