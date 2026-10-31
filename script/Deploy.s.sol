// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {QFRound} from "../src/QFRound.sol";
interface Vm {function envUint(string calldata)external returns(uint);function envAddress(string calldata)external returns(address);function envBytes32(string calldata)external returns(bytes32);function startBroadcast(uint)external;function stopBroadcast()external;}
contract Deploy {Vm constant vm=Vm(address(uint160(uint(keccak256("hevm cheat code")))));function run()external returns(QFRound q){vm.startBroadcast(vm.envUint("PRIVATE_KEY"));q=new QFRound(vm.envAddress("OPERATOR"),vm.envUint("ROUND_START"),vm.envUint("ROUND_END"),vm.envBytes32("ELIGIBILITY_ROOT"));vm.stopBroadcast();}}
