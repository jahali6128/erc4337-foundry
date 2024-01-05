// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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



contract SimpleAccountTest is Test {
    
    EntryPoint entry_point;
    EntryPointSimulations entry_point_simulations;
    SimpleAccount simple_account;
    SimpleAccountFactory simple_account_factory;
    Greeter greeter;


    event EtherSent(bool _sent, bytes _data);

    function setUp() public {
        entry_point = new EntryPoint();
        entry_point_simulations = new EntryPointSimulations();
        simple_account_factory = new SimpleAccountFactory(entry_point);
        greeter = new Greeter();
    }

    // Ensure simple_account is set to the same address of the entry point contract 
    function test_SameEntryPoint() public {
        simple_account = simple_account_factory.createAccount(address(1), 12345);
        assertEq(address(simple_account.entryPoint()), address(entry_point));
    }

    function test_DepositEntryPoint() public {
         simple_account = simple_account_factory.createAccount(address(1), 12345);

        // Sanity checks - check simple_account is empty
        assertEq(simple_account.getDeposit(), 0);
        // Send some ether to simple_account
        (bool sent, bytes memory data) = address(simple_account).call{value: 1 ether}("");
        require(sent, "Failed to send Ether");
        emit EtherSent(sent, data);

        // Check simple account has recieved the ether
        assertEq(address(simple_account).balance, 1 ether);

        // Check if deposit has gone through
        simple_account.addDeposit{value: 1 ether}();
        assertEq(simple_account.getDeposit(), 1 ether);
    }

    // Deposit ether on behalf of the user using a different account
    function test_DepositFromDiffAddr() public {
        simple_account = simple_account_factory.createAccount(address(1), 12345);
        
        assertEq(simple_account.getDeposit(), 0);
        entry_point.depositTo{value : 1 ether}(address(simple_account));
        assertEq(simple_account.getDeposit(), 1 ether);
    }


    function test_UseropSignature() public {

        (address test_wallet, uint256 key) = makeAddrAndKey("test_wallet");
        // emit log_named_address("Address", test_wallet); 
        // emit log_named_uint("Private Key", key); 

        entry_point_simulations  = new EntryPointSimulations();
        simple_account_factory = new SimpleAccountFactory(entry_point_simulations);

        simple_account = simple_account_factory.createAccount(test_wallet, 12345);
        assertEq(simple_account.owner(), test_wallet);

        UserOperation memory userop;
        userop.sender = address(simple_account);
        userop.nonce = simple_account.getNonce();
        userop.initCode = hex"";
        userop.callData = hex"";
        userop.callGasLimit = 2100000;
        userop.verificationGasLimit = 10000000;
        userop.preVerificationGas = 500000;
        userop.maxFeePerGas = 0;
        userop.maxPriorityFeePerGas = 0;
        userop.paymasterAndData = hex"";

        bytes32 userop_hash = entry_point_simulations.getUserOpHash(userop);
        bytes32 signed_eth_hash = MessageHashUtils.toEthSignedMessageHash(userop_hash);

        // emit log_named_bytes32("userop_hash", userop_hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, signed_eth_hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        userop.signature = signature;
        assertEq(ECDSA.recover(signed_eth_hash, signature), test_wallet);

        IEntryPointSimulations.ValidationResult memory val_result;                                         
        // IEntryPoint.ReturnInfo memory ret_info;

        val_result = entry_point_simulations.simulateValidation(userop);
        IEntryPoint.ReturnInfo memory ret = val_result.returnInfo;
        assertEq(ret.sigFailed, false);
    }


    function test_SimulateValidation() public {
        (address test_wallet, uint256 key) = makeAddrAndKey("test_wallet");

        entry_point_simulations  = new EntryPointSimulations();
        simple_account_factory = new SimpleAccountFactory(entry_point_simulations);

        simple_account = simple_account_factory.createAccount(test_wallet, 12345);

        (bool sent, bytes memory data) = address(simple_account).call{value: 1 ether}("");
        require(sent, "Failed to send Ether");
        emit EtherSent(sent, data);

        // simple_account.addDeposit{value: 1 ether}();

        bytes memory greeter_func = abi.encodeWithSignature("setGreeting(string)", "World!");
        bytes memory userop_calldata = abi.encodeWithSignature("execute(address,uint256,bytes)",
                                                                    address(greeter), 0, greeter_func);

        IEntryPointSimulations.ValidationResult memory val_result;                                         
        // sim_interface.ValidationResult val_result;

        emit log_named_uint("Balance before", address(simple_account).balance);

        UserOperation memory userop;
        userop.sender = address(simple_account);
        userop.nonce = simple_account.getNonce();
        userop.initCode = hex"";
        userop.callData = userop_calldata;
        userop.callGasLimit = 2100000;
        userop.verificationGasLimit = 10000000;
        userop.preVerificationGas = 500000;
        userop.maxFeePerGas = 1;
        userop.maxPriorityFeePerGas = 0;
        userop.paymasterAndData = hex"";
        // userop.signature = hex"fffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c";

        bytes32 userop_hash = entry_point_simulations.getUserOpHash(userop);
        bytes32 signed_eth_hash = MessageHashUtils.toEthSignedMessageHash(userop_hash);

        // emit log_named_bytes32("userop_hash", userop_hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, signed_eth_hash);
        bytes memory signature = abi.encodePacked(r, s, v);
        userop.signature = signature;

        val_result = entry_point_simulations.simulateValidation(userop);
        // console2.log(val_result.returnInfo);
        // entry_point_simulations.simulateHandleOp(userop, address(0), hex"");

        emit log_named_uint("Balance after", address(simple_account).balance);
        emit log_named_uint("Deposit", simple_account.getDeposit());
    }


}