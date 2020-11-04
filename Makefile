# setup: frontend docs backend

docker-up:
	cd ./deploy && docker-compose up -d

docs:
	mix docs