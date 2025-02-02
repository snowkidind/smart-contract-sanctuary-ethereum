/**
 *Submitted for verification at Etherscan.io on 2022-10-21
*/

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/utils/Strings.sol

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol

// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: contracts/DextoolsSale.sol

pragma solidity 0.8.7;








contract DextoolsSale is ReentrancyGuard, Ownable, AccessControl {
    bytes32 public constant OWNER_ADMIN = keccak256("OWNER_ADMIN");
    bytes32 public constant FACTORY_ADMIN = keccak256("FACTORY_ADMIN");

    using Address for address payable;

    // Whitelist
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private WHITELIST;
    bool public whitelistEnabled = false;

    // Participants
    mapping(address => uint256) public participants;

    // Events
    event SellToken(address indexed recepient, uint tokensSold, uint value);
    event ClaimToken(address indexed recepient, uint tokensClaimed, uint256 date);

    // Basics
    address public crowdsaleToken;
    uint256 public tokenDecimals;
    uint256 public buyPrice;
    uint256 public totalTokens;
    uint256 public minimalGoal;
    uint256 public hardCap;
    uint256 public minBuy;
    uint256 public maxBuy;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    string public projectInfo;

    // Counting
    address payable public fundingAddress;
    uint256 public totalCollected;
    uint256 public totalSold;
    
    // Status
    bool public stopped = false;
    bool public funded = false;

    // Cliff
    uint256 public claimCliffTime = 10 minutes;

    // Vesting
    mapping(address => uint256) public claimableTokens;
    mapping(address => uint256) public claimedTokens;
    bool public vestingEnabled = false;
    uint256 public claimTiming = 30 days;
    uint256[] public vestingClaim = [10000];

    constructor(
        address _token,
        uint256 _buyPrice,  // 1 token = X ETH
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _minAllocation,
        uint256 _maxAllocation,
        uint256 _startDate,
        uint256 _endDate,
        address payable _fundingAddress
    ) {
        require(_fundingAddress != address(0x0), "DextoolsSale: _fundingAddress can not be 0x0 address");
        crowdsaleToken = _token;
        tokenDecimals = IERC20Metadata(_token).decimals();
        buyPrice = _buyPrice;
        totalTokens = _hardcap * (10 ** tokenDecimals) / _buyPrice;
        minimalGoal = _softcap;
        hardCap = _hardcap;
        minBuy = _minAllocation;
        maxBuy = _maxAllocation;
        startTimestamp = _startDate;
        endTimestamp = _endDate;
        fundingAddress = _fundingAddress;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /** Update config and info */
    function updateDates(
        uint256 _startDate,
        uint256 _endDate
    )
        external
        hasntStarted()
    {
        require(hasRole(FACTORY_ADMIN, msg.sender), "DextoolsSale: Restricted to FACTORY_ADMIN role");
        require(_startDate > block.timestamp, "DextoolsSale: _startDate must be future time");
        require(_endDate > block.timestamp, "DextoolsSale: _endDate must be future time");
        require(_endDate > _startDate, "DextoolsSale: _endDate must be major than _startDate");

        startTimestamp = _startDate;
        endTimestamp = _endDate;
    }

    function updateTokenomics(
        uint256 _buyPrice,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _minAllocation,
        uint256 _maxAllocation
    )
        external
        hasntStarted()
    {
        require(hasRole(FACTORY_ADMIN, msg.sender), "DextoolsSale: Restricted to FACTORY_ADMIN role");

        buyPrice = _buyPrice;
        minimalGoal = _softcap;
        hardCap = _hardcap;
        minBuy = _minAllocation;
        maxBuy = _maxAllocation;

        totalTokens = _hardcap * (10 ** tokenDecimals) / _buyPrice;
    }

    function updateProjectInfo(
        string memory _projectInfo
    )
        external
        hasntStarted()
    {
        require(hasRole(FACTORY_ADMIN, msg.sender), "DextoolsSale: Restricted to FACTORY_ADMIN role");

        projectInfo = _projectInfo;
    }

    /** Vesting */
    function setVesting(
        uint256[] memory _vestingClaim,
        uint256 _claimTiming
    )
        external
        hasntStarted()
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");
        require(vestingClaim.length <= 36, "DextoolsSale: vestingClaim length must be max 36");
        
        // Set new vesting
        uint256 vestingTotal = 0;
        for (uint8 i = 0; i < _vestingClaim.length; i++) {
            vestingTotal += _vestingClaim[i];
        }
        
        require(vestingTotal == 10000, "DextoolsSale: vestingClaim percentages sum must be 100%");

        vestingClaim = _vestingClaim;
        claimTiming = _claimTiming;
        vestingEnabled = true;
    }

    function disableVesting() external {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        vestingEnabled = false;
    }

    function updateClaimCliffTime(
        uint256 _claimCliffTime
    )
        external
        hasntStarted()
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        claimCliffTime = _claimCliffTime;
    }

    /** Participating */
    receive() external payable
    {
        require(msg.value >= minBuy, "DextoolsSale: You must send more than the required minimum to participate");
        require(msg.value <= maxBuy, "DextoolsSale: You must send less than the required maximum to participate");
        require(participants[msg.sender] + msg.value <= maxBuy, 
            "DextoolsSale: Sent amount plus previous sent amounts must not exceed the required maximum to participate"
        );

        sell(payable(msg.sender), msg.value);
    }

    function sell(address payable _recepient, uint256 _value) internal
        nonReentrant
        hasBeenStarted()
        hasntStopped()
        whenCrowdsaleAlive()
    {
        if (whitelistEnabled) {
            require(getWhitelistStatus(msg.sender), "DextoolsSale: You are not in the whitelist");
        }

        uint256 newTotalCollected = totalCollected + _value;

        if (hardCap < newTotalCollected) {
            // Refund anything above the hard cap
            uint256 toRefund = newTotalCollected - hardCap;
            uint256 diff = _value - toRefund;
            _recepient.sendValue(toRefund);
            _value = diff;
            newTotalCollected = totalCollected - _value;
        }

        // Token amount per price
        uint256 tokensSold = ((_value * 10000) / buyPrice) * (10 ** tokenDecimals) / 10000;

        // Set how much tokens the user can claim
        claimableTokens[_recepient] = claimableTokens[_recepient] + tokensSold;

        emit SellToken(_recepient, tokensSold, _value);

        participants[_recepient] = participants[_recepient] + _value;

        totalCollected = totalCollected + _value;
        
        totalSold = totalSold + tokensSold;
    }

    /** Claiming */
    function claim() 
        external 
        nonReentrant 
        hasntStopped()
        whenCrowdsaleSuccessful()
        returns (uint256) 
    {
        require(canClaim(), "DextoolsSale: Claim is not yet possible");

        uint256 pending = pendingClaimable(msg.sender);
        claimedTokens[msg.sender] += pending;

        require(pending > 0, "DextoolsSale: Nothing to claim");
        require(IERC20(crowdsaleToken).transfer(msg.sender, pending), "DextoolsSale: Error transfering");

        emit ClaimToken(msg.sender, pending, getTime());

        return pending;
    }

    function getClaimableTokens(address wallet)
        external 
        view
        returns(uint256)
    {
        return claimableTokens[wallet];
    }

    function pendingClaimable(address wallet) public view returns (uint256) {
        require(canClaim(), "DextoolsSale: Claim is not yet possible");

        if (claimedTokens[wallet] == claimableTokens[wallet]) return 0;

        uint256 claimablePercentage = 0;
        if (vestingEnabled) {
            uint256 currentTime = getTime();
            uint256 secondsElapsed = currentTime - (endTimestamp + claimCliffTime);
            uint256 monthsElapsed = secondsElapsed / claimTiming;

            if (monthsElapsed >= vestingClaim.length) {
                monthsElapsed = vestingClaim.length - 1;
            }
            
            for (uint256 index = 0; index <= monthsElapsed; index += 1) {
                claimablePercentage += vestingClaim[index];
            }
        } else {
            claimablePercentage = 10000;
        }

        uint256 claimable = claimableTokens[wallet] * claimablePercentage / 10000;
        require(claimable > claimedTokens[wallet], "DextoolsSale: Nothing pending to claim for now");

        return claimable - claimedTokens[wallet];
    }

    function remainToClaim(address wallet) public view returns (uint256) {
        require(claimableTokens[wallet] >= claimedTokens[wallet], "DextoolsSale: Nothing remains to claim");
        return claimableTokens[wallet] - claimedTokens[wallet];
    }

    /** Helpers */
    function withdraw(
        uint256 _amount
    )
        external
        nonReentrant
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");
        require(_amount <= address(this).balance, "DextoolsSale: Not enough funds");

        fundingAddress.sendValue(_amount);
    }

    function withdrawTokens(
        address _token,
        uint256 _amount
    )
        external
        nonReentrant
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");
        require(_token != crowdsaleToken, "DextoolsSale: Use recoverUnsold()");
        require(_amount <= IERC20(_token).balanceOf(address(this)), "DextoolsSale: Not enough funds");

        IERC20(_token).transfer(fundingAddress, _amount);
    }

    function recoverUnsold()
        external
        nonReentrant
        hasntStopped()
        whenCrowdsaleSuccessful()
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        uint256 unsold = totalTokens - totalSold;
        
        IERC20(crowdsaleToken).transfer(fundingAddress, unsold);
    }

    function fund()
        external
    {
        require(!funded, "DextoolsSale: Already funded");

        IERC20(crowdsaleToken).transferFrom(msg.sender, address(this), totalTokens);
        funded = true;
    }

    // Called to refund user's ETH if the TGE has failed
    function refund()
        external
        nonReentrant
    {
        require(stopped || isFailed(), "DextoolsSale: Not cancelled or failed");
        uint256 amount = participants[msg.sender];

        require(amount > 0, "DextoolsSale: Only once");
        participants[msg.sender] = 0;

        payable(msg.sender).sendValue(amount);
    }

    // Cancels the TGE
    function stop() public hasntStopped()  {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        if (hasStarted()) {
            require(!isFailed(), "DextoolsSale: Sale was failed");
            require(!isSuccessful(), "DextoolsSale: Sale was successful");
        }
        stopped = true;
    }

    /** Getters */
    function getToken()
        external
        view
        returns(address)
    {
        return address(crowdsaleToken);
    }

    function getVestingClaim() public view returns (uint256[] memory)  {
        return vestingClaim;
    }

    function canClaim() public view returns (bool) {
        return block.timestamp > (endTimestamp + claimCliffTime);
    }

    function getTime()
        public
        view
        returns(uint256)
    {
        return block.timestamp;
    }

    function isFailed()
        public
        view
        returns(bool)
    {
        return (
            getTime() >= endTimestamp &&
            totalCollected < minimalGoal
        );
    }

    function hasStarted()
        public
        view
        returns(bool)
    {
        return (
            funded && 
            getTime() >= startTimestamp &&
            getTime() < endTimestamp
        );
    }

    function isActive()
        public
        view
        returns(bool)
    {
        return (
            funded &&
            hasStarted() &&
            totalCollected < hardCap
        );
    }

    function isSuccessful()
        public
        view
        returns(bool)
    {
        return (
            totalCollected >= hardCap ||
            (getTime() >= endTimestamp && totalCollected >= minimalGoal)
        );
    }

    /** Whitelist */
    function editWhitelist(address[] calldata _users, bool _add)
        external
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        if (_add) {
            for (uint i = 0; i < _users.length; i++) {
                WHITELIST.add(_users[i]);
            }
        } else {
            for (uint i = 0; i < _users.length; i++) {
                WHITELIST.remove(_users[i]);
            }
        }
    }

    function enableWhitelist()
        external
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        whitelistEnabled = true;
    }

    function disableWhitelist()
        external
    {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        whitelistEnabled = false;
    }
    
    function getWhitelistStatus(address _user)
        public
        view
    returns (bool)
    {
        return WHITELIST.contains(_user);
    }

    /** Modifiers */
    modifier whenCrowdsaleAlive() {
        require(isActive(), 'DextoolsSale: Sale is not active');
        _;
    }

    modifier whenCrowdsaleSuccessful() {
        require(isSuccessful(), 'DextoolsSale: Crowdsale must be successful');
        _;
    }

    modifier hasntStopped() {
        require(!stopped, 'DextoolsSale: Sale is stopped');
        _;
    }

    modifier hasntStarted() {
        require(!hasStarted(), 'DextoolsSale: Sale is started');
        _;
    }

    modifier hasBeenStarted() {
        require(hasStarted(), 'DextoolsSale: Sale has not started');
        _;
    }
}

