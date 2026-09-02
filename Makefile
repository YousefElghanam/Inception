all: nginx wordpress mariadb cleanup run

nginx:
	docker build -t nginx srcs/requirements/nginx/

wordpress:
	@echo 'TODO: wordpress'

mariadb:
	@echo 'TODO: mariadb'

cleanup:
	docker system prune -f

run:
	@echo 'TODO: run' # here we use docker compose??

clean:
	@echo 'TODO: make clean'

fclean:
	# Care, this will remove all docker stuff.
	# Better delete all containers, images and volumes one by one
	docker system prune -f -a --volumes 

