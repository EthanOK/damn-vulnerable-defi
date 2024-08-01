// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {CommonBase} from "forge-std/Base.sol";
import {EIP712, MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract HelpUtils is CommonBase {
    bytes32 public constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function getSignature(uint256 privateKey, bytes32 digest) public pure returns (bytes memory signature) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        (v, r, s) = vm.sign(privateKey, digest);
        signature = abi.encodePacked(r, s, v);
    }

    function getEIP712Digest(address verifyingContract, bytes32 structHash) public view returns (bytes32) {
        (, string memory name, string memory version, uint256 chainId,,,) = EIP712(verifyingContract).eip712Domain();
        bytes32 _domainSeparatorV4 = keccak256(
            abi.encode(_TYPE_HASH, keccak256(bytes(name)), keccak256(bytes(version)), chainId, verifyingContract)
        );
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4, structHash);
    }
}
