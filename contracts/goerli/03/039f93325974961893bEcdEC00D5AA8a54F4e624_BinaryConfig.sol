// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BinaryErrors.sol";
import "../interfaces/binary/IBinaryConfig.sol";

contract BinaryConfig is Ownable, IBinaryConfig {
    uint256 public constant FEE_BASE = 10_000;
    /// @dev Trading fee should be paid when winners claim their rewards, see claim function of Market
    uint256 public tradingFee;
    /// @dev Winners should claim their winning rewards within claim notice period
    uint256 public claimNoticePeriod;
    /// @dev treasury wallet
    address public treasury;

    constructor(
        uint16 tradingFee_,
        uint256 claimNoticePeriod_,
        address treasury_
    ) Ownable() {
        require(tradingFee_ < FEE_BASE, "Too high");
        require(treasury_ != address(0), "Invalid address");
        tradingFee = tradingFee_; // 10% as default
        claimNoticePeriod = claimNoticePeriod_;
        treasury = treasury_;
    }
    
    function setTradingFee(uint256 newTradingFee) external onlyOwner {
        require(newTradingFee < FEE_BASE, "Too high");
        tradingFee = newTradingFee;
    }

    function setClaimNoticePeriod(uint256 newNoticePeriod) external onlyOwner {
        claimNoticePeriod = newNoticePeriod;
    }

    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZERO_ADDRESS();
        treasury = newTreasury;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

// Common Errors
error ZERO_ADDRESS();
error ZERO_AMOUNT();
error INPUT_ARRAY_MISMATCH();

// Config Errors
error TOO_HIGH_FEE();

// Oracle
error INVALID_ROUND(uint256 roundId);
error INVALID_ROUND_TIME(uint256 roundId, uint256 timestamp);
error NOT_ORACLE_ADMIN(address sender);
error NOT_ORACLE_WRITER(address sender);
error ORACLE_ALREADY_ADDED(address market);

// Vault
error NOT_FROM_MARKET(address caller);
error NO_DEPOSIT(address user);
error EXCEED_BALANCE(address user, uint256 amount);
error EXCEED_BETS(address player, uint256 amount);
error EXPIRED_CLAIM(address player);

// Market
error INVALID_TIMEFRAMES();
error INVALID_TIMEFRAME_ID(uint timeframeId);
error POS_ALREADY_CREATED(uint roundId, address account);
error CANNOT_CLAIM(uint roundId, address account);

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IBinaryConfig {
    function FEE_BASE() external view returns (uint256);
    
    function treasury() external view returns (address);

    function tradingFee() external view returns (uint256);

    function claimNoticePeriod() external view returns (uint256);
}