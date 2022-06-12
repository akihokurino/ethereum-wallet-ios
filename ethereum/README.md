## Owner Address（Ropsten）

`0x1341048E3d37046Ca18A09EFB154Ea9771744f41`

## Contract Address（Ropsten）

`0x803c6922F39792Bd17DE55Db7eFcd7b4a206ebA4`

## Samples

```
// check basic info
let t = await Token.deployed()
t.name()
t.symbol()
t.totalSupply()

// get accounts
let accounts = await web3.eth.getAccounts()

// check balance of token
let balance = await t.balanceOf(accounts[0])
balance.toNumber()

// send token
await t.transfer(accounts[1], 100)
```
