// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import "forge-std/console.sol";
import { Staking } from "../src/Staking.sol";
import { Token } from "../src/Token.sol";

contract CounterTest is Test {
  error CustomError();
  address owner;
  address alice;
  address bob;

  Staking public staking;
  Token public rewardToken;
  Token public token;
  uint256 SECONDS_IN_A_DAY = 86400;
  uint256 SECONDS_IN_A_YEAR = 31449600;

  function setUp() public virtual {
    // new deployed contracts will have Test as owner
    owner = address(this);

    alice = address(1);
    bob = address(2);

    token = new Token();
    rewardToken = new Token();
    staking = new Staking(address(token), address(rewardToken));
    bool success = rewardToken.transfer(address(staking), rewardToken.balanceOf(owner));
    if (!success) revert CustomError();
    console.log("deploying contracts");
  }

  function testStaking() public {
    // vm.prank(address)
    // vm.startPrank(address)
    // vm.stopPrank(address)
    // per sec we get 100

    uint256 amount = 10;
    token.transfer(alice, amount);
    token.transfer(bob, amount);
    vm.startPrank(alice);

    token.approve(address(staking), amount);
    staking.stake(amount);
    console.log('Alice stakes');
    assertEq(staking.s_balances(alice), amount);

    uint256 startingEarned = staking.earned(alice);

    console.log('Alice Starting earned: ', startingEarned);

    skip(10);
    console.log('forward time');

    uint256 endingEarnedAlice1 = staking.earned(alice);
    console.log('Alice earned so far: ', endingEarnedAlice1);
    vm.stopPrank();

    vm.startPrank(bob);
    token.approve(address(staking), amount);
    staking.stake(amount);
    console.log('Bob stakes');
    skip(10);
    console.log('forward time');
    uint256 endingEarnedAlice2 = staking.earned(alice);
    uint256 endingEarnedBob = staking.earned(bob);
    console.log('Alice earned: ', endingEarnedAlice2);
    console.log('Bob earned: ', endingEarnedBob);

    // staking.claimReward();
    // console.log('Reward token balance', rewardToken.balanceOf(alice));
  }
}
