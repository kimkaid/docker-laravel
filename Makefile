up:
	docker-compose up -d
build:
	docker-compose build --no-cache --force-rm
laravel-install:
	docker-compose exec -T app composer create-project --prefer-dist laravel/laravel .
create-project:
	@make build
	@make up
	@make laravel-install
	docker-compose exec -T app php artisan key:generate
	docker-compose exec -T app php artisan storage:link
	docker-compose exec -T app chmod -R 777 storage bootstrap/cache
	@make migrate
	@make seed
install-recommend-packages:
	docker-compose exec -T app composer require doctrine/dbal "^2"
	docker-compose exec -T app composer require --dev ucan-lab/laravel-dacapo
	docker-compose exec -T app composer require --dev barryvdh/laravel-ide-helper
	docker-compose exec -T app composer require --dev beyondcode/laravel-dump-server
	docker-compose exec -T app composer require --dev barryvdh/laravel-debugbar
	docker-compose exec -T app composer require --dev roave/security-advisories:dev-master
	docker-compose exec -T app php artisan vendor:publish --provider="BeyondCode\DumpServer\DumpServerServiceProvider"
	docker-compose exec -T app php artisan vendor:publish --provider="Barryvdh\Debugbar\ServiceProvider"
init:
	docker-compose up -d --build
	docker-compose exec -T app composer install
	docker-compose exec -T app cp .env.example .env
	docker-compose exec -T app php artisan key:generate
	docker-compose exec -T app php artisan storage:link
	docker-compose exec -T app chmod -R 777 storage bootstrap/cache
	@make fresh
remake:
	@make destroy
	@make init
stop:
	docker-compose stop
down:
	docker-compose down --remove-orphans
restart:
	@make down
	@make up
destroy:
	docker-compose down --rmi all --volumes --remove-orphans
destroy-volumes:
	docker-compose down --volumes --remove-orphans
ps:
	docker-compose ps
logs:
	docker-compose logs
logs-watch:
	docker-compose logs --follow
log-web:
	docker-compose logs web
log-web-watch:
	docker-compose logs --follow web
log-app:
	docker-compose logs app
log-app-watch:
	docker-compose logs --follow app
log-db:
	docker-compose logs db
log-db-watch:
	docker-compose logs --follow db
web:
	docker-compose exec -T web ash
app:
	docker-compose exec -T app bash
migrate:
	docker-compose exec -T app php artisan migrate
fresh:
	docker-compose exec -T app php artisan migrate:fresh --seed
seed:
	docker-compose exec -T app php artisan db:seed
dacapo:
	docker-compose exec -T app php artisan dacapo
rollback-test:
	docker-compose exec -T app php artisan migrate:fresh
	docker-compose exec -T app php artisan migrate:refresh
tinker:
	docker-compose exec -T app php artisan tinker
test:
	docker-compose exec -T app php artisan test
optimize:
	docker-compose exec -T app php artisan optimize
optimize-clear:
	docker-compose exec -T app php artisan optimize:clear
cache:
	docker-compose exec -T app composer dump-autoload -o
	@make optimize
	docker-compose exec -T app php artisan event:cache
	docker-compose exec -T app php artisan view:cache
cache-clear:
	docker-compose exec -T app composer clear-cache
	@make optimize-clear
	docker-compose exec -T app php artisan event:clear
npm:
	@make npm-install
npm-install:
	docker-compose exec -T web npm install
npm-dev:
	docker-compose exec -T web npm run dev
npm-watch:
	docker-compose exec -T web npm run watch
npm-watch-poll:
	docker-compose exec -T web npm run watch-poll
npm-hot:
	docker-compose exec -T web npm run hot
yarn:
	docker-compose exec -T web yarn
yarn-install:
	@make yarn
yarn-dev:
	docker-compose exec -T web yarn dev
yarn-watch:
	docker-compose exec -T web yarn watch
yarn-watch-poll:
	docker-compose exec -T web yarn watch-poll
yarn-hot:
	docker-compose exec -T web yarn hot
db:
	docker-compose exec -T db bash
sql:
	docker-compose exec -T db bash -c 'mysql -u $$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE'
redis:
	docker-compose exec -T redis redis-cli
ide-helper:
	docker-compose exec -T app php artisan clear-compiled
	docker-compose exec -T app php artisan ide-helper:generate
	docker-compose exec -T app php artisan ide-helper:meta
	docker-compose exec -T app php artisan ide-helper:models --nowrite
