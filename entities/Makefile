#   This file is part of Bob.
#
#   Bob is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Bob is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with Bob. If not, see <http://www.gnu.org/licenses/>.

all: test compile

.PHONY: test
test:
	docker kill bob-test-storage bob-test-queue && \
		docker rm bob-test-storage bob-test-queue || true
	docker network rm bob-net || true
	docker network create bob-net
	docker run \
		-d \
		--name bob-test-storage \
		-p 5433:5432 \
		-e POSTGRES_DB=bob-test \
		-e POSTGRES_USER=bob \
		-e POSTGRES_PASSWORD=bob \
		--network bob-net \
		postgres:alpine
	docker run \
		-d \
		--name bob-test-queue \
		-p 5673:5672 \
		--network bob-net \
		rabbitmq:3-alpine
	sleep 7 # TODO: Find a better way to wait till things come up.
	clojure -M:test --fail-fast
	docker kill bob-test-storage bob-test-queue && \
		docker rm bob-test-storage bob-test-queue
	docker network rm bob-net

compile:
	clojure -X:depstar uberjar :jar entities.jar :aot true :main-class entities.main

docker-image:
	docker build -t ghcr.io/bob-cd/entities .

docker-push: docker-image
	docker push ghcr.io/bob-cd/entities

clean:
	rm -rf .cpcache entities.jar pom.xml
	docker rmi ghcr.io/bob-cd/entities || true
