-include .env

.PHONY: all test deploy

all: build

clean:
	forge clean

build-clean: clean build

build:
	forge build

test:
	forge test -vvvv

format:
	forge fmt

install:
	forge install openzeppelin/openzeppelin-contracts --no-commit && forge install foundry-rs/forge-std --no-commit