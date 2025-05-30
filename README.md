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
- _Развернуть отказоустойчивый кластер поискового движка ManticoreSearch 6.3.6 
на 5 виртуальных машинах (Ubuntu Server) с автоматическим монтированием SSD-дисков и настройкой прав доступа._

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
192.20.1.*
```

### Проверка подключения

```
ansible webservers -m ping
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

Первая версия ansible-playbook

Продакшен версия [ansible-playbook](ansible/install_manticore.yml)
 
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
- _Развернуть связку MySQL и ManticoreSearch через docker-compose, заполнить таблицы БД тестовыми данными и 
реализовать ограничение уникальности на уровне MySQL_

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
(1, 'ыфафыафыr', 150000, 200000, 1, 10, 100, 1609459200),  -- 2021-01-01
(2, 'афыафыафы', 120000, 180000, 1, 10, 101, 1612137600); -- 2021-02-01
```


### Инструкция по запуску
- Выполнить docker-compose up -d

#### Для проверки работы:

- MySQL: docker exec -it mysql mysql -uroot -p
- Manticore: docker exec -it manticore mysql -h0 -P9306









```angular2html
INSERT INTO vacancy (id, title, salary_from, salary_to, country_id, region_id, city_id, created_at)
VALUES
(3, 'ыфафыафыr', 150000, 200000, 1, 10, 100, 1609459200),  -- 2021-01-01
(4, 'афыафыафы', 120000, 180000, 1, 10, 101, 1612137600); -- 2021-02-01


INSERT INTO vacancy (id, title, salary_from, salary_to, country_id, region_id, city_id, created_at)
SELECT 
    id, 
    title, 
    salary_from, 
    salary_to, 
    country_id, 
    region_id, 
    city_id, 
    UNIX_TIMESTAMP(created_at)
FROM 
    mysql('host=mysql_db dbname=your_db user=your_user password=your_pass', 'vacancies');

```