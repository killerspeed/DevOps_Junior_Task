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
('Разработка (Development)',80000, 160000, 1, 1, 1, '2023-02-05 11:20:00'),
('Тестирование (QA)', 900000, 960000, 1, 2, 2, '2023-02-05 11:20:00'),
('Администрирование и сети', 200000, 260000, 1, 3, 3, '2023-02-05 11:20:00'),
('Управление и менеджмент', 500000, 560000, 1, 1, 1, '2023-02-05 11:20:00'),
('Разработка программного обеспечения', 400000, 460000, 1, 3, 3, '2023-02-05 11:20:00'),
('Работа с данными и искусственным интеллектом', 300000, 360000, 1, 2, 2, '2023-02-05 11:20:00'),
('DevOps и облачные технологии', 200000, 260000, 1, 3, 3, '2023-02-05 11:20:00'),
('Кибербезопасность', 100, 1600, 1, 1, 1, '2023-02-05 11:20:00'),
('Управление IT-проектами', 100000, 160000, 1, 2, 2, '2023-02-05 11:20:00'),
('AR/VR-разработчик', 100000, 160000, 1, 1, 1, '2023-02-05 11:20:00'),
('SEO-специалист', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00'),
('Технический писатель', 100000, 160000, 1, 3, 3, '2023-02-05 11:20:00');