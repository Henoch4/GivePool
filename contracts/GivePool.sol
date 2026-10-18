// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title GivePool — donation pools with milestone payouts.
/// Organizer posts a cause with a beneficiary and milestone tranches.
/// Anyone funds any time. A designated reviewer approves milestones IN ORDER,
/// each paying the beneficiary its tranche. Leftover dust completes to the
/// beneficiary. Empty pools can be cancelled. Grant-committee native.
contract GivePool is ReentrancyGuard {
    struct Pool {
        address organizer;
        address beneficiary;
        address reviewer;
        string causeURI;
        uint256[] milestones;
        uint256 releasedCount;
        uint256 totalFunded;
        bool closed;
    }

    Pool[] private _pools;

    event PoolCreated(uint256 indexed id, address indexed organizer, address indexed beneficiary, uint256 milestones);
    event Funded(uint256 indexed id, address indexed from, uint256 amount);
    event MilestoneApproved(uint256 indexed id, uint256 indexed idx, uint256 amount);
    event Completed(uint256 indexed id, uint256 remainder);
    event PoolCancelled(uint256 indexed id);

    function create(string calldata causeURI, address beneficiary, uint256[] calldata milestones, address reviewer) external returns (uint256) {
        require(bytes(causeURI).length > 0, "Empty cause");
        require(beneficiary != address(0), "Zero beneficiary");
        require(milestones.length > 0, "No milestones");
        for (uint256 i = 0; i < milestones.length; i++) require(milestones[i] > 0, "Zero milestone");
        _pools.push();
        Pool storage p = _pools[_pools.length - 1];
        p.organizer = msg.sender;
        p.beneficiary = beneficiary;
        p.reviewer = reviewer == address(0) ? msg.sender : reviewer;
        p.causeURI = causeURI;
        for (uint256 i = 0; i < milestones.length; i++) p.milestones.push(milestones[i]);
        uint256 id = _pools.length - 1;
        emit PoolCreated(id, msg.sender, beneficiary, milestones.length);
        return id;
    }

    function fund(uint256 id) external payable nonReentrant {
        Pool storage p = _pools[id];
        require(!p.closed, "Closed");
        require(msg.value > 0, "Bad amount");
        p.totalFunded += msg.value;
        emit Funded(id, msg.sender, msg.value);
    }

    function releasedTotal(uint256 id) public view returns (uint256) {
        Pool storage p = _pools[id];
        uint256 sum;
        for (uint256 i = 0; i < p.releasedCount; i++) sum += p.milestones[i];
        return sum;
    }

    function approveMilestone(uint256 id) external nonReentrant {
        Pool storage p = _pools[id];
        require(msg.sender == p.reviewer, "Not reviewer");
        require(!p.closed, "Closed");
        require(p.releasedCount < p.milestones.length, "All released");
        uint256 amount = p.milestones[p.releasedCount];
        require(address(this).balance >= amount, "Underfunded");
        p.releasedCount++;
        (bool ok, ) = p.beneficiary.call{value: amount}("");
        require(ok, "Pay failed");
        emit MilestoneApproved(id, p.releasedCount - 1, amount);
    }

    function complete(uint256 id) external nonReentrant {
        Pool storage p = _pools[id];
        require(!p.closed, "Closed");
        require(p.releasedCount == p.milestones.length, "Milestones pending");
        p.closed = true;
        uint256 rest = address(this).balance;
        if (rest > 0) {
            (bool ok, ) = p.beneficiary.call{value: rest}("");
            require(ok, "Pay failed");
        }
        emit Completed(id, rest);
    }

    function cancel(uint256 id) external nonReentrant {
        Pool storage p = _pools[id];
        require(msg.sender == p.organizer, "Not organizer");
        require(!p.closed, "Closed");
        require(p.totalFunded == 0, "Has funds");
        p.closed = true;
        emit PoolCancelled(id);
    }

    function totalPools() external view returns (uint256) {
        return _pools.length;
    }

    function getPool(uint256 id)
        external
        view
        returns (address organizer, address beneficiary, address reviewer, string memory causeURI, uint256 milestoneCount, uint256 releasedCount, uint256 totalFunded, bool closed)
    {
        Pool storage p = _pools[id];
        return (p.organizer, p.beneficiary, p.reviewer, p.causeURI, p.milestones.length, p.releasedCount, p.totalFunded, p.closed);
    }

    function milestone(uint256 id, uint256 idx) external view returns (uint256) {
        return _pools[id].milestones[idx];
    }
}
