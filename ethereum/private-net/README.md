## アカウント作成

```
personal.newAccount("1234")
```

## アカウントの確認

```
eth.accounts
eth.accounts[0]
```

## コインベースアカウントの確認

```
eth.coinbase
```

## コインベースアカウントの変更

```
miner.setEtherbase(eth.accounts[1])
```

## genesis ブロックの確認

```
eth.getBlock(0)
```

## 1 スレッドでマイニングの開始+停止

```
miner.start(1)
miner.stop()
```

## マイニングの確認

```
eth.mining
```

## コインベースの残高確認

マイニングをすることにより残高が増える

```
eth.getBalance(eth.accounts[0])
web3.fromWei(eth.getBalance(eth.accounts[0]), "ether")
```

## ether の送金

private ネットでは geth 起動時にパスワードを事前に設定可能

送金直後ではまだトランザクションがブロックに組み込まれていないため、残高は増えない

```
personal.unlockAccount(eth.accounts[0])
eth.sendTransaction({from: eth.accounts[0], to: eth.accounts[2], value: web3.toWei(5, "ether")})
web3.fromWei(eth.getBalance(eth.accounts[0]), "ether")
web3.fromWei(eth.getBalance(eth.accounts[2]), "ether")
```

## トランザクションの確認

トランザクションを作成直後では BlockHash や BlockNumber は null になっており、マイニングを実行することによりブロックに取り込まれる

```
eth.getTransaction("0x9f1df3cd75e273cafb4fc4e6ae774ebc4a4349246737f26d3b40319a657041cc")
```

## トランザクションレシートの確認

```
eth.getTransactionReceipt("0x9f1df3cd75e273cafb4fc4e6ae774ebc4a4349246737f26d3b40319a657041cc")
```

## ブロックの確認

```
eth.getBlock("0x5bab9872aac39a6a901bad9077d97d141354db14e5925921c17fd5f7410023ad")
eth.getBlockByNumber(6)
```
