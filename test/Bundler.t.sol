// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {EntryPoint} from "../src/core/EntryPoint.sol";
import {EntryPointSimulations} from "../src/core/EntryPointSimulations.sol";
import {SimpleAccount} from "../src/samples/SimpleAccount.sol";
import {SimpleAccountFactory} from "../src/samples/SimpleAccountFactory.sol";
import {Greeter} from "../src/Greeter.sol";
import {UserOperation} from "../src/interfaces/UserOperation.sol";
import "../src/interfaces/IEntryPoint.sol";
import "../src/interfaces/IEntryPointSimulations.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {VerifyingPaymaster} from "../src/samples/VerifyingPaymaster.sol";


contract BundlerTest is Test {

    EntryPoint entry_point;
    EntryPointSimulations entry_point_simulations;
    SimpleAccount simple_account;
    SimpleAccountFactory simple_account_factory;
    Greeter greeter;
    VerifyingPaymaster paymaster;


    event EtherSent(bool _sent, bytes _data);

    function setUp() public {
        entry_point = new EntryPoint();
        entry_point_simulations = new EntryPointSimulations();
        simple_account_factory = new SimpleAccountFactory(entry_point);
        greeter = new Greeter();
        // paymaster = new VerifyingPaymaster(entry_point, msg.sender);
    }


    function test_Bundler() public {

        (address test_wallet, uint256 key) = makeAddrAndKey("test_wallet");
        simple_account_factory = new SimpleAccountFactory(entry_point_simulations);

        simple_account = simple_account_factory.createAccount(test_wallet, 12345);
        assertEq(simple_account.owner(), test_wallet); 

        emit log_named_address("entrypoint_simul", address(entry_point_simulations));
        emit log_named_address("factory", address(simple_account_factory));
        emit log_named_address("account", address(simple_account));

        UserOperation memory userop;
        userop.sender = address(simple_account);
        userop.nonce = simple_account.getNonce();
        userop.initCode = hex"";
        userop.callData = hex"";
        userop.callGasLimit = 35000;
        userop.verificationGasLimit = 70000;
        userop.preVerificationGas = 21000;
        userop.maxFeePerGas = 0;
        userop.maxPriorityFeePerGas = 0;
        userop.paymasterAndData = hex"";
    
        bytes32 userop_hash = entry_point_simulations.getUserOpHash(userop);
        bytes32 signed_eth_hash = MessageHashUtils.toEthSignedMessageHash(userop_hash);   

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, signed_eth_hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        userop.signature = signature;
        assertEq(ECDSA.recover(signed_eth_hash, signature), test_wallet);

        entry_point_simulations.simulateValidation(userop);
    }



}