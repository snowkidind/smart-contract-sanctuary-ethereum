// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./Ownable.sol";

interface USDC {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract Bridge is Ownable {

    USDC USDCAddress;
    address SweepAddress;
    uint Balance;
    uint SweepBalance;

    constructor(USDC _USDCAddress, address _SweepAddress, uint _Balance, uint _MaxTokens) {
        USDCAddress = _USDCAddress;
        SweepAddress = _SweepAddress;
        Balance = _Balance;
        SweepBalance = 0;
        USDCAddress.approve(address(this), _MaxTokens); 
    }

    event Deposit(address _Sender, uint Amount);
    event LowBalance();

    function setBalance(uint _Balance) external onlyOwner {
        Balance = _Balance;
    }

    function setSweepAddress(address _SweepAddress) external onlyOwner {
        SweepAddress = _SweepAddress;
    }

    function ownerSweep() external onlyOwner {
        USDCAddress.transfer(address(_owner), SweepBalance);
        SweepBalance = 0;
    }

    function depositSweep() internal {
        USDCAddress.transfer(address(_owner), SweepBalance);
        SweepBalance = 0;
    }

    function deposit(uint _Deposit) external {
        require(Balance > _Deposit, "Deposit Failed");
        bool success = USDCAddress.transferFrom(msg.sender, address(this), _Deposit);
        require(success, "Deposit Failed");
        uint _OldSweepBalance = SweepBalance;
        SweepBalance = _OldSweepBalance + _Deposit;
        emit Deposit(msg.sender, _Deposit);
        uint _OldBalance = Balance;
        Balance = _OldBalance - _Deposit;
        if (Balance == 0) {
            emit LowBalance();
        }
    }
    
    function depositWithSweep(uint _Deposit) external {
        require(Balance >= _Deposit, "Deposit Failed");
        bool success = USDCAddress.transferFrom(msg.sender, address(this), _Deposit);
        require(success, "Deposit Failed");
        uint _OldSweepBalance = SweepBalance;
        SweepBalance = _OldSweepBalance + _Deposit;
        emit Deposit(msg.sender, _Deposit);
        uint _OldBalance = Balance;
        Balance = _OldBalance - _Deposit;
        if (Balance == 0) {
            emit LowBalance();
            depositSweep();
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
    address _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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