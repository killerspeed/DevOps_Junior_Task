CREATE DATABASE IF NOT EXISTS jobrate CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE jobrate;

CREATE TABLE IF NOT EXISTS vacancy (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    salary_from INT,
    salary_to INT,
    country_id INT,
    region_id INT,
    city_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uc_vacancy_unique_combination
    UNIQUE (title, country_id, region_id, city_id)
);

CREATE USER IF NOT EXISTS 'manticore'@'%' IDENTIFIED BY 'manticorepassword';
GRANT ALL PRIVILEGES ON jobrate.* TO 'manticore'@'%';
FLUSH PRIVILEGES;

INSERT INTO vacancy (title, salary_from, salary_to, country_id, region_id, city_id, created_at) VALUES
('русй стоайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('русскийайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('русский тоайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('руский соайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('рсский соайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('усский стайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('усский стоайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('рукий стоайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('русй стойл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('русский сйл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('руссй стоайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('русскиоайл', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00');