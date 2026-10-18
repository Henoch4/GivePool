// @openzeppelin/contracts/utils/StorageSlot.sol
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/StorageSlot.sol)
// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

// @openzeppelin/contracts/utils/ReentrancyGuard.sol
// OpenZeppelin Contracts (last updated v5.5.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * IMPORTANT: Deprecated. This storage-based reentrancy guard will be removed and replaced
 * by the {ReentrancyGuardTransient} variant in v6.0.
 *
 * @custom:stateless
 */
abstract contract ReentrancyGuard {
    using StorageSlot for bytes32;

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANCY_GUARD_STORAGE =
        0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    /**
     * @dev A `view` only version of {nonReentrant}. Use to block view functions
     * from being called, preventing reading from inconsistent contract state.
     *
     * CAUTION: This is a "view" modifier and does not change the reentrancy
     * status. Use it only on view functions. For payable or non-payable functions,
     * use the standard {nonReentrant} modifier instead.
     */
    modifier nonReentrantView() {
        _nonReentrantBeforeView();
        _;
    }

    function _nonReentrantBeforeView() private view {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        _nonReentrantBeforeView();

        // Any calls to nonReentrant after this point will fail
        _reentrancyGuardStorageSlot().getUint256Slot().value = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _reentrancyGuardStorageSlot().getUint256Slot().value = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _reentrancyGuardStorageSlot().getUint256Slot().value == ENTERED;
    }

    function _reentrancyGuardStorageSlot() internal pure virtual returns (bytes32) {
        return REENTRANCY_GUARD_STORAGE;
    }
}

// GivePool.sol
pragma solidity ^0.8.20;


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

