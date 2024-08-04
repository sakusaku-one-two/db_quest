# db_quest

```
.
├── README.md
├── db
│   └── init.sql
└── docker-compose.yaml
```

<br>
dockerでmysqlを実行できます。（以下実行手順）
<br>
1.ディレクトリを移動して、dockerを立ち上げる

```
cd db_quest
docker-compose up -d
```
<br>
2. mysqlのコマンドラインに入る

```
docker exec -it quest_db mysql -u root -p
```
<br>
3. Enter:passwordの入力

```
root
```
<br>
4.databaseの中に入る

```
USE quset_db
```
<br>
<br>

## よく見られているエピソードトップ３を表示(viewで定義済み)

```
SELECT * FROM top3_epsode
```
<br>

```
CREATE VIEW top3_epsode AS 
SELECT 
    ptt.title_name AS title,
    COUNT(vl.id) AS view_count 
FROM 
    view_logs AS vl
JOIN 
    broadcast_programs AS bp ON bp.id = vl.broadcast_program_id
JOIN 
    program_to_title AS ptt ON bp.title_id = ptt.title_id
GROUP BY 
    ptt.title_name
ORDER BY 
    view_count DESC
LIMIT 3;
```


<br>

## よく見られているエピソードトップ３の詳細を表示(viewで定義済み)


```
SELECT * FROM top3_epsode2
```

<br>

```
CREATE VIEW top3_epsode2 AS
SELECT 
    ptt.title_name AS title,
    bp.season_no AS season_no,
    bp.episode_no AS episode_no,
    COUNT(vl.id) as view_count,
    ptt.title_description AS description
FROM 
    view_logs AS vl
JOIN
    broadcast_programs AS bp ON bp.id = vl.broadcast_program_id
JOIN
    program_to_title AS ptt ON bp.title_id = ptt.title_id
GROUP BY 
    ptt.title_name,
    ptt.title_description,
    bp.season_no,
    bp.episode_no
ORDER BY 
    view_count DESC
LIMIT 3;

```

<br>
注：）各テーブルと初期値・viewはinit.dbで定義済みです。
<br>
<br>

## 本日の番組リストを表示(viewで定義済み)
```
SELECT * FROM today_programs;
```

<br>

```
CREATE VIEW today_programs AS 
SELECT 
    c.name AS channel,
    ptt.title_name AS title, 
    bs.start_time AS start_time,
    bs.end_time AS end_time,
    bp.season_no AS season_no,
    bp.episode_no AS episode_no,
    ptt.description AS episode_description
FROM 
    broadcast_programs as bp
JOIN broadcast_slots as bs 
    ON bs.id = bp.slot_id
JOIN 
    program_to_title AS ptt ON bp.title_id = ptt.title_id 
    AND bp.episode_no = ptt.episode_no 
    AND bp.season_no = ptt.season_no
JOIN 
    channels AS c ON c.id = bp.channel_id
WHERE 
    bp.broadcast_date = CURDATE()
ORDER BY 
    bs.start_time ASC;

```

<br>
<br>

## 本日から7日間にあるドラマチャンネルの放送リスト(viewで定義済み)
```
SELECT * FROM dorama_programs;
```

<br>

```
CREATE VIEW dorama_programs AS
SELECT 
    bp.broadcast_date AS broadcast_date,
    c.name AS channel,
    ptt.title_name AS title, 
    bs.start_time AS start_time,
    bs.end_time AS end_time,
    bp.season_no AS season_no,
    bp.episode_no AS episode_no,
    ptt.description AS episode_description
FROM 
    broadcast_programs as bp
JOIN broadcast_slots as bs 
    ON bs.id = bp.slot_id
JOIN 
    program_to_title AS ptt ON bp.title_id = ptt.title_id 
    AND bp.episode_no = ptt.episode_no 
    AND bp.season_no = ptt.season_no
JOIN 
    channels AS c ON c.id = bp.channel_id
WHERE 
    bp.broadcast_date BETWEEN CURDATE() AND CURDATE() + INTERVAL 7 DAY
    AND c.id = 11
ORDER BY 
    bp.broadcast_date ASC,
    bs.start_time ASC; 
```

<br>
<br>
<br>

***

以下　テーブル定義
<br>

テーブル：users(ユーザーのマスタ)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||PRIMARY INDEX||YES|
|name|varchar(256)|NOT NULL||||
|email|varchar(256)|NOT NULL||||
|age|INT|NOT NULL|||||

<br>
<br>
<br>


```
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

```

<br>
<br>
<br>

テーブル：channels(チャンネルのマスタ)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||NOT NULL|PRIMARY KEY|YES|YES|
|name|varchar(50)|NOT NULL||||
|description|TEXT|||||

<br>
<br>
<br>


```

CREATE TABLE channels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);


```
<br>
<br>
<br>


テーブル：genres(ジャンルのマスタ)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||PRIMARY KEY||YES|
|name|varchar(50)|NOT NULL||||
|description|TEXT|||||


