TEST_COMMAND = swift test -Xlinker -L/usr/local/lib

build:
	@echo --- Building package
	swift build -Xlinker -L/usr/local/lib

test_unit: build
	@echo --- Running tests

	$(TEST_COMMAND) -s MySQLTests.MySQLConnectionTests
	$(TEST_COMMAND) -s MySQLTests.MySQLTransactionTests
	$(TEST_COMMAND) -s MySQLTests.MySQLConnectionPoolTests
	$(TEST_COMMAND) -s MySQLTests.MySQLFieldParserTests
	$(TEST_COMMAND) -s MySQLTests.MySQLQueryBuilderTests
	$(TEST_COMMAND) -s MySQLTests.MySQLResultTests
	$(TEST_COMMAND) -s MySQLTests.MySQLRowParserTests

test_one: build
	swift test -Xlinker -L/usr/local/lib -s ${TEST}

test_integration: build
	@echo --- Running integration tests

	docker run --name mysqlswift \
	-e MYSQL_ROOT_PASSWORD=my-secret-pw \
	-d \
	-p 3306:3306 mysql

	sleep 15

	trap '$(TEST_COMMAND) -s IntegrationTests.IntegrationTests' EXIT

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
