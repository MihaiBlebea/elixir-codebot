setup: build-frontend build-backend

build-frontend: 
	cd ./front && npm run build

build-backend:
	mix run --no-halt

build-docker:
	docker build -t demo-elixir-app .

run-docker:
	ocker run -t demo-elixir-app