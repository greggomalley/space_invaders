RADAR ?= config/radar/radar_1.txt

build:
	docker build -t space_invaders .

run:
	docker run space_invaders ruby space_invaders.rb $(RADAR)

shell:
	docker run -it -v $(pwd):/app space_invaders bash

.PHONY: build build-prod run run-prod shell