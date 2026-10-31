// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {QFRound} from "../src/QFRound.sol";

interface Vm { function warp(uint256) external; function prank(address) external; function deal(address,uint256) external; }

contract QFRoundTest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    address op = address(1); address alice = address(2); address bob = address(3);
    uint256 constant START = 2_000_000_000; uint256 constant END = 2_000_001_000;
    QFRound q;
    function setUp() public { vm.warp(START - 1); q = new QFRound(op, START, END, keccak256(bytes.concat(keccak256(abi.encode(alice))))); vm.prank(op); q.registerProject(payable(bob), "docs"); vm.deal(op, 10 ether); vm.deal(alice, 10 ether); vm.prank(op); q.fundPool{value: 1 ether}(); }
    function testEligibleContributionUsesSqrtDelta() public { vm.warp(START); vm.prank(alice); q.contribute{value: 1 ether}(0, new bytes32[](0)); uint256 first = q.sumSqrtOf(0); vm.prank(alice); q.contribute{value: 3 ether}(0, new bytes32[](0)); require(q.sumSqrtOf(0) == q.sqrt(4 ether * 1e18) && q.sumSqrtOf(0) > first, "delta"); }
    function testIneligibleAndLateContributionsRevert() public { vm.warp(START); vm.prank(bob); (bool ok,) = address(q).call{value: 1}(abi.encodeCall(q.contribute, (0, new bytes32[](0)))); require(!ok, "ineligible"); vm.warp(END + 1); vm.prank(alice); (ok,) = address(q).call{value: 1}(abi.encodeCall(q.contribute, (0, new bytes32[](0)))); require(!ok, "late"); }
    function testEarlyFinalizeAndDoubleWithdrawalRevert() public { vm.warp(START); vm.prank(alice); q.contribute{value: 1 ether}(0, new bytes32[](0)); (bool ok,) = address(q).call(abi.encodeCall(q.finalizeMatches, ())); require(!ok, "early"); vm.warp(END + 1); q.finalizeMatches(); vm.prank(bob); q.withdraw(0); vm.prank(bob); (ok,) = address(q).call(abi.encodeCall(q.withdraw, (0))); require(!ok, "double"); }
    function testFinalScoreMatchAndRecipientRestriction() public { vm.warp(START); vm.prank(alice); q.contribute{value: 1 ether}(0, new bytes32[](0)); uint256 expected = q.sqrt(1 ether * 1e18); vm.warp(END + 1); q.finalizeMatches(); require(q.totalScore() == expected * expected, "score"); vm.prank(alice); (bool ok,) = address(q).call(abi.encodeCall(q.withdraw, (0))); require(!ok, "only recipient"); vm.prank(bob); q.withdraw(0); require(address(q).balance == 0, "all funds paid"); }
}
