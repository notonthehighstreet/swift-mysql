TEST_COMMAND = swift test -Xlinker -L/usr/local/lib

build:
	@echo --- Building package
	swift build -Xlinker -L/usr/local/lib

test_unit: build
	@echo --- Running tests

	$(TEST_COMMAND) --filter MySQLTests

test_one: build
	swift test -Xlinker -L/usr/local/lib --filter ${TEST}

test_integration: build
	@echo --- Running integration tests

	docker run --name mysqlswift \
	-e MYSQL_ROOT_PASSWORD=my-secret-pw \
	-d \
	-p 3306:3306 mysql

	sleep 15

	trap '$(TEST_COMMAND) --filter IntegrationTests' EXIT

	docker stop mysqlswift
	docker rm -v mysqlswift

swiftdocs:
	jazzy \
  --clean \
  --author Nic Jackson \
  --author_url https://nicholasjackson.io \
  --github_url https://github.com/nicholasjackson/swift-mysql \
  --module MySQL \
  --output docs/ \

clean:
	@echo --- Clean build folder
	rm -rf .build
