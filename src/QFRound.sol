// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/// @notice A single, permissioned quadratic-funding round with on-chain eligibility.
contract QFRound is ReentrancyGuard {
    address public immutable operator;
    uint256 public immutable roundStart;
    uint256 public immutable roundEnd;
    bytes32 public immutable eligibilityRoot;
    uint256 public pool;
    bool public finalized;
    uint256 public totalScore;
    uint256 public sumMatches;
    uint256 public withdrawals;

    struct Project {
        address payable recipient;
        string metadata;
        uint256 raw;
        uint256 contributors;
        uint256 sumSqrt;
        uint256 score;
        uint256 matchAmount;
        bool withdrawn;
    }

    Project[] public projects;
    mapping(uint256 projectId => mapping(address contributor => uint256 amount)) public contributed;
    mapping(uint256 projectId => mapping(address contributor => bool)) public hasContributed;

    event ProjectRegistered(uint256 indexed id, address recipient, string metadata);
    event PoolFunded(address indexed funder, uint256 amount);
    event Contributed(uint256 indexed projectId, address indexed contributor, uint256 amount);
    event MatchFinalized(uint256 indexed projectId, uint256 score, uint256 matchAmount);
    event Withdrawn(uint256 indexed id, address indexed recipient, uint256 amount);

    modifier onlyOperator() { require(msg.sender == operator, "operator only"); _; }

    constructor(address initialOperator, uint256 start, uint256 end, bytes32 root) {
        require(initialOperator != address(0) && start < end, "invalid terms");
        operator = initialOperator;
        roundStart = start;
        roundEnd = end;
        eligibilityRoot = root;
    }

    function registerProject(address payable recipient, string calldata metadata) external onlyOperator {
        require(block.timestamp <= roundEnd && recipient != address(0), "registration closed");
        projects.push(Project(recipient, metadata, 0, 0, 0, 0, 0, false));
        emit ProjectRegistered(projects.length - 1, recipient, metadata);
    }

    function fundPool() external payable onlyOperator {
        require(block.timestamp <= roundEnd && msg.value != 0, "funding closed");
        pool += msg.value;
        emit PoolFunded(msg.sender, msg.value);
    }

    function contribute(uint256 projectId, bytes32[] calldata proof) external payable {
        require(block.timestamp >= roundStart && block.timestamp <= roundEnd, "round inactive");
        require(msg.value != 0 && projectId < projects.length, "invalid contribution");
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender))));
        require(MerkleProof.verifyCalldata(proof, eligibilityRoot, leaf), "ineligible");

        Project storage project = projects[projectId];
        uint256 oldTotal = contributed[projectId][msg.sender];
        uint256 newTotal = oldTotal + msg.value;
        contributed[projectId][msg.sender] = newTotal;
        if (!hasContributed[projectId][msg.sender]) { hasContributed[projectId][msg.sender] = true; project.contributors += 1; }
        project.raw += msg.value;
        project.sumSqrt += Math.sqrt(newTotal * 1e18) - Math.sqrt(oldTotal * 1e18);
        emit Contributed(projectId, msg.sender, msg.value);
    }

    function finalizeMatches() external {
        require(block.timestamp > roundEnd && !finalized, "not finalizable");
        for (uint256 i; i < projects.length; ++i) {
            uint256 sqrtSum = projects[i].sumSqrt;
            projects[i].score = sqrtSum * sqrtSum;
            totalScore += projects[i].score;
        }
        for (uint256 i; i < projects.length; ++i) {
            uint256 matchAmount = totalScore == 0 ? 0 : pool * projects[i].score / totalScore;
            projects[i].matchAmount = matchAmount;
            sumMatches += matchAmount;
            emit MatchFinalized(i, projects[i].score, matchAmount);
        }
        finalized = true;
    }

    function withdraw(uint256 projectId) external nonReentrant {
        Project storage project = projects[projectId];
        require(finalized && msg.sender == project.recipient && !project.withdrawn, "withdraw denied");
        project.withdrawn = true;
        withdrawals += 1;
        uint256 amount = project.raw + project.matchAmount;
        emit Withdrawn(projectId, project.recipient, amount);
        (bool sent,) = project.recipient.call{value: amount}("");
        require(sent, "transfer failed");
    }

    function reclaimDust() external nonReentrant onlyOperator {
        require(finalized && withdrawals == projects.length, "not settled");
        uint256 amount = pool - sumMatches;
        (bool sent,) = payable(operator).call{value: amount}("");
        require(sent, "transfer failed");
    }

    function verify(bytes32 leaf, bytes32[] calldata proof) external view returns (bool) { return MerkleProof.verifyCalldata(proof, eligibilityRoot, leaf); }
    function sqrt(uint256 value) external pure returns (uint256) { return Math.sqrt(value); }
    function sumSqrtOf(uint256 projectId) external view returns (uint256) { return projects[projectId].sumSqrt; }
    function projectCount() external view returns (uint256) { return projects.length; }
}
