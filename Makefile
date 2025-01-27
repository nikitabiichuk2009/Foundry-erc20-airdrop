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

generate-input:
	forge script script/GenerateInput.s.sol:GenerateInput

generate-merkle:
	forge script script/MakeMerkle.s.sol:MakeMerkle

install:
	forge install openzeppelin/openzeppelin-contracts --no-commit && forge install foundry-rs/forge-std --no-commit