// File: contracts/DextoolsFactory.sol

pragma solidity 0.8.7;





contract DextoolsFactory is ReentrancyGuard, Ownable, AccessControl {
    bytes32 public constant OWNER_ADMIN = keccak256("OWNER_ADMIN");
    bytes32 public constant FACTORY_ADMIN = keccak256("FACTORY_ADMIN");

    // Token Address => Sales Address
    mapping(address => address[]) public getSale;
    address[] public allSales;

    event SaleCreated(
        address indexed sale,
        address indexed token,
        uint256 buyPrice,
        uint256 softcap,
        uint256 hardcap,
        uint256 minAllocation,
        uint256 maxAllocation,
        uint256 startDate,
        uint256 endDate
    );

    event SaleDatesUpdated(
        address indexed sale,
        uint256 startDate,
        uint256 endDate
    );

    event SaleProjectInfoUpdated(
        address indexed sale,
        string projectInfo
    );

    event SaleTokenomicsUpdated(
        address indexed sale,
        uint256 buyPrice,
        uint256 softcap,
        uint256 hardcap,
        uint256 minAllocation,
        uint256 maxAllocation
    );

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ADMIN, msg.sender);
    }

    function create(
        address _token,
        uint256 _buyPrice,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _minAllocation,
        uint256 _maxAllocation,
        uint256 _startDate,
        uint256 _endDate,
        address payable _fundingAddress
    ) external returns(address) {
        require(hasRole(OWNER_ADMIN, msg.sender), "DextoolsSale: Restricted to OWNER_ADMIN role");

        DextoolsSale newSale = new DextoolsSale(
            _token,
            _buyPrice,
            _softcap,
            _hardcap,
            _minAllocation,
            _maxAllocation,
            _startDate,
            _endDate,
            _fundingAddress
        );

        getSale[_token].push(address(newSale));
        allSales.push(address(newSale));

        emit SaleCreated(
            address(newSale),
            _token,
            _buyPrice,
            _softcap,
            _hardcap,
            _minAllocation,
            _maxAllocation,
            _startDate,
            _endDate
        );

        DextoolsSale(newSale).grantRole(OWNER_ADMIN, msg.sender);
        DextoolsSale(newSale).grantRole(FACTORY_ADMIN, address(this));

        return address(newSale);
    }

    /** Dates */
    function updateDates(
        address payable saleAddress,
        uint256 _startDate,
        uint256 _endDate
    )
        external
    {
        require(DextoolsSale(saleAddress).hasRole(OWNER_ADMIN, msg.sender), "DextoolsFactory: Restricted to OWNER_ADMIN role on DextoolsSale");

        emit SaleDatesUpdated(saleAddress, _startDate, _endDate);

        DextoolsSale(saleAddress).updateDates(_startDate, _endDate);
    }

    /** Project Info */
    function updateProjectInfo(
        address payable saleAddress,
        string memory _projectInfo
    )
        external
    {
        require(DextoolsSale(saleAddress).hasRole(OWNER_ADMIN, msg.sender), "DextoolsFactory: Restricted to OWNER_ADMIN role on DextoolsSale");

        emit SaleProjectInfoUpdated(saleAddress, _projectInfo);

        DextoolsSale(saleAddress).updateProjectInfo(_projectInfo);
    }
    
    /** Project Info */
    function updateTokenomics(
        address payable saleAddress,
        uint256 _buyPrice,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _minAllocation,
        uint256 _maxAllocation
    )
        external
    {
        require(DextoolsSale(saleAddress).hasRole(OWNER_ADMIN, msg.sender), "DextoolsFactory: Restricted to OWNER_ADMIN role on DextoolsSale");

        emit SaleTokenomicsUpdated(
            saleAddress,
            _buyPrice,
            _softcap,
            _hardcap,
            _minAllocation,
            _maxAllocation
        );

        DextoolsSale(saleAddress).updateTokenomics(
            _buyPrice,
            _softcap,
            _hardcap,
            _minAllocation,
            _maxAllocation
        );
    }

    function grantSaleRole(address payable saleAddress, bytes32 role, address account) external {
        require(DextoolsSale(saleAddress).hasRole(OWNER_ADMIN, msg.sender), "DextoolsFactory: Restricted to OWNER_ADMIN role on DextoolsSale");

        DextoolsSale(saleAddress).grantRole(role, account);
    }
    
}