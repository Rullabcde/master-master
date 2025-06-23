# Konfigurasi MySQL Replication Master-Master + Slave

Ini setup MySQL replication yang dengan **topologi master-master** dan tambahan 2 **slave**. Semua pakai **GTID-based replication** biar lebih fleksibel dan minim masalah saat failover.

## Konfigurasi Tiap Node

### master-1

```ini
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog-format = ROW
gtid-mode = ON
enforce-gtid-consistency = ON
log-slave-updates = ON
read-only = OFF

auto_increment_increment = 2
auto_increment_offset = 1

binlog-do-db = testdb
replicate-wild-do-table = testdb.%
expire_logs_days = 7
max_binlog_size = 100M

slave-skip-errors = 1062
```

- `server-id` unik biar ga tabrakan
- `auto_increment_offset = 1` dan `auto_increment_increment = 2` buat ngatur ID auto increment biar beda sama master-2
- Cuma replikasi database `testdb`
- Skip error duplikat (`1062`) biar ga stop replikasi

---

### master-2

```ini
[mysqld]
server-id = 2
log-bin = mysql-bin
binlog-format = ROW
gtid-mode = ON
enforce-gtid-consistency = ON
log-slave-updates = ON
read-only = OFF

auto_increment_increment = 2
auto_increment_offset = 2

binlog-do-db = testdb
replicate-wild-do-table = testdb.%
expire_logs_days = 7
max_binlog_size = 100M

slave-skip-errors = 1062
```

- `auto_increment_offset = 2` biar ID auto increment-nya selang-seling sama master-1

---

### slave-1 (Replica dari master-1)

```ini
[mysqld]
server-id = 3
log-bin = mysql-bin
binlog-format = ROW
gtid-mode = ON
enforce-gtid-consistency = ON
log-slave-updates = ON
read-only = ON

relay-log = slave1-relay-bin
replicate-wild-do-table = testdb.%
slave-skip-errors = 1062
```

- `read-only = ON` biar ga bisa ditulis
- Ambil data dari `master-1`

---

### slave-2 (Replica dari master-2)

```ini
[mysqld]
server-id = 4
log-bin = mysql-bin
binlog-format = ROW
gtid-mode = ON
enforce-gtid-consistency = ON
log-slave-updates = ON
read-only = ON

relay-log = slave2-relay-bin
replicate-wild-do-table = testdb.%
slave-skip-errors = 1062
```

- Ambil data dari `master-2`
- Setting mirip kayak slave-1, cuma beda `relay-log` dan `server-id`

---

## Catatan

- Format binlog pakai `ROW` biar akurat dalam replikasi
- `gtid-mode = ON` & `enforce-gtid-consistency = ON` WAJIB buat GTID replication

---
