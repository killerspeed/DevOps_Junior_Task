# Инструкция по запуску проекта 

## 1. Установка необходимого ПО

### Для Windows:

1. Установите**VirtualBox**:  
    [Скачать с официального сайта](https://www.virtualbox.org/wiki/Downloads)
    
2. Установите**Vagrant**:  
	[Скачать с официального сайта](https://www.vagrantup.com/downloads)

	- Запустите скачанный `.exe` файл
	- Следуйте инструкциям установщика
	- Перезагрузите компьютер


### 1.2 Проверка установки

``` bash
vagrant --version
```

## 2 Создание ВМ

1. Перейдите в папку проекта:
2. Инициализируйте Vagrant:
``` bash
  vagrant init	
```
### 2.1 Настройка конфигурации

1. Замените содержимое `Vagrantfile`на:
	- vagrant/Vagrantfile
### 2.2 Запуск виртуальных машин

``` bash
  vagrant up
```
_После выполнения vagrant up у вас будут созданы 8 виртуальные машины `название машин * и *`._

### 2.3 Работа с виртуальной машиной
- Подключиться по SSH:
  ``` bash
  vagrant ssh
  ```
- Приостановить работу:
    ``` bash
  vagrant suspend
    ```
- Полная остановка:
    ``` bash
  vagrant halt
    ```
- Удалить машину:
    
    ``` bash
  vagrant destroy
    ```

### 2.4 Перезагрузка конфигурации

После изменения Vagrantfile:
```
vagrant reload
```

#### Советы

1. При проблемах с запуском проверьте:
    
    - Включена ли виртуализация в BIOS
        
    - Достаточно ли свободного места на диске
        
    - Логи ошибок: `vagrant up --debug`
        
2. Для ускорения работы:
    
    - Используйте локальные образы (boxes)
        
        
3. Полезные команды:
    
    
    `vagrant status`    # Показать статус ВМ
   
    `vagrant port`      # Показать проброшенные порты
   
    `vagrant snapshot`  # Работа со снимками состояния

## 3 Работа с инструментом управления серверами - Ansible

### _Задание:_
- _Написать playbook, который от пользователя скопирует файлы из ветки main удалённого репозитория (GitHub) 
в папку /var/www/site на сервере с заменой файлов.
Доступ к репозиторию осуществляется с помощью rsa ключа._

### _Что вам нужно:_
1. Ansible Playbook
2. Git-репозиторий
3. Клонирование/обновление репозитория – так как используется `github`ветка поумолчянию `main` и поместить их в /var/www/site
4. Доступ по SSH-ключу

### Пошаговая настройка

1. На управляющем сервере
    Установка Ansible ( в моем случае делаться это все через vagrant) для ручной устаноки:
``` bash
sudo apt update
```
```bash
sudo apt install ansible -y
```

2. Проверка установки

``` bash
ansible --version
```

### Настройка SSH-доступа к целевому хосту

1. Генерация SSH-ключа (если нет):

```
ssh-keygen
```

2. Копирование ключа на удалённый хост:

```bash
ssh-copy-id user@remote_host
```

### Создание inventory-файла

Создание inventory-файла:

``` ini
[site]
site ansible_host=192.20.1.21
```

### Проверка подключения

```
ansible site -m ping
```

Итоговый Playbook [(clone_site.yml)](ansible/clone_site.yml)


## 4 Работа с виртуальными машинами и manticore

### Задание:
_Создать 5 ВМ ( Ubuntu Server), они должны быть в одной серой подсети. 
У каждой по два диска: первый загрузочный SSD, второй - нереплицируемый SSD._

### Шаги выполнения
1. Установка ManticoreSearch 6.3.6
- Добавление официального репозитория Manticore. 
- Установка указанной версии (6.3.6). 
- Запуск и включение службы manticore.
2. Монтирование SSD-диска
- Создание файловой системы (если диск не размечен).
- Монтирование в /var/lib/manticore/data/disk_index.
3. Настройка прав доступа
- Установка владельца manticore:manticore для /var/lib/manticore/ и вложенных файлов.

### Инструкция по запуску

1. В ранее созданый inventory-файл добовляем
``` ini
 [search_servers]
manticore ansible_host=192.168.1.101
manticore1 ansible_host=192.168.1.102
manticore2 ansible_host=192.168.1.103
manticore3 ansible_host=192.168.1.104
manticore4 ansible_host=192.168.1.105
```

### Запуск Playbook

``` bssh
ansible-playbook -i inventory install_manticore.yml
```
- Продакшен версия [ansible-playbook](ansible/install_manticore.yml)
- Первая версия ansible-playbook
 
```
---
- name: dowloud
  hosts: all
  become: yes
  tasks:
    - block:
        - name: Create download directory
          ansible.builtin.file:
            path: "{{ download_dir }}"
            state: directory
            mode: '0755'
          become: yes

        - name: manticore_version
          ansible.builtin.get_url:
            url: "{{ repo_url }}/{{ item.name }}_{{ manticore_version }}_{{ item.type }}.deb"
            dest: "{{ download_dir }}/{{ item.name }}-{{ manticore_version }}.deb"
          loop: "{{ manticore_packages }}"

        - name: manticore_columnar_version
          ansible.builtin.get_url:
            url: "https://repo.manticoresearch.com/repository/manticoresearch_jammy/dists/jammy/main/binary-amd64/{{ item.name }}_{{ manticore_columnar_version }}_{{ item.type }}.deb"
            dest: "{{ download_dir }}/{{ item.name }}-{{ manticore_columnar_version }}.deb"
          loop: "{{ columnar_packages }}"

        - name: manticore_backup_version
          ansible.builtin.get_url:
            url: "{{ repo_url }}/{{ item.name }}_{{ manticore_backup_version }}_{{ item.type }}.deb"
            dest: "/manticore/{{ item.name }}-{{ manticore_backup_version }}.deb"
          loop: "{{ backup_packages }}"

        - name: manticore_buddy_version
          ansible.builtin.get_url:
            url: "{{ repo_url }}/{{ item.name }}_{{ manticore_buddy_version }}_{{ item.type }}.deb"
            dest: "/manticore/{{ item.name }}-{{ manticore_buddy_version }}.deb"
          loop: "{{ buddy_packages }}"

        - name: manticore_executor_version
          ansible.builtin.get_url:
            url: "{{ repo_url }}/{{ item.name }}_{{ manticore_executor_version }}_{{ item.type }}.deb"
            dest: "/manticore/{{ item.name }}-{{ manticore_executor_version }}.deb"
          loop: "{{ executor_packages }}"

        - name: manticore_icudata_version
          ansible.builtin.get_url:
            url: "{{ repo_url }}/{{ item.name }}-{{ manticore_icudata_version }}.deb"
            dest: "/manticore/{{ item.name }}-{{ manticore_icudata_version }}.deb"
          loop: "{{ icudata_packages }}"

        -  name: manticore_galera_version
           ansible.builtin.get_url:
             url: "{{ repo_url }}/{{ item.name }}_{{ manticore_galera_version }}_{{ item.type }}.deb"
             dest: "/manticore/{{ item.name }}-{{ manticore_galera_version }}.deb"
           loop: "{{ galera_packages }}"

        - name: manticore_tzdata_version
          ansible.builtin.get_url:
            url: "{{ repo_url }}/{{ item.name }}_{{ manticore_tzdata_version }}_{{ item.type }}.deb"
            dest: "/manticore/{{ item.name }}-{{ manticore_tzdata_version }}.deb"
          loop: "{{ tzdata_packages }}"

```

## 5 Работа с Docker
### _Задание:_
- Развернуть связку MySQL и ManticoreSearch через docker-compose
- Заполнить таблицы БД тестовыми данными
- Реализовать ограничение уникальности на уровне MySQL

### 1. Docker Compose конфигурация
Создан файл [docker-compose.yml](docker/docker-compose.yml), содержащий:
- Сервис **MySQL 8.0.39** с предварительно настроенной БД `jobrate`
- Сервис **ManticoreSearch 6.3.6**
- Настроена сеть для взаимодействия между сервисами

### 1. Настройка MySQL сервиса
- Развернут контейнер с MySQL 8.0.39
- Создана база данных `jobrate`
- В БД создана таблица `vacancy` с требуемой структурой
- Реализовано ограничение уникальности для комбинации полей с помощью файла [init.sql](docker/init.sql)

### Настройка ManticoreSearch

```
CREATE TABLE vacancy
(
    id BIGINT,
    title TEXT,
    salary_from FLOAT,
    salary_to FLOAT,
    country_id INT,
    region_id INT,
    city_id INT,
    created_at TIMESTAMP
)
engine='rowwise'  
html_strip='1'   
min_word_len='3'  
stopwords='en,ru' 
morphology='stem_en,stem_ru'
```

```
INSERT INTO vacancy (id, title, salary_from, salary_to, country_id, region_id, city_id, created_at)
VALUES
(1, 'Разработка (Development)', 80000, 160000, 1, 1, 1, 1609459200),  -- 2021-01-01
(2, 'Тестирование (QA)', 900000, 960000, 1, 2, 2, 1675555200),       -- 2023-02-05
(3, 'Администрирование и сети', 200000, 260000, 1, 3, 3, 1675641600), -- 2023-02-06
(4, 'Управление и менеджмент', 500000, 560000, 1, 1, 1, 1678060800), -- 2023-03-06
(5, 'Разработка программного обеспечения', 400000, 460000, 1, 3, 3, 1678320000), -- 2023-03-09
(6, 'Работа с данными и искусственным интеллектом', 300000, 360000, 1, 2, 2, 1679184000), -- 2023-03-19
(7, 'DevOps и облачные технологии', 200000, 260000, 1, 3, 3, 1679270400), -- 2023-03-20
(8, 'Кибербезопасность', 100, 1600, 1, 1, 1, 1679356800),             -- 2023-03-21
(9, 'Управление IT-проектами', 100000, 160000, 1, 2, 2, 1684540800), -- 2023-05-20
(10, 'AR/VR-разработчик', 100000, 160000, 1, 1, 1, 1684540800),      -- 2023-05-20
(11, 'SEO-специалист', 100000, 160000, 1, 3, 3, 1747699200),         -- 2024-05-20
(12, 'Технический писатель', 100000, 160000, 1, 3, 3, 1747699200);   -- 2024-05-20
```

### Инструкция по запуску
- Выполнить docker-compose up -d

#### Для проверки работы:

- MySQL: docker exec -it mysql mysql -uroot -p
- Manticore: docker exec -it manticoresearch mysql -h0 -P9306
- sudo docker exec -it mysql_db mysql -uroot -prootpassword jobrate -e "SHOW TABLES; Select * from vacancy"


```
vagrant@ubuntu-jammy:~$ sudo docker exec -it mysql_db mysql -uroot -prootpassword jobrate -e "SHOW TABLES; Select * from vacancy"
mysql: [Warning] Using a password on the command line interface can be insecure.
+-------------------+
| Tables_in_jobrate |
+-------------------+
| vacancy           |
+-------------------+
+----+-------------------------------------------------------------------------------------+-------------+-----------+------------+-----------+---------+---------------------+
| ID | title                                                                               | salary_from | salary_to | country_id | region_id | city_id | created_at          |
+----+-------------------------------------------------------------------------------------+-------------+-----------+------------+-----------+---------+---------------------+
|  1 | Разработка (Development)                                                  |       80000 |    160000 |          1 |         1 |       1 | 2023-02-05 11:20:00 |
|  2 | Тестирование (QA)                                                       |      900000 |    960000 |          1 |         2 |       2 | 2023-02-05 11:20:00 |
|  3 | Администрирование и сети                                      |      200000 |    260000 |          1 |         3 |       3 | 2023-02-05 11:20:00 |
|  4 | Управление и менеджмент                                        |      500000 |    560000 |          1 |         1 |       1 | 2023-02-05 11:20:00 |
|  5 | Разработка программного обеспечения                |      400000 |    460000 |          1 |         3 |       3 | 2023-02-05 11:20:00 |
|  6 | Работа с данными и искусственным интеллектом |      300000 |    360000 |          1 |         2 |       2 | 2023-02-05 11:20:00 |
|  7 | DevOps и облачные технологии                                     |      200000 |    260000 |          1 |         3 |       3 | 2023-02-05 11:20:00 |
|  8 | Кибербезопасность                                                  |         100 |      1600 |          1 |         1 |       1 | 2023-02-05 11:20:00 |
|  9 | Управление IT-проектами                                          |      100000 |    160000 |          1 |         2 |       2 | 2023-02-05 11:20:00 |
| 10 | AR/VR-разработчик                                                        |      100000 |    160000 |          1 |         1 |       1 | 2023-02-05 11:20:00 |
| 11 | SEO-специалист                                                            |      100000 |    160000 |          1 |         3 |       3 | 2023-02-05 11:20:00 |
| 12 | Технический писатель                                             |      100000 |    160000 |          1 |         3 |       3 | 2023-02-05 11:20:00 |
+----+-------------------------------------------------------------------------------------+-------------+-----------+------------+-----------+---------+---------------------+
vagrant@ubuntu-jammy:~$
```

```
vagrant@ubuntu-jammy:~$ sudo docker exec -it manticoresearch mysql -h 127.0.0.1 -P 9306 -e "select * from vacancy;"
+------+-------------------------------------------------------------------------------------+---------------+---------------+------------+-----------+---------+------------+
| id   | title                                                                               | salary_from   | salary_to     | country_id | region_id | city_id | created_at |
+------+-------------------------------------------------------------------------------------+---------------+---------------+------------+-----------+---------+------------+
|    1 | Разработка (Development)                                                            |  80000.000000 | 160000.000000 |          1 |         1 |       1 | 1609459200 |
|    2 | Тестирование (QA)                                                                   | 900000.000000 | 960000.000000 |          1 |         2 |       2 | 1675555200 |
|    3 | Администрирование и сети                                                            | 200000.000000 | 260000.000000 |          1 |         3 |       3 | 1675641600 |
|    4 | Управление и менеджмент                                                             | 500000.000000 | 560000.000000 |          1 |         1 |       1 | 1678060800 |
|    5 | Разработка программного обеспечения                                                 | 400000.000000 | 460000.000000 |          1 |         3 |       3 | 1678320000 |
|    6 | Работа с данными и искусственным интеллектом                                        | 300000.000000 | 360000.000000 |          1 |         2 |       2 | 1679184000 |
|    7 | DevOps и облачные технологии                                                        | 200000.000000 | 260000.000000 |          1 |         3 |       3 | 1679270400 |
|    8 | Кибербезопасность                                                                   |    100.000000 |   1600.000000 |          1 |         1 |       1 | 1679356800 |
|    9 | Управление IT-проектами                                                             | 100000.000000 | 160000.000000 |          1 |         2 |       2 | 1684540800 |
|   10 | AR/VR-разработчик                                                                   | 100000.000000 | 160000.000000 |          1 |         1 |       1 | 1684540800 |
|   11 | SEO-специалист                                                                      | 100000.000000 | 160000.000000 |          1 |         3 |       3 | 1747699200 |
|   12 | Технический писатель                                                                | 100000.000000 | 160000.000000 |          1 |         3 |       3 | 1747699200 |
+------+-------------------------------------------------------------------------------------+---------------+---------------+------------+-----------+---------+------------+
```

##  Задание 4. Поиск:

### Требования:
1. Реализовать поиск по полю `title` с учетом морфологии русского языка
2. Поиск должен учитывать различные словоформы (например: "разработка", "разработки", "разработку")

### Установка скрипта в контейнер ManticoreSearch:


- Сохраните скрипт как /usr/local/bin/search.sh внутри контейнера:
```angular2html
sudo docker exec -i manticoresearch bash -c 'cat > /usr/local/bin/search.sh' < search.sh
```
- Дайте права на выполнение:
```angular2html
sudo docker exec manticoresearch chmod +x /usr/local/bin/search.sh
```
- вывод
```angular2html
vagrant@ubuntu-jammy:~$ sudo docker exec -it manticoresearch search.sh 'Разработка'
ID       Должность                       ЗП от  ЗП до  Дата
-------------------------------------------------------------------------------
+------+----------------------------------------------------------------------+---------------+---------------+------------+
|    5 |                                  Разработка программного обеспечения | 400000.000000 | 460000.000000 | 1678320000 |
|    1 |                                             Разработка (Development) |  80000.000000 | 160000.000000 | 1609459200 |
+------+----------------------------------------------------------------------+---------------+---------------+------------+
```

скрипт для поиска 
[search.sh](docker/search.sh)

---

