// SPDX-License-Identifier: GPL-3.0 AND GPL-3.0-only AND LGPL-3.0-only AND MIT

pragma solidity >=0.8.0;

contract Greeter {

    string public greeting;

    constructor()  {
        greeting = "Hello";
    }

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }

    function greet() view public returns (string memory) {
        return greeting;
    }
}