```
CREATE TABLE genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL
);
```
<br>
<br>
<br>


テーブル：channels_genres(チャンネルとジャンルを紐付ける many to many)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|channel_id|INT|NOT NULL|PRIMARY KEY FOREGIN KEY|||
|genre_id|INT|NOT NULL|PRIMARY KEY FOREIGN KEY|||

<br>
<br>
<br>


```
CREATE TABLE channels_genres (
    channel_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(channel_id, genre_id),
    FOREIGN KEY (channel_id) REFERENCES channels(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);
```
<br>
<br>
<br>

テーブル：broadcast_slots(配信時間のマスタ)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT|NOT NULL|PRIMARY KEY||TRUE|
|start_time|TIME|NOT NULL||||
|end_time|TIME|NOT NULL||||
|description|TEXT|NOT NULL||||

<br>
<br>
<br>


```
CREATE TABLE broadcast_slots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT NOT NULL
);
```
<br>
<br>
<br>


テーブル：titles(作品マスタ)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||PRIMARY KEY||TRUE|
|name|VARCHAR(50)|NOT NULL||||
|description|TEXT|NOT NULL||||

<br>
<br>
<br>

```
CREATE TABLE titles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);
```

<br>
<br>
<br>

テーブル：titles_genres(作品に付随したジャンルをmany to manyで表現)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|title_id|INT|NOT NULL|PRIMARY KEY FOREIGN KEY|||
|genre_id|INT|NOT NULL|PRIMARY KEY FOREIGN KEY|||


<br>
<br>
<br>

```
/*
中間テーブル　タイトル（作品・番組）とジャンルの多対多を複合主キーで表現
*/
CREATE TABLE titles_genres (
    title_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(title_id, genre_id),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);
```

<br>
<br>
<br>

テーブル：programs(配信番組のマスター)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|title_id|INT|NOT NULL|PRIMARY KEY FOREIGN KEY|||
|season_no|INT|NOT NULL|PRIMARY KEY FOREGIN KEY|1|
|epsode_no|INT|NOT NULL|PRIMARY KEY FOREGIN KEY|1|
|description|TEXT|||||


<br>
<br>
<br>

```
CREATE TABLE programs (
    title_id INT NOT NULL,
    season_no INT DEFAULT 1,
    episode_no INT DEFAULT 1,
    description TEXT,
    PRIMARY KEY(title_id, season_no, episode_no),
    FOREIGN KEY (title_id) REFERENCES titles(id)
);
```


<br>
<br>
<br>

テーブル：broadcast_programs(配信番組表)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT||PRIMARY KEY||TRUE|
|title_id|INT|NOT NULL|FOREGIN KEY|||
|season_no|INT|NOT NULL|FOREGIN KEY|||
|episode_no|INT|NOT NULL|FOREGIN KEY|||
|channel_id|INT|NOT NULL|FOREGIN KEY|||
|slot_id|INT|NOT NULL|FOREGIN KEY|||
|broadcast_date|DATE|NOT NULL||CURRENT_DATETIME||


<br>
<br>
<br>

```
CREATE TABLE broadcast_programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    channel_id INT NOT NULL,
    slot_id INT NOT NULL,
    broadcast_date DATE NOT NULL CURRENT_DATETIME,
    FOREIGN KEY program_id REFERENCES programs(id),
    FOREIGN KEY channel_id REFERENCES channels(id),
    FOREIGN KEY slot_id REFERENCES slots(id)
);
```


<br>
<br>
<br>

テーブル：view_logs(視聴履歴)

|カラム名|データ型|NULL|キー|初期値|AUTO INCREMENT|
| ---- | ---- | ---- | ---- | ---- | ---- |
|id|INT|NOT NULL|PRIMARY KEY||YES|
|broadcast_program_id|INT|NOT NULL|FOREGIN KEY|||
|user_id|INT|NOT NULL|FOREGIN KEY|||
|created_at|DATETIME|NOT NULL||CURRENT_TIMESTAMP||


<br>
<br>
<br>

```
CREATE TABLE view_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    broadcast_program_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (broadcast_program_id) REFERENCES broadcast_programs(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

```

<br>
<br>
<br>

以下　insert文のサンプル
***



