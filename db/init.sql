CREATE DATABASE IF NOT EXISTS quest_db;

USE quest_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

CREATE INDEX idx_user_id ON users(id);

CREATE TABLE channels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE channels_genres (
    channel_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(channel_id, genre_id),
    FOREIGN KEY (channel_id) REFERENCES channels(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE broadcast_slots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE titles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

/*
中間テーブル　タイトル（作品・番組）とジャンルの多対多を表現
*/
CREATE TABLE titles_genres (
    title_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(title_id, genre_id),
    FOREIGN KEY (title_id) REFERENCES titles(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE programs (
    title_id INT NOT NULL,
    season_no INT DEFAULT 1,
    episode_no INT DEFAULT 1,
    description TEXT,
    PRIMARY KEY(title_id, season_no, episode_no),
    FOREIGN KEY (title_id) REFERENCES titles(id)
);

CREATE INDEX idx_title_of_programs ON programs(title_id);

CREATE VIEW program_to_title AS
SELECT 
    programs.title_id,
    programs.season_no,
    programs.episode_no,
    programs.description,
    titles.name AS title_name,
    titles.description AS title_description
FROM programs
JOIN titles ON programs.title_id = titles.id;




CREATE TABLE broadcast_programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title_id INT NOT NULL,
    season_no INT NOT NULL,
    episode_no INT NOT NULL,
    channel_id INT NOT NULL,
    slot_id INT NOT NULL,
    broadcast_date DATE NOT NULL,
    FOREIGN KEY(title_id, season_no, episode_no) REFERENCES programs(title_id, season_no, episode_no),
    FOREIGN KEY(channel_id) REFERENCES channels(id)
);



CREATE TABLE view_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    broadcast_program_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (broadcast_program_id) REFERENCES broadcast_programs(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);



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
('加藤 勝', 'masaru.kato@example.com', 31),
('吉田 玲子', 'reiko.yoshida@example.com', 26),
('山田 太一', 'taichi.yamada@example.com', 33),
('佐々木 亮', 'ryo.sasaki@example.com', 23),
('松本 美香', 'mika.matsumoto@example.com', 34),
('井上 健太', 'kenta.inoue@example.com', 21),
('木村 さくら', 'sakura.kimura@example.com', 28),
('林 直樹', 'naoki.hayashi@example.com', 27),
('清水 由紀', 'yuki.shimizu@example.com', 25),
('森田 翔', 'sho.morita@example.com', 30),
('池田 真由美', 'mayumi.ikeda@example.com', 22),
('橋本 健', 'ken.hashimoto@example.com', 24),
('山口 直子', 'naoko.yamaguchi@example.com', 29),
('斎藤 勇', 'isamu.saito@example.com', 32),
('坂本 美香', 'mika.sakamoto@example.com', 34),
('藤田 健太', 'kenta.fujita@example.com', 21),
('岡田 さくら', 'sakura.okada@example.com', 28),
('村上 直樹', 'naoki.murakami@example.com', 27),
('青木 由紀', 'yuki.aoki@example.com', 25),
('石井 翔', 'sho.ishii@example.com', 30),
('三浦 真由美', 'mayumi.miura@example.com', 22),
('原田 健', 'ken.harada@example.com', 24),
('森 直子', 'naoko.mori@example.com', 29),
('横山 勇', 'isamu.yokoyama@example.com', 32),
('宮崎 美香', 'mika.miyazaki@example.com', 34),
('田村 健太', 'kenta.tamura@example.com', 21),
('竹内 さくら', 'sakura.takeuchi@example.com', 28),
('中川 直樹', 'naoki.nakagawa@example.com', 27),
('小野 由紀', 'yuki.ono@example.com', 25),
('松田 翔', 'sho.matsuda@example.com', 30),
('杉山 真由美', 'mayumi.sugiyama@example.com', 22),
('福田 健', 'ken.fukuda@example.com', 24),
('大野 直子', 'naoko.ohno@example.com', 29),
('西村 勇', 'isamu.nishimura@example.com', 32),
('平野 美香', 'mika.hirano@example.com', 34),
('金子 健太', 'kenta.kaneko@example.com', 21),
('中島 さくら', 'sakura.nakajima@example.com', 28),
('石田 直樹', 'naoki.ishida@example.com', 27),
('上田 由紀', 'yuki.ueda@example.com', 25),
('吉川 翔', 'sho.yoshikawa@example.com', 30),
('堀 真由美', 'mayumi.hori@example.com', 22),
('松井 健', 'ken.matsui@example.com', 24),
('菊地 直子', 'naoko.kikuchi@example.com', 29),
('佐野 勇', 'isamu.sano@example.com', 32),
('木下 美香', 'mika.kinoshita@example.com', 34),
('野村 健太', 'kenta.nomura@example.com', 21),
('松下 さくら', 'sakura.matsushita@example.com', 28),
('大塚 直樹', 'naoki.otsuka@example.com', 27),
('中田 由紀', 'yuki.nakata@example.com', 25),
('高木 翔', 'sho.takagi@example.com', 30),
('秋山 真由美', 'mayumi.akiyama@example.com', 22),
('田辺 健', 'ken.tanabe@example.com', 24),
('川口 直子', 'naoko.kawaguchi@example.com', 29),
('今井 勇', 'isamu.imai@example.com', 32),
('大西 美香', 'mika.onishi@example.com', 34),
('藤井 健太', 'kenta.fujii@example.com', 21),
('村田 さくら', 'sakura.murata@example.com', 28),
('西田 直樹', 'naoki.nishida@example.com', 27),
('菅原 由紀', 'yuki.sugawara@example.com', 25),
('河野 翔', 'sho.kono@example.com', 30),
('武田 真由美', 'mayumi.takeda@example.com', 22),
('青山 健', 'ken.aoyama@example.com', 24),
('石川 直子', 'naoko.ishikawa@example.com', 29),
('中山 勇', 'isamu.nakayama@example.com', 32),
('栗原 美香', 'mika.kurihara@example.com', 34),
('松岡 健太', 'kenta.matsuoka@example.com', 21),
('小松 さくら', 'sakura.komatsu@example.com', 28),
('吉村 直樹', 'naoki.yoshimura@example.com', 27),
('山下 由紀', 'yuki.yamashita@example.com', 25),
('岩田 翔', 'sho.iwata@example.com', 30),
('長谷川 真由美', 'mayumi.hasegawa@example.com', 22),
('菊池 健', 'ken.kikuchi@example.com', 24),
('大橋 直子', 'naoko.ohashi@example.com', 29),
('岡本 勇', 'isamu.okamoto@example.com', 32),
('松田 美香', 'mika.matsuda@example.com', 34),
('中井 健太', 'kenta.nakai@example.com', 21),
('小池 さくら', 'sakura.koike@example.com', 28),
('山内 直樹', 'naoki.yamauchi@example.com', 27),
('川崎 由紀', 'yuki.kawasaki@example.com', 25),
('田口 翔', 'sho.taguchi@example.com', 30),
('三宅 真由美', 'mayumi.miyake@example.com', 22),
('藤本 健', 'ken.fujimoto@example.com', 24),
('永井 直子', 'naoko.nagai@example.com', 29),
('中西 勇', 'isamu.nakanishi@example.com', 32),
('石原 美香', 'mika.ishihara@example.com', 34),
('松浦 健太', 'kenta.matsuura@example.com', 21),
('小山 さくら', 'sakura.koyama@example.com', 28),
('吉本 直樹', 'naoki.yoshimoto@example.com', 27),
('山崎 由紀', 'yuki.yamazaki@example.com', 25),
('岩崎 翔', 'sho.iwasaki@example.com', 30);

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
('ニュースチャンネル', 'ニュース番組を放送するチャンネル'),
('ドラマチャンネル', 'ドラマ番組を放送するチャンネル'),
('子供向けチャンネル', '子供向け番組を放送するチャンネル'),
('旅チャンネル', '旅番組を放送するチャンネル'),
('クイズチャンネル', 'クイズ番組を放送するチャンネル'),
('恋愛チャンネル', '恋愛番組を放送するチャンネル'),
('歴史チャンネル', '歴史番組を放送するチャンネル'),
('科学チャンネル', '科学番組を放送するチャンネル'),
('ペットチャンネル', 'ペット番組を放送するチャンネル'),
('DIYチャンネル', 'DIY番組を放送するチャンネル'),
('健康チャンネル', '健康番組を放送するチャンネル'),
('ファッションチャンネル', 'ファッション番組を放送するチャンネル'),
('ゲームチャンネル', 'ゲーム番組を放送するチャンネル'),
('アートチャンネル', 'アート番組を放送するチャンネル'),
('ビジネスチャンネル', 'ビジネス番組を放送するチャンネル'),
('教育チャンネル', '教育番組を放送するチャンネル');

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
('ニュース', 'ニュース番組'),
('映画', '映画番組'),
('子供向け', '子供向け番組'),
('旅', '旅番組'),
('クイズ', 'クイズ番組'),
('恋愛', '恋愛番組'),
('歴史', '歴史番組'),
('科学', '科学番組'),
('ペット', 'ペット番組'),
('DIY', 'DIY番組'),
('健康', '健康番組'),
('ファッション', 'ファッション番組'),
('ゲーム', 'ゲーム番組'),
('アート', 'アート番組'),
('ビジネス', 'ビジネス番組'),
('教育', '教育番組');

-- channels_genresテーブルにデータを挿入
INSERT INTO channels_genres (channel_id, genre_id) VALUES
(1, 1), (1, 8), (1, 23), -- お笑いチャンネル
(2, 2), (2, 8), (2, 23), -- トークショーチャンネル
(3, 3), (3, 20), -- 料理チャンネル
(4, 4), (4, 16), -- ミステリーチャンネル
(5, 5),  -- 音楽チャンネル
(6, 6),  -- アニメチャンネル
(7, 7),  -- ドキュメンタリーチャンネル
(8, 8),  -- バラエティチャンネル
(9, 9),  -- スポーツチャンネル
(10, 10),  -- ニュースチャンネル
(11, 11),  -- 映画チャンネル
(12, 12),  -- 子供向けチャンネル
(13, 13),  -- 旅チャンネル
(14, 14),  -- クイズチャンネル
(15, 15),  -- 恋愛チャンネル
(16, 16),  -- 歴史チャンネル
(17, 17),  -- 科学チャンネル
(18, 18),  -- ペットチャンネル
(19, 19),  -- DIYチャンネル
(20, 20),  -- 健康チャンネル
(21, 21),  -- ファッションチャンネル
(22, 22),  -- ゲームチャンネル
(23, 23),  -- アートチャンネル
(24, 24),  -- ビジネスチャンネル
(25, 25); -- 教育チャンネル
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
('09:00:00', '10:00:00', '枠：10'),
('10:00:00', '11:00:00', '枠：11'),
('11:00:00', '12:00:00', '枠：12'),
('12:00:00', '13:00:00', '枠：13'),
('13:00:00', '14:00:00', '枠：14'),
('14:00:00', '15:00:00', '枠：15'),
('15:00:00', '16:00:00', '枠：16'),
('16:00:00', '17:00:00', '枠：17'),
('17:00:00', '18:00:00', '枠：18'),
('18:00:00', '19:00:00', '枠：19'),
('19:00:00', '20:00:00', '枠：20'),
('20:00:00', '21:00:00', '枠：21'),
('21:00:00', '22:00:00', '枠：22'),
('22:00:00', '23:00:00', '枠：23'),
('23:00:00', '00:00:00', '枠：24');

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
('ニュース速報', '最新のニュースを速報でお届け'),
('映画特集', '話題の映画を特集'),
('子供向けアニメ', '子供たちに人気のアニメ番組'),
('旅番組', '世界各地を巡る旅番組'),
('クイズショー', '知識を競うクイズショー'),
('恋愛リアリティショー', '恋愛模様を描くリアリティショー'),
('歴史ドキュメンタリー', '歴史的事件を取り上げるドキュメンタリー'),
('科学番組', '科学の不思議を解き明かす番組'),
('ペット特集', '可愛いペットたちを紹介'),
('DIY番組', '自分で作るDIYのアイデアを紹介'),
('健康番組', '健康に関する情報をお届け'),
('ファッションショー', '最新のファッションを紹介'),
('ゲーム実況', '人気ゲームの実況プレイ'),
('お笑いライブ', '人気芸人のライブパフォーマンス'),
('アート特集', 'アートの世界を紹介'),
('ビジネスニュース', '最新のビジネスニュースをお届け'),
('教育番組', '子供たちのための教育番組'),
('料理教室', 'プロのシェフが教える料理教室'),
('スポーツニュース', '最新のスポーツニュースをお届け'),
('音楽ランキング', '最新の音楽ランキングを紹介'),
('ドラマシリーズ', '話題のドラマシリーズ'),
('アニメ特集', '人気アニメを特集'),
('映画レビュー', '話題の映画をレビュー'),
('トークバラエティ', 'ゲストを迎えてのトークバラエティ'),
('お笑いコンテスト', '芸人たちが競うお笑いコンテスト'),
('ニュース解説', 'ニュースを詳しく解説'),
('旅の情報', '旅行に役立つ情報をお届け'),
('クッキングバトル', '料理人たちが競うクッキングバトル'),
('スポーツ特集', '注目のスポーツを特集'),
('音楽ライブ', '人気アーティストのライブパフォーマンス'),
('ドキュメンタリー映画', '話題のドキュメンタリー映画'),
('子供向け番組', '子供たちに人気の番組'),
('歴史ドラマ', '歴史的事件を描くドラマ'),
('科学実験', '科学の実験を紹介'),
('ペットの時間', '可愛いペットたちを紹介'),
('DIYプロジェクト', '自分で作るDIYプロジェクト'),
('健康情報', '健康に関する情報をお届け'),
('ファッションチェック', '最新のファッションをチェック'),
('ゲーム大会', '人気ゲームの大会'),
('お笑いステージ', '人気芸人のステージパフォーマンス'),
('アートの世界', 'アートの世界を紹介'),
('ビジネス特集', '注目のビジネスを特集'),
('教育の時間', '子供たちのための教育番組'),
('料理のコツ', 'プロのシェフが教える料理のコツ'),
('スポーツハイライト', '注目のスポーツハイライト'),
('音楽の時間', '音楽に関する情報をお届け'),
('ドラマ特集', '話題のドラマを特集'),
('アニメの時間', '人気アニメを紹介'),
('映画の時間', '話題の映画を紹介'),
('トークショー', 'ゲストを迎えてのトークショー'),
('お笑いの時間', '笑いをお届けするお笑い番組'),
('ニュースの時間', '最新のニュースをお届け'),
('旅の特集', '旅行に役立つ情報を特集'),
('クッキングショー', '料理人たちが腕を競うクッキングショー'),
('スポーツの時間', 'スポーツに関する情報をお届け'),
('音楽の祭典', '音楽の祭典をお届け'),
('ドキュメンタリーの時間', '社会問題を取り上げるドキュメンタリー'),
('子供の時間', '子供たちに人気の番組'),
('歴史の時間', '歴史的事件を紹介'),
('科学の時間', '科学の不思議を解き明かす番組'),
('ペットの特集', '可愛いペットたちを特集'),
('DIYの時間', '自分で作るDIYのアイデアを紹介'),
('健康の時間', '健康に関する情報をお届け'),
('ファッションの時間', '最新のファッションを紹介'),
('ゲームの時間', '人気ゲームの情報をお届け'),
('お笑いの祭典', '人気芸人の祭典'),
('アートの時間', 'アートの世界を紹介'),
('ビジネスの時間', '最新のビジネス情報をお届け'),
('教育の特集', '子供たちのための教育特集'),
('料理の時間', 'プロのシェフが教える料理の時間'),
('スポーツの祭典', '注目のスポーツの祭典'),
('音楽の特集', '音楽に関する特集'),
('ドラマの時間', '話題のドラマを紹介'),
('アニメの祭典', '人気アニメの祭典'),
('映画の祭典', '話題の映画の祭典'),
('トークの時間', 'ゲストを迎えてのトークの時間'),
('お笑いの特集', '笑いをお届けするお笑い特集'),
('ニュースの特集', '最新のニュースを特集'),
('旅の祭典', '旅行に役立つ情報をお届け'),
('クッキングの時間', '料理人たちが腕を競うクッキングの時間'),
('スポーツの特集', '注目のスポーツを特集'),
('音楽の時間', '音楽に関する情報をお届け'),
('ドキュメンタリーの特集', '社会問題を取り上げるドキュメンタリー特集'),
('子供の特集', '子供たちに人気の番組を特集'),
('歴史の特集', '歴史的事件を紹介'),
('科学の特集', '科学の不思議を解き明かす特集'),
('ペットの時間', '可愛いペットたちを紹介'),
('DIYの特集', '自分で作るDIYのアイデアを特集'),
('健康の特集', '健康に関する情報を特集'),
('ファッションの特集', '最新のファッションを特集'),
('ゲームの特集', '人気ゲームの情報を特集');

-- titles_genresテーブルにデータを挿入
INSERT INTO titles_genres (title_id, genre_id) VALUES
(1, 1), -- お笑いバトル -> お笑い
(2, 2), -- 深夜のトークショー -> トークショー
(3, 3), -- 料理の鉄人 -> 料理
(4, 4), -- ミステリードラマ -> ミステリー
(5, 5), -- 音楽フェスティバル -> 音楽
(6, 6), -- アニメマラソン -> アニメ
(7, 7), -- ドキュメンタリー特集 -> ドキュメンタリー
(8, 8), -- バラエティーショー -> バラエティ
(9, 9), -- スポーツ中継 -> スポーツ
(10, 10), -- ニュース速報 -> ニュース
(11, 11), -- 映画特集 -> 映画
(12, 12), -- 子供向けアニメ -> 子供向け
(13, 13), -- 旅番組 -> 旅
(14, 14), -- クイズショー -> クイズ
(15, 15), -- 恋愛リアリティショー -> 恋愛
(16, 16), -- 歴史ドキュメンタリー -> 歴史
(17, 17), -- 科学番組 -> 科学
(18, 18), -- ペット特集 -> ペット
(19, 19), -- DIY番組 -> DIY
(20, 20), -- 健康番組 -> 健康
(21, 21), -- ファッションショー -> ファッション
(22, 22), -- ゲーム実況 -> ゲーム
(23, 1), -- お笑いライブ -> お笑い
(24, 23), -- アート特集 -> アート
(25, 24), -- ビジネスニュース -> ビジネス
(26, 25), -- 教育番組 -> 教育
(27, 3), -- 料理教室 -> 料理
(28, 9), -- スポーツニュース -> スポーツ
(29, 5), -- 音楽ランキング -> 音楽
(30, 6), -- ドラマシリーズ -> アニメ
(31, 11), -- アニメ特集 -> 映画
(32, 2), -- 映画レビュー -> トークショー
(33, 1), -- トークバラエティ -> お笑い
(34, 10), -- お笑いコンテスト -> ニュース
(35, 13), -- ニュース解説 -> 旅
(36, 3), -- 旅の情報 -> 料理
(37, 9), -- クッキングバトル -> スポーツ
(38, 5), -- スポーツ特集 -> 音楽
(39, 7), -- 音楽ライブ -> ドキュメンタリー
(40, 12), -- ドキュメンタリー映画 -> 子供向け
(41, 4), -- 子供向け番組 -> ミステリー
(42, 17), -- 歴史ドラマ -> 科学
(43, 18), -- 科学実験 -> ペット
(44, 19), -- ペットの時間 -> DIY
(45, 20), -- DIYプロジェクト -> 健康
(46, 21), -- 健康情報 -> ファッション
(47, 22), -- ファッションチェック -> ゲーム
(48, 1), -- ゲーム大会 -> お笑い
(49, 23), -- お笑いステージ -> アート
(50, 24), -- アートの世界 -> ビジネス
(51, 25), -- ビジネス特集 -> 教育
(52, 9), -- 教育の時間 -> スポーツ
(53, 3), -- 料理のコツ -> 料理
(54, 9), -- スポーツハイライト -> スポーツ
(55, 5), -- 音楽の時間 -> 音楽
(56, 11), -- ドラマ特集 -> 映画
(57, 6), -- アニメの時間 -> アニメ
(58, 1), -- 映画の時間 -> お笑い
(59, 2), -- トークショー -> トークショー
(60, 13), -- お笑いの時間 -> 旅
(61, 10), -- ニュースの時間 -> ニュース
(62, 13), -- 旅の特集 -> 旅
(63, 3), -- クッキングショー -> 料理
(64, 9), -- スポーツの時間 -> スポーツ
(65, 5), -- 音楽の祭典 -> 音楽
(66, 7), -- ドキュメンタリーの時間 -> ドキュメンタリー
(67, 12), -- 子供の時間 -> 子供向け
(68, 16), -- 歴史の時間 -> 歴史
(69, 17), -- 科学の時間 -> 科学
(70, 18), -- ペットの特集 -> ペット
(71, 19), -- DIYの時間 -> DIY
(72, 20), -- 健康の時間 -> 健康
(73, 21), -- ファッションの時間 -> ファッション
(74, 22), -- ゲームの時間 -> ゲーム
(75, 1), -- お笑いの祭典 -> お笑い
(76, 23), -- アートの時間 -> アート
(77, 24), -- ビジネスの時間 -> ビジネス
(78, 25), -- 教育の特集 -> 教育
(79, 3), -- 料理の時間 -> 料理
(80, 9), -- スポーツの祭典 -> スポーツ
(81, 5), -- 音楽の特集 -> 音楽
(82, 11), -- ドラマの時間 -> 映画
(83, 6), -- アニメの祭典 -> アニメ
(84, 10), -- 映画の祭典 -> ニュース
(85, 2), -- トークの時間 -> トークショー
(86, 1), -- お笑いの特集 -> お笑い
(87, 10), -- ニュースの特集 -> ニュース
(88, 13), -- 旅の祭典 -> 旅
(89, 3), -- クッキングの時間 -> 料理
(90, 9), -- スポーツの特集 -> スポーツ
(91, 5), -- 音楽の時間 -> 音楽
(92, 7), -- ドキュメンタリーの特集 -> ドキュメンタリー
(93, 12), -- 子供の特集 -> 子供向け
(94, 16), -- 歴史の特集 -> 歴史
(95, 17), -- 科学の特集 -> 科学
(96, 18), -- ペットの時間 -> ペット
(97, 19), -- DIYの特集 -> DIY
(98, 20), -- 健康の特集 -> 健康
(99, 21), -- ファッションの特集 -> ファッション
(100, 22); -- ゲームの特集 -> ゲーム


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
(10, 1, 1, 'Episode 1 of Season 1 of ニュース速報'),
(11, 1, 1, 'Episode 1 of Season 1 of 映画特集'),
(12, 1, 1, 'Episode 1 of Season 1 of 子供向けアニメ'),
(13, 1, 1, 'Episode 1 of Season 1 of 旅番組'),
(14, 1, 1, 'Episode 1 of Season 1 of クイズショー'),
(15, 1, 1, 'Episode 1 of Season 1 of 恋愛リアリティショー'),
(16, 1, 1, 'Episode 1 of Season 1 of 歴史ドキュメンタリー'),
(17, 1, 1, 'Episode 1 of Season 1 of 科学番組'),
(18, 1, 1, 'Episode 1 of Season 1 of ペット特集'),
(19, 1, 1, 'Episode 1 of Season 1 of DIY番組'),
(20, 1, 1, 'Episode 1 of Season 1 of 健康番組'),
(21, 1, 1, 'Episode 1 of Season 1 of ファッションショー'),
(22, 1, 1, 'Episode 1 of Season 1 of ゲーム実況'),
(23, 1, 1, 'Episode 1 of Season 1 of お笑いライブ'),
(24, 1, 1, 'Episode 1 of Season 1 of アート特集'),
(25, 1, 1, 'Episode 1 of Season 1 of ビジネスニュース'),
(26, 1, 1, 'Episode 1 of Season 1 of 教育番組'),
(27, 1, 1, 'Episode 1 of Season 1 of 料理教室'),
(28, 1, 1, 'Episode 1 of Season 1 of スポーツニュース'),
(29, 1, 1, 'Episode 1 of Season 1 of 音楽ランキング'),
(30, 1, 1, 'Episode 1 of Season 1 of ドラマシリーズ'),
(31, 1, 1, 'Episode 1 of Season 1 of アニメ特集'),
(32, 1, 1, 'Episode 1 of Season 1 of 映画レビュー'),
(33, 1, 1, 'Episode 1 of Season 1 of トークバラエティ'),
(34, 1, 1, 'Episode 1 of Season 1 of お笑いコンテスト'),
(35, 1, 1, 'Episode 1 of Season 1 of ニュース解説'),
(36, 1, 1, 'Episode 1 of Season 1 of 旅の情報'),
(37, 1, 1, 'Episode 1 of Season 1 of クッキングバトル'),
(38, 1, 1, 'Episode 1 of Season 1 of スポーツ特集'),
(39, 1, 1, 'Episode 1 of Season 1 of 音楽ライブ'),
(40, 1, 1, 'Episode 1 of Season 1 of ドキュメンタリー映画'),
(41, 1, 1, 'Episode 1 of Season 1 of 子供向け番組'),
(42, 1, 1, 'Episode 1 of Season 1 of 歴史ドラマ'),
(43, 1, 1, 'Episode 1 of Season 1 of 科学実験'),
(44, 1, 1, 'Episode 1 of Season 1 of ペットの時間'),
(45, 1, 1, 'Episode 1 of Season 1 of DIYプロジェクト'),
(46, 1, 1, 'Episode 1 of Season 1 of 健康情報'),
(47, 1, 1, 'Episode 1 of Season 1 of ファッションチェック'),
(48, 1, 1, 'Episode 1 of Season 1 of ゲーム大会'),
(49, 1, 1, 'Episode 1 of Season 1 of お笑いステージ'),
(50, 1, 1, 'Episode 1 of Season 1 of アートの世界'),
(51, 1, 1, 'Episode 1 of Season 1 of ビジネス特集'),
(52, 1, 1, 'Episode 1 of Season 1 of 教育の時間'),
(53, 1, 1, 'Episode 1 of Season 1 of 料理のコツ'),
(54, 1, 1, 'Episode 1 of Season 1 of スポーツハイライト'),
(55, 1, 1, 'Episode 1 of Season 1 of 音楽の時間'),
(56, 1, 1, 'Episode 1 of Season 1 of ドラマ特集'),
(57, 1, 1, 'Episode 1 of Season 1 of アニメの時間'),
(58, 1, 1, 'Episode 1 of Season 1 of 映画の時間'),
(59, 1, 1, 'Episode 1 of Season 1 of トークショー'),
(60, 1, 1, 'Episode 1 of Season 1 of お笑いの時間'),
(61, 1, 1, 'Episode 1 of Season 1 of ニュースの時間'),
(62, 1, 1, 'Episode 1 of Season 1 of 旅の特集'),
(63, 1, 1, 'Episode 1 of Season 1 of クッキングショー'),
(64, 1, 1, 'Episode 1 of Season 1 of スポーツの時間'),
(65, 1, 1, 'Episode 1 of Season 1 of 音楽の祭典'),
(66, 1, 1, 'Episode 1 of Season 1 of ドキュメンタリーの時間'),
(67, 1, 1, 'Episode 1 of Season 1 of 子供の時間'),
(68, 1, 1, 'Episode 1 of Season 1 of 歴史の時間'),
(69, 1, 1, 'Episode 1 of Season 1 of 科学の時間'),
(70, 1, 1, 'Episode 1 of Season 1 of ペットの特集'),
(71, 1, 1, 'Episode 1 of Season 1 of DIYの時間'),
(72, 1, 1, 'Episode 1 of Season 1 of 健康の時間'),
(73, 1, 1, 'Episode 1 of Season 1 of ファッションの時間'),
(74, 1, 1, 'Episode 1 of Season 1 of ゲームの時間'),
(75, 1, 1, 'Episode 1 of Season 1 of お笑いの祭典'),
(76, 1, 1, 'Episode 1 of Season 1 of アートの時間'),
(77, 1, 1, 'Episode 1 of Season 1 of ビジネスの時間'),
(78, 1, 1, 'Episode 1 of Season 1 of 教育の特集'),
(79, 1, 1, 'Episode 1 of Season 1 of 料理の時間'),
(80, 1, 1, 'Episode 1 of Season 1 of スポーツの祭典'),
(81, 1, 1, 'Episode 1 of Season 1 of 音楽の特集'),
(82, 1, 1, 'Episode 1 of Season 1 of ドラマの時間'),
(83, 1, 1, 'Episode 1 of Season 1 of アニメの祭典'),
(84, 1, 1, 'Episode 1 of Season 1 of 映画の祭典'),
(85, 1, 1, 'Episode 1 of Season 1 of トークの時間'),
(86, 1, 1, 'Episode 1 of Season 1 of お笑いの特集'),
(87, 1, 1, 'Episode 1 of Season 1 of ニュースの特集'),
(88, 1, 1, 'Episode 1 of Season 1 of 旅の祭典'),
(89, 1, 1, 'Episode 1 of Season 1 of クッキングの時間'),
(90, 1, 1, 'Episode 1 of Season 1 of スポーツの特集'),
(91, 1, 1, 'Episode 1 of Season 1 of 音楽の時間'),
(92, 1, 1, 'Episode 1 of Season 1 of ドキュメンタリーの特集'),
(93, 1, 1, 'Episode 1 of Season 1 of 子供の特集'),
(94, 1, 1, 'Episode 1 of Season 1 of 歴史の特集'),
(95, 1, 1, 'Episode 1 of Season 1 of 科学の特集'),
(96, 1, 1, 'Episode 1 of Season 1 of ペットの時間'),
(97, 1, 1, 'Episode 1 of Season 1 of DIYの特集'),
(98, 1, 1, 'Episode 1 of Season 1 of 健康の特集'),
(99, 1, 1, 'Episode 1 of Season 1 of ファッションの特集'),
(100, 1, 1, 'Episode 1 of Season 1 of ゲームの特集');

-- broadcast_programsテーブルにデータを挿入
-- INSERT INTO broadcast_programs (title_id, season_no, episode_no, channel_id, slot_id, broadcast_date) VALUES
-- (1, 1, 1, 1, 1, '2023-01-01'),
-- (2, 1, 1, 2, 2, '2023-01-02'),
-- (3, 1, 1, 3, 3, '2023-01-03'),
-- (4, 1, 1, 4, 4, '2023-01-04'),
-- (5, 1, 1, 5, 5, '2023-01-05'),
-- (6, 1, 1, 6, 6, '2023-01-06'),
-- (7, 1, 1, 7, 7, '2023-01-07'),
-- (8, 1, 1, 8, 8, '2023-01-08'),
-- (9, 1, 1, 9, 9, '2023-01-09'),
-- (10, 1, 1, 10, 10, '2023-01-10'),
-- (11, 1, 1, 11, 11, '2023-01-11'),
-- (12, 1, 1, 12, 12, '2023-01-12'),
-- (13, 1, 1, 13, 13, '2023-01-13'),
-- (14, 1, 1, 14, 14, '2023-01-14'),
-- (15, 1, 1, 15, 15, '2023-01-15'),
-- (16, 1, 1, 16, 16, '2023-01-16'),
-- (17, 1, 1, 17, 17, '2023-01-17'),
-- (18, 1, 1, 18, 18, '2023-01-18'),
-- (19, 1, 1, 19, 19, '2023-01-19'),
-- (20, 1, 1, 20, 20, '2023-01-20'),
-- (21, 1, 1, 21, 21, '2023-01-21'),
-- (22, 1, 1, 22, 22, '2023-01-22'),
-- (23, 1, 1, 23, 23, '2023-01-23'),
-- (24, 1, 1, 24, 24, '2023-01-24'),
-- (25, 1, 1, 25, 25, '2023-01-25'),
-- (26, 1, 1, 26, 26, '2023-01-26'),
-- (27, 1, 1, 27, 27, '2023-01-27'),
-- (28, 1, 1, 28, 28, '2023-01-28'),
-- (29, 1, 1, 29, 29, '2023-01-29'),
-- (30, 1, 1, 30, 30, '2023-01-30'),
-- (31, 1, 1, 31, 31, '2023-01-31'),
-- (32, 1, 1, 32, 32, '2023-02-01'),
-- (33, 1, 1, 33, 33, '2023-02-02'),
-- (34, 1, 1, 34, 34, '2023-02-03'),
-- (35, 1, 1, 35, 35, '2023-02-04'),
-- (36, 1, 1, 36, 36, '2023-02-05'),
-- (37, 1, 1, 37, 37, '2023-02-06'),
-- (38, 1, 1, 38, 38, '2023-02-07'),
-- (39, 1, 1, 39, 39, '2023-02-08'),
-- (40, 1, 1, 40, 40, '2023-02-09'),
-- (41, 1, 1, 41, 41, '2023-02-10'),
-- (42, 1, 1, 42, 42, '2023-02-11'),
-- (43, 1, 1, 43, 43, '2023-02-12'),
-- (44, 1, 1, 44, 44, '2023-02-13'),
-- (45, 1, 1, 45, 45, '2023-02-14'),
-- (46, 1, 1, 46, 46, '2023-02-15'),
-- (47, 1, 1, 47, 47, '2023-02-16'),
-- (48, 1, 1, 48, 48, '2023-02-17'),
-- (49, 1, 1, 49, 49, '2023-02-18'),
-- (50, 1, 1, 50, 50, '2023-02-19'),
-- (51, 1, 1, 51, 51, '2023-02-20'),
-- (52, 1, 1, 52, 52, '2023-02-21'),
-- (53, 1, 1, 53, 53, '2023-02-22'),
-- (54, 1, 1, 54, 54, '2023-02-23'),
-- (55, 1, 1, 55, 55, '2023-02-24'),
-- (56, 1, 1, 56, 56, '2023-02-25'),
-- (57, 1, 1, 57, 57, '2023-02-26'),
-- (58, 1, 1, 58, 58, '2023-02-27'),
-- (59, 1, 1, 59, 59, '2023-02-28'),
-- (60, 1, 1, 60, 60, '2023-03-01'),
-- (61, 1, 1, 61, 61, '2023-03-02'),
-- (62, 1, 1, 62, 62, '2023-03-03'),
-- (63, 1, 1, 63, 63, '2023-03-04'),
-- (64, 1, 1, 64, 64, '2023-03-05'),
-- (65, 1, 1, 65, 65, '2023-03-06'),
-- (66, 1, 1, 66, 66, '2023-03-07'),
-- (67, 1, 1, 67, 67, '2023-03-08'),
-- (68, 1, 1, 68, 68, '2023-03-09'),
-- (69, 1, 1, 69, 69, '2023-03-10'),
-- (70, 1, 1, 70, 70, '2023-03-11'),
-- (71, 1, 1, 71, 71, '2023-03-12'),
-- (72, 1, 1, 72, 72, '2023-03-13'),
-- (73, 1, 1, 73, 73, '2023-03-14'),
-- (74, 1, 1, 74, 74, '2023-03-15'),
-- (75, 1, 1, 75, 75, '2023-03-16'),
-- (76, 1, 1, 76, 76, '2023-03-17'),
-- (77, 1, 1, 77, 77, '2023-03-18'),
-- (78, 1, 1, 78, 78, '2023-03-19'),
-- (79, 1, 1, 79, 79, '2023-03-20'),
-- (80, 1, 1, 80, 80, '2023-03-21'),
-- (81, 1, 1, 81, 81, '2023-03-22'),
-- (82, 1, 1, 82, 82, '2023-03-23'),
-- (83, 1, 1, 83, 83, '2023-03-24'),
-- (84, 1, 1, 84, 84, '2023-03-25'),
-- (85, 1, 1, 85, 85, '2023-03-26'),
-- (86, 1, 1, 86, 86, '2023-03-27'),
-- (87, 1, 1, 87, 87, '2023-03-28'),
-- (88, 1, 1, 88, 88, '2023-03-29'),
-- (89, 1, 1, 89, 89, '2023-03-30'),
-- (90, 1, 1, 90, 90, '2023-03-31'),
-- (91, 1, 1, 91, 91, '2023-04-01'),
-- (92, 1, 1, 92, 92, '2023-04-02'),
-- (93, 1, 1, 93, 93, '2023-04-03'),
-- (94, 1, 1, 94, 94, '2023-04-04'),
-- (95, 1, 1, 95, 95, '2023-04-05'),
-- (96, 1, 1, 96, 96, '2023-04-06'),
-- (97, 1, 1, 97, 97, '2023-04-07'),
-- (98, 1, 1, 98, 98, '2023-04-08'),
-- (99, 1, 1, 99, 99, '2023-04-09'),
-- (100, 1, 1, 100, 100, '2023-04-10');

DELIMITER //
CREATE PROCEDURE generate_values()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_date DATE;
    WHILE i <= 150 DO
        SET random_date = CURDATE() + INTERVAL FLOOR(RAND() * 7) -3 DAY;
        INSERT INTO broadcast_programs (title_id, season_no, episode_no, channel_id, slot_id, broadcast_date)
        VALUES (FLOOR(RAND() * 100) + 1, 1, 1, FLOOR(RAND() * 25) + 1, FLOOR(RAND() * 24) + 1, random_date);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- プロシージャを実行
CALL generate_values();





        


-- view_logsテーブルにデータを挿入
INSERT INTO view_logs (broadcast_program_id, user_id, created_at) VALUES
(1, 1, '2023-01-01 10:00:00'),
(2, 2, '2023-01-02 11:00:00'),
(2, 3, '2023-01-03 12:00:00'),
(4, 4, '2023-01-04 13:00:00'),
(5, 5, '2023-01-05 14:00:00'),
(6, 6, '2023-01-06 15:00:00'),
(7, 7, '2023-01-07 16:00:00'),
(9, 8, '2023-01-08 17:00:00'),
(9, 9, '2023-01-09 18:00:00'),
(10, 10, '2023-01-10 19:00:00'),
(11, 11, '2023-01-11 20:00:00'),
(12, 12, '2023-01-12 21:00:00'),
(9, 13, '2023-01-13 22:00:00'),
(14, 14, '2023-01-14 23:00:00'),
(15, 15, '2023-01-15 10:00:00'),
(16, 16, '2023-01-16 11:00:00'),
(17, 17, '2023-01-17 12:00:00'),
(18, 18, '2023-01-18 13:00:00'),
(19, 19, '2023-01-19 14:00:00'),
(20, 20, '2023-01-20 15:00:00'),
(21, 21, '2023-01-21 16:00:00'),
(22, 22, '2023-01-22 17:00:00'),
(23, 23, '2023-01-23 18:00:00'),
(24, 24, '2023-01-24 19:00:00'),
(25, 25, '2023-01-25 20:00:00'),
(26, 26, '2023-01-26 21:00:00'),
(27, 27, '2023-01-27 22:00:00'),
(28, 28, '2023-01-28 23:00:00'),
(29, 29, '2023-01-29 10:00:00'),
(30, 30, '2023-01-30 11:00:00'),
(31, 31, '2023-01-31 12:00:00'),
(32, 32, '2023-02-01 13:00:00'),
(33, 33, '2023-02-02 14:00:00'),
(34, 34, '2023-02-03 15:00:00'),
(35, 35, '2023-02-04 16:00:00'),
(36, 36, '2023-02-05 17:00:00'),
(37, 37, '2023-02-06 18:00:00'),
(38, 38, '2023-02-07 19:00:00'),
(39, 39, '2023-02-08 20:00:00'),
(40, 40, '2023-02-09 21:00:00'),
(41, 41, '2023-02-10 22:00:00'),
(42, 42, '2023-02-11 23:00:00'),
(43, 43, '2023-02-12 10:00:00'),
(44, 44, '2023-02-13 11:00:00'),
(45, 45, '2023-02-14 12:00:00'),
(46, 46, '2023-02-15 13:00:00'),
(47, 47, '2023-02-16 14:00:00'),
(48, 48, '2023-02-17 15:00:00'),
(49, 49, '2023-02-18 16:00:00'),
(50, 50, '2023-02-19 17:00:00');



