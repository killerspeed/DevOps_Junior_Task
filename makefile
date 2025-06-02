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
	docker-compose exec mysql sh -c 'mysql -u $${root} -p$${rootpassword} $${jobrate < /scripts/mysql/seed.sql'
