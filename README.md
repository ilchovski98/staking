## Calculation Explanation
The math behind determining how much a user should be paid is done by calculating the difference between tokenRewardPerToken since the deploy of the contract and the s_userRewardPerTokenPaid[account] (tokenRewardPerToken value since the last user balance change (withdraw, deposit, claimRewards)). This way we store in s_rewards[account] how much the user must be paid so far by multiplying the old balance of staked tokens he had by the difference in tokenRewardPerToken and last user recorded tokenRewardPerToken (s_userRewardPerTokenPaid[account]) + the cached user rewards from before.

This way we don't have to store info regarding how much N tokens of user, were staked for since when, as this would become very difficult and expensive.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
