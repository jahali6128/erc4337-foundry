// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "../src/core/EntryPoint.sol";
import {EntryPointSimulations} from "../src/core/EntryPointSimulations.sol";
import {SimpleAccount} from "../src/samples/SimpleAccount.sol";
import {SimpleAccountFactory} from "../src/samples/SimpleAccountFactory.sol";
import {Greeter} from "../src/Greeter.sol";
import {UserOperation} from "../src/interfaces/UserOperation.sol";


contract SimpleAccountScript is Script {

    EntryPoint entry_point;
    EntryPointSimulations entry_point_simulations;
    SimpleAccount simple_account;
    SimpleAccountFactory simple_account_factory;
    Greeter greeter;

    event EtherSent(bool _sent, bytes _data);

    function setUp() public {}

    function run() public {
        
        vm.startBroadcast();

        entry_point = new EntryPoint();
        entry_point_simulations = new EntryPointSimulations();
        simple_account_factory = new SimpleAccountFactory(entry_point);
        greeter = new Greeter();

        simple_account = simple_account_factory.createAccount(address(1), 12345);
        vm.stopBroadcast();

    }
}
