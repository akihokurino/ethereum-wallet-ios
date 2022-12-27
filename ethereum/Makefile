vendor:
	npm install

compile:
	npx hardhat compile

.PHONY: test
test:
	npx hardhat test

node:
	npx hardhat node

deploy-geth:
	npx hardhat run scripts/deploy.ts --network geth

deploy-hardhat:
	npx hardhat run scripts/deploy.ts --network hardhat

deploy-goerli:
	npx hardhat run scripts/deploy.ts --network goerli

init-private-net:
	geth --datadir ./private-net/ init ./private-net/genesis.json

console-private-net:
	geth --networkid "10" --port 8545 --http --nodiscover --datadir ./private-net/ --allow-insecure-unlock --unlock 0,1 --password ./private-net/password console

reset-private-net:
	rm -rf ./private-net/geth/*
	rm -rf ./private-net/history
	touch ./private-net/history
	geth --datadir ./private-net/ init ./private-net/genesis.json

import-private-net:
	geth account import --datadir ./private-net/ ./private-net/key.prv

extract-abi:
	cat artifacts/contracts/SimpleToken.sol/SimpleToken.json | jq '.abi' > artifacts/contracts/SimpleToken.sol/SimpleToken.abi.json

show-abi:
	cat artifacts/contracts/SimpleToken.sol/SimpleToken.json | jq '.abi' | jq '@json' -c