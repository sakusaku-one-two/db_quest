# db_quest




テーブル：users

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||PRIMARY INDEX||YES|
|name|varchar(256)|NOT NULL||||
|email|varchar(256)|NOT NULL||||
|age|INT|NOT NULL|||||

```
CREATE TABLE user (
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCAHR(256) NOT NULL,
 email VARCHAR(256) NOT NULL,
 age INT NOT NULL,
);

CREATE INDEX user_index ON users(id);
```

<br>
***
<br>



テーブル：views_logs

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||PRIMARY INDEX||YES|
|user_id|INT|FOREIGN KEY||||
|broadcast_id|INT|FOREIGN KEY|||||
|created_at|DATETIME|NOT NULL|DEFAULT CURRENT_TIMESTAMP|||


```
CREATE TABLE view_logs (
 id INT AUTO_INCREMENT PRIMARY KEY,
 broadcast_id INT NOT NULL,
 user_id INT NOT NULL,
 created_at DATETIME DEFAULT　 CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id),
 REFERENCES users(id)
);
```