```
-- usersテーブルにデータを挿入
INSERT INTO users (name, email, age) VALUES
('佐藤 太郎', 'taro.sato@example.com', 25),
('鈴木 次郎', 'jiro.suzuki@example.com', 30),
('高橋 花子', 'hanako.takahashi@example.com', 22),
('田中 一郎', 'ichiro.tanaka@example.com', 28),
('伊藤 美咲', 'misaki.ito@example.com', 35),
('渡辺 健', 'ken.watanabe@example.com', 27),
('山本 由美', 'yumi.yamamoto@example.com', 24),
('中村 勇', 'isamu.nakamura@example.com', 32),
('小林 直子', 'naoko.kobayashi@example.com', 29),
('加藤 勝', 'masaru.kato@example.com', 31);

-- channelsテーブルにデータを挿入
INSERT INTO channels (name, description) VALUES
('お笑いチャンネル', 'お笑い番組を放送するチャンネル'),
('トークショーチャンネル', 'トークショー番組を放送するチャンネル'),
('料理チャンネル', '料理番組を放送するチャンネル'),
('ミステリーチャンネル', 'ミステリー番組を放送するチャンネル'),
('音楽チャンネル', '音楽番組を放送するチャンネル'),
('アニメチャンネル', 'アニメ番組を放送するチャンネル'),
('ドキュメンタリーチャンネル', 'ドキュメンタリー番組を放送するチャンネル'),
('バラエティチャンネル', 'バラエティ番組を放送するチャンネル'),
('スポーツチャンネル', 'スポーツ番組を放送するチャンネル'),
('ニュースチャンネル', 'ニュース番組を放送するチャンネル');

-- genresテーブルにデータを挿入
INSERT INTO genres (name, description) VALUES
('お笑い', 'お笑い番組'),
('トークショー', 'トークショー番組'),
('料理', '料理番組'),
('ミステリー', 'ミステリー番組'),
('音楽', '音楽番組'),
('アニメ', 'アニメ番組'),
('ドキュメンタリー', 'ドキュメンタリー番組'),
('バラエティ', 'バラエティ番組'),
('スポーツ', 'スポーツ番組'),
('ニュース', 'ニュース番組');

-- channels_genresテーブルにデータを挿入
INSERT INTO channels_genres (channel_id, genre_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- broadcast_slotsテーブルにデータを挿入
INSERT INTO broadcast_slots (start_time, end_time, description) VALUES
('00:00:00', '01:00:00', '枠：01'),
('01:00:00', '02:00:00', '枠：02'),
('02:00:00', '03:00:00', '枠：03'),
('03:00:00', '04:00:00', '枠：04'),
('04:00:00', '05:00:00', '枠：05'),
('05:00:00', '06:00:00', '枠：06'),
('06:00:00', '07:00:00', '枠：07'),
('07:00:00', '08:00:00', '枠：08'),
('08:00:00', '09:00:00', '枠：09'),
('09:00:00', '10:00:00', '枠：10');

-- titlesテーブルにデータを挿入
INSERT INTO titles (name, description) VALUES
('お笑いバトル', '人気芸人が競うお笑いバトル番組'),
('深夜のトークショー', '深夜に放送されるトークショー'),
('料理の鉄人', 'プロの料理人が腕を競う料理番組'),
('ミステリードラマ', '謎解きがテーマのミステリードラマ'),
('音楽フェスティバル', '人気アーティストが出演する音楽フェス'),
('アニメマラソン', '人気アニメを一挙放送'),
('ドキュメンタリー特集', '社会問題を取り上げるドキュメンタリー'),
('バラエティーショー', '笑いと感動のバラエティーショー'),
('スポーツ中継', 'ライブでお届けするスポーツ中継'),
('ニュース速報', '最新のニュースを速報でお届け');

-- titles_genresテーブルにデータを挿入
INSERT INTO titles_genres (title_id, genre_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- programsテーブルにデータを挿入
INSERT INTO programs (title_id, season_no, episode_no, description) VALUES
(1, 1, 1, 'Episode 1 of Season 1 of お笑いバトル'),
(2, 1, 1, 'Episode 1 of Season 1 of 深夜のトークショー'),
(3, 1, 1, 'Episode 1 of Season 1 of 料理の鉄人'),
(4, 1, 1, 'Episode 1 of Season 1 of ミステリードラマ'),
(5, 1, 1, 'Episode 1 of Season 1 of 音楽フェスティバル'),
(6, 1, 1, 'Episode 1 of Season 1 of アニメマラソン'),
(7, 1, 1, 'Episode 1 of Season 1 of ドキュメンタリー特集'),
(8, 1, 1, 'Episode 1 of Season 1 of バラエティーショー'),
(9, 1, 1, 'Episode 1 of Season 1 of スポーツ中継'),
(10, 1, 1, 'Episode 1 of Season 1 of ニュース速報');

-- broadcast_programsテーブルにデータを挿入
INSERT INTO broadcast_programs (title_id, season_no, episode_no, channel_id, slot_id, broadcast_date) VALUES
(1, 1, 1, 1, 1, '2023-01-01'),
(2, 1, 1, 2, 2, '2023-01-02'),
(3, 1, 1, 3, 3, '2023-01-03'),
(4, 1, 1, 4, 4, '2023-01-04'),
(5, 1, 1, 5, 5, '2023-01-05'),
(6, 1, 1, 6, 6, '2023-01-06'),
(7, 1, 1, 7, 7, '2023-01-07'),
(8, 1, 1, 8, 8, '2023-01-08'),
(9, 1, 1, 9, 9, '2023-01-09'),
(10, 1, 1, 10, 10, '2023-01-10');

-- view_logsテーブルにデータを挿入
INSERT INTO view_logs (broadcast_program_id, user_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);
```