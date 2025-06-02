makefile
```
# Запуск всех сервисов из docker-compose.yml
up:
	docker-compose up -d

# Остановка всех сервисов
down:
	docker-compose down
```
# Запуск скрипта для заполнения данных в MySQL
seed-mysql:
docker-compose exec mysql bash -c "mysql -u пользователь -pпароль база_данных < /путь/в/контейнере/скрипт.sql"

docker-compose exec mysql sh -c 'mysql -u $${root} -p$${MYSQL_PASSWORD} $${MYSQL_DATABASE} < /scripts/mysql/seed.sql'
