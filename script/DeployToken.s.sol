// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/Token.sol";

contract DeployToken is Script {
    function run() public {
        vm.broadcast();
        MyToken token = new MyToken(msg.sender, 5);
        console.log("Token deployed at:", address(token));
    }
}
