// SPDX-License-Identifier: MIT
// Inspired by https://solidity-by-example.org/defi/staking-rewards/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/console.sol";

error TransferFailed();
error NeedsMoreThanZero();

contract Staking is ReentrancyGuard {
    IERC20 public s_rewardsToken;
    IERC20 public s_stakingToken;

    // This is the reward token per second
    // Which will be multiplied by the tokens the user staked divided by the total
    // This ensures a steady reward rate of the platform
    // So the more users stake, the less for everyone who is staking.
    uint256 public constant REWARD_RATE = 100;
    uint256 public s_lastUpdateTime;
    uint256 public s_rewardPerTokenStored;

    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    uint256 private s_totalSupply;
    mapping(address => uint256) public s_balances;

    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    constructor(address stakingToken, address rewardsToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardsToken = IERC20(rewardsToken);
    }

    /**
     * @notice How much reward a token gets based on how long it's been in and during which "snapshots"
     */
    function rewardPerToken() public view returns (uint256) {
      console.log('function rewardPerToken() public view returns (uint256):::');
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    /**
     * @notice How much reward a user has earned
     */
    function earned(address account) public view returns (uint256) {
      console.log('function earned(address account) public view returns (uint256):::');
      uint256 _balance = s_balances[account];
      uint256 _rewardPerToken = rewardPerToken();// 1.1 ->
      uint256 _s_userRewardPerTokenPaid = s_userRewardPerTokenPaid[account]; // 1
      uint256 _s_rewards = s_rewards[account]; // 10
      console.log('((s_balances[account]:', s_balances[account], '*(rewardPerToken(): ', _rewardPerToken);
      console.log('- s_userRewardPerTokenPaid[account]: ', _s_userRewardPerTokenPaid, ')) / 1e18) + _s_rewards: ', s_rewards[account]);

        return
            ((_balance * (_rewardPerToken - _s_userRewardPerTokenPaid)) /
                1e18) + _s_rewards;
    }

    /**
     * @notice Deposit tokens into this contract
     * @param amount | How much to stake
     */
    function stake(uint256 amount)
        external
        updateReward(msg.sender)
        nonReentrant
        moreThanZero(amount)
    {
        console.log('function stake(uint256 amount) external updateReward(msg.sender) nonReentrant moreThanZero(amount):::');
        s_totalSupply += amount;
        console.log('Stake():increase total supply with ', amount, s_totalSupply);
        s_balances[msg.sender] += amount;
        console.log('Stake():s_balances[msg.sender] increase with ', amount, s_balances[msg.sender]);
        emit Staked(msg.sender, amount);
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert TransferFailed();
        }

        console.log('successfully staked (transfered)', amount, ' to ', 'contract');
    }

    /**
     * @notice Withdraw tokens from this contract
     * @param amount | How much to withdraw
     */
    function withdraw(uint256 amount) external updateReward(msg.sender) nonReentrant {
        console.log('function withdraw(uint256 amount) external updateReward(msg.sender) nonReentrant:::');
        s_totalSupply -= amount;
        console.log('withdraw():lower s_totalSupply with', amount);
        s_balances[msg.sender] -= amount;
        console.log('withdraw():lower s_balances[msg.sender] with', amount, s_balances[msg.sender]);
        emit WithdrewStake(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert TransferFailed();
        }
        console.log('successfully withdrew (transfered)', amount, ' to ', msg.sender);
    }

    /**
     * @notice User claims their tokens
     */
    function claimReward() external updateReward(msg.sender) nonReentrant {
        console.log('function claimReward() external updateReward(msg.sender) nonReentrant:::');
        uint256 reward = s_rewards[msg.sender];
        s_rewards[msg.sender] = 0;
        console.log('withdraw():set s_rewards[msg.sender] to 0');
        emit RewardsClaimed(msg.sender, reward);
        bool success = s_rewardsToken.transfer(msg.sender, reward);
        if (!success) {
            revert TransferFailed();
        }
        console.log('successfully claimed (transfered)', reward, ' to ', msg.sender);
    }

    /********************/
    /* Modifiers Functions */
    /********************/
    modifier updateReward(address account) {// runs at stake, withdraw, claimReward
        console.log('modifier updateReward(address account):::');
        console.log(' ---- updateReward start ----');
        s_rewardPerTokenStored = rewardPerToken(); // 1.1
        console.log('s_rewardPerTokenStored', s_rewardPerTokenStored);
        s_lastUpdateTime = block.timestamp;// +1
        console.log('s_lastUpdateTime', s_lastUpdateTime);
        s_rewards[account] = earned(account);
        console.log('s_rewards[account]', s_rewards[account]);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        console.log('s_userRewardPerTokenPaid[account]', s_userRewardPerTokenPaid[account]);
        console.log(' ---- updateReward end ----');
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    /********************/
    /* Getter Functions */
    /********************/
    // Ideally, we'd have getter functions for all our s_ variables we want exposed, and set them all to private.
    // But, for the purpose of this demo, we've left them public for simplicity.

    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }
}
