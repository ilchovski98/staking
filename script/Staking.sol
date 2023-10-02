// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Staking {
  error Staking__TransferFailed();

  IERC20 public s_stakingToken;

  // address -> staking balance
  mapping(address => uint256) public s_balances;
  uint256 public s_totalSupply;
  uint256 public s_rewardPerTokenStored;
  uint256 public s_lastUpdateTime;

  modifier updateReward(address account) {
    // how much reward per token?
    // last timestamp
    // 12 - 1, user earned X tokens
    s_rewardPerTokenStored = rewardPerToken();
    s_lastUpdateTime = block.timestamp;
    s_rewards[account] = earned(account);
    _;
  }

  constructor(address stakingToken) {
    s_stakingToken = IERC20(stakingToken);
  }

  function earned(address account) public view returns (uint256) {
    // ...
  }

  function rewardPerToken() public view returns (uint256) {
    if (s_totalSupply == 0) {
      return s_rewardPerTokenStored;
    }
    return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
  }

  // do we allow any tokens = no
  //    - should use chainlink to convert the prices of tokens
  // allow specific token = yes
  function stake(uint256 amount) external {
    // keep track of user staking balance
    s_balances[msg.sender] += amount;
    // keep track of total amount of tokens
    s_totalSupply += amount;
    // transfer the tokens to this contract
    bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
    if (!success) {
      revert Staking__TransferFailed();
    }
  }

  function withdraw(uint256 amount) external {
    s_balances[msg.sender] -= amount;
    // keep track of total amount of tokens
    s_totalSupply -= amount;
    // transfer the tokens to this contract
    bool success = s_stakingToken.transfer(msg.sender, amount);
    if (!success) {
      revert Staking__TransferFailed();
    }
  }

  function claimReward() external {
    // how much reward the user should get?
    // The most basic defi rewards system is N tokens per second
    // And disperse them to all token stakers

    // 100 reward tokens / second
    // staked: 50 tokens / 20 tokens, 30 tokens (total: 100)
    // rewards: 50 tokens, 20 tokens, 30 tokens

    // staked: 100 / 50 / 20 / 30 (total: 200)
    // rewards: 50 / 25 / 10 / 15
  }
}
