setup: frontend docs backend

frontend: 
	cd ./front && npm run build

backend:
	mix run --no-halt

docker: docker-build docker-run

docker-build:
	docker build -t demo-elixir-app .

docker-run:
	docker run -t demo-elixir-app

docs:
	mix docs