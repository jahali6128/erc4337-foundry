// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";


contract HelloWorldTest is Test {

    function setUp() public {}

    function test_ReadFile() public view {
        string memory json_str = vm.readFile("hello_world.json");
        console2.log(json_str);
    }

    function test_ReadJSON() public view {
        // string memory json_str = vm.readFile("hello_world.json");
        // string memory json = "{ \"abi\": [ ], \"methodIdentifiers\": { \"function1()\": \"abcdabcd\", \"function2()\": \"def0def0\" } } ";
        // bytes memory key = stdJson.parseRaw(json, "abi");
        
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/example.json");
        string memory json = vm.readFile(path);
        string[] memory keys = vm.parseJsonKeys(json, "$");
        // string memory json_value = vm.parseJsonString(json, ".list[1].test");
        
        // console2.log(json_value);

        // string memory json_value = vm.parseJsonString(json, "methodIdentifiers");
        // emit log_named_bytes("json", key);
    }


    function test_WriteJSON() public {
        string memory obj1 = "some key";
        vm.serializeBool(obj1, "boolean", true);
        vm.serializeUint(obj1, "number", uint256(342));

        string memory obj2 = "some other key";
        string memory output = vm.serializeString(obj2, "title", "finally json serialization");

        // IMPORTANT: This works because `serializeString` first tries to interpret `output` as
        //   a stringified JSON object. If the parsing fails, then it treats it as a normal
        //   string instead.
        //   For instance, an `output` equal to '{ "ok": "asd" }' will produce an object, but
        //   an output equal to '"ok": "asd" }' will just produce a normal string.
        string memory finalJson = vm.serializeString(obj1, "object", output);

        vm.writeJson(finalJson, "./example.json");
    }



}