# DiamondDream.Cards Nft 
## Open Source Non-Fungible Token Platform Demo, by AnChain.AI

Note: source code in the process of migrating and will be completed in the week of Jun 11, 2021.

Currently supports : 
- Ethereum solidity smart contract (This demo)
- Flow cadence smart contract

Demo website: 
https://demo.diamonddream.cards/



## How to edit in remix

```
npm install remix-ide -g
cd contracts
remix-ide
```

## How to compile and deploy

```
npm install -g truffle
truffle compile
truffle migrate --network development
truffle migrate --network rinkeby
```

## How to run local ETH

```
npm install -g ganache-cli
ganache-cli -p 9545
```

## How to run test

```
truffle compile
npm run test
```


# Directory
```
contracts/: Directory for Solidity contracts
migrations/: Directory for scriptable deployment files
test/: Directory for test files for testing your application and contracts
src/: React front end
server/: back end
public/:
.env: credentials
truffle.js: Truffle configuration file
```

Developed by AnChain.AI team. 2021
