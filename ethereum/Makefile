MAKEFLAGS=--no-builtin-rules --no-builtin-variables --always-make
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

vendor:
	npm install

truffle-init:
	./node_modules/.bin/truffle init

truffle-compile:
	./node_modules/.bin/truffle compile

truffle-develop:
	./node_modules/.bin/truffle develop

truffle-migrate-private-net:
	./node_modules/.bin/truffle migrate --network development

truffle-console-private-net:
	./node_modules/.bin/truffle console --network development

truffle-migrate-goerli-net:
	./node_modules/.bin/truffle migrate --network goerli

truffle-console-goerli-net:
	./node_modules/.bin/truffle console --network goerli

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
