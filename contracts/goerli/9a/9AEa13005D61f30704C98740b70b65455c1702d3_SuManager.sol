// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

// SPDX-License-Identifier: MIT
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
library EnumerableSetUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: BSL 1.1

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./SuAuthenticated.sol";

pragma solidity ^0.8.0;

/**
 * @title SuAccessControl
 * @dev Access control for contracts. SuVaultParameters can be inherited from it.
 */
// TODO: refactor by https://en.wikipedia.org/wiki/Principle_of_least_privilege
contract SuAccessControlSingleton is AccessControlUpgradeable, SuAuthenticated, ISuAccessControl {
    /**
     * @dev Initialize the contract with initial owner to be deployer
     */
    function initialize() public initializer {
        __AccessControl_init();
        __SuAuthenticated_init(address(this));
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function transferOwnership(address newOwner) external {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Ownable: caller is not the owner");

        if (hasRole(MINTER_ROLE, msg.sender)) {
            grantRole(MINTER_ROLE, newOwner);
            revokeRole(MINTER_ROLE, msg.sender);
        }

        if (hasRole(VAULT_ACCESS_ROLE, msg.sender)) {
            grantRole(VAULT_ACCESS_ROLE, newOwner);
            revokeRole(VAULT_ACCESS_ROLE, msg.sender);
        }

        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}

// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "../interfaces/ISuAccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title SuAuthenticated
 * @dev other contracts should inherit to be authenticated
 */
abstract contract SuAuthenticated is Initializable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant VAULT_ACCESS_ROLE = keccak256("VAULT_ACCESS_ROLE");
    bytes32 public constant LIQUIDATION_ACCESS_ROLE = keccak256("LIQUIDATION_ACCESS_ROLE");
    bytes32 private constant DEFAULT_ADMIN_ROLE = 0x00;

    // @dev the address of SuAccessControlSingleton - it should be one for all contract that inherits SuAuthenticated
    ISuAccessControl public ACCESS_CONTROL_SINGLETON;

    // @dev should be passed in constructor
    function __SuAuthenticated_init(address _accessControlSingleton) internal onlyInitializing {
        ACCESS_CONTROL_SINGLETON = ISuAccessControl(_accessControlSingleton);
        // TODO: check that _accessControlSingleton points to ISuAccessControl instance
        // require(ISuAccessControl(_accessControlSingleton).supportsInterface(ISuAccessControl.hasRole.selector), "bad dependency");
    }

    // @dev check DEFAULT_ADMIN_ROLE
    modifier onlyOwner() {
        require(ACCESS_CONTROL_SINGLETON.hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "SuAuth: onlyOwner AUTH_FAILED");
        _;
    }

    // @dev check VAULT_ACCESS_ROLE
    modifier onlyVaultAccess() {
        require(ACCESS_CONTROL_SINGLETON.hasRole(VAULT_ACCESS_ROLE, msg.sender), "SuAuth: onlyVaultAccess AUTH_FAILED");
        _;
    }

    // @dev check VAULT_ACCESS_ROLE
    modifier onlyLiquidationAccess() {
        require(ACCESS_CONTROL_SINGLETON.hasRole(LIQUIDATION_ACCESS_ROLE, msg.sender), "SuAuth: onlyLiquidationAccess AUTH_FAILED");
        _;
    }

    // @dev check MINTER_ROLE
    modifier onlyMinter() {
        require(ACCESS_CONTROL_SINGLETON.hasRole(MINTER_ROLE, msg.sender), "SuAuth: onlyMinter AUTH_FAILED");
        _;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./ISuOracle.sol";

/**
 * @title RewardChefV2
 * @notice fork of MasterChefV2(May-13-2021) https://etherscan.io/address/0xef0881ec094552b2e128cf945ef17a6752b4ec5d#code
 * @dev This contract is based on MVC2, but uses "virtual" balances instead of storing real ERC20 tokens
 * and uses address of this assets instead of pid.
 * Rewards that are distributed have to be deposited using refillReward(uint256 amount, uint64 endBlock)
 **/
interface IRewardChefV2 {
    // @notice Info of each reward pool.
    // `allocPoint` The amount of allocation points assigned to the pool.
    // Also known as the amount of REWARD_TOKEN to distribute per block.
    struct PoolInfo {
        uint128 accSushiPerShare;
        uint64 lastRewardBlock;
        uint64 allocPoint;
        uint256 lpSupply;
    }

    // @notice Info of each user.
    // `amount` token amount the user has provided.
    // `rewardDebt` The amount of rewards entitled to the user.
    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;

        uint256 multiplicator1e18;
        uint256 lockupPeriodSeconds;
        uint256 lockupStartTimestamp;
    }

    struct ILockupPeriod {
        uint256 lockupPeriodSeconds;
        uint256 multiplicator1e18;
    }

    // =======================================EVENTS=============================================
    event VirtualDeposit(address indexed user, address indexed asset, uint256 amount);
    event VirtualWithdraw(address indexed user, address indexed asset, uint256 amount);
    event ResetAmount(address indexed user, address indexed asset, address indexed to, uint256 amount, uint256 lockupPeriodSeconds);
    event Harvest(address indexed user, address indexed asset, uint256 amount);
    event LogPoolAddition(address indexed asset, uint256 allocPoint);
    event LogSetPool(address indexed asset, uint256 allocPoint);
    event LogUpdatePool(address indexed asset, uint64 lastRewardBlock, uint256 lpSupply, uint256 accSushiPerShare);

    // =========================================VARS====================_=========================
    // @dev Total allocation points. Must be the sum of all allocation points in all pools.
    // The good practice, to always keep this variable is equal 1000.
    function totalAllocPoint() external view returns ( uint256 );

    // =======================================REWARDER=============================================
    function REWARD_TOKEN() external view returns ( IERC20Upgradeable );
    function ORACLE() external view returns ( ISuOracle );
    function rewardPerBlock() external view returns ( uint256 );
    function rewardEndBlock() external view returns ( uint256 );

    function refillReward(uint256 amount, uint64 endBlock) external;
    /**
     *  @dev returns total amount of rewards allocated to the all pools on the rage (startBlock, endBlock]
     *      i.e. excluding startBlock but including endBlock
     */
    function rewardsBetweenBlocks(uint256 startBlock, uint256 endBlock) external returns ( uint256 );

    //=======================================LOCKUP LOGIC===========================================
    function getPossibleLockupPeriodsSeconds() external view returns (ILockupPeriod[] memory);
    function setPossibleLockupPeriodsSeconds(uint256 lockupPeriodSeconds, uint256 multiplicator1e18) external;

    //================================CORE REWARD CHEF METHODS======================================
    // @notice Add a new reward pool. Can only be called by the owner.
    // DO NOT add the same LP token more than once.
    // @param allocPoint AP of the new pool.
    // @param _asset Address of the ERC-20 token.
    function add(uint256 allocPoint, address _asset) external;

    // @notice Update the given pool's REWARD_TOKEN allocation point. Can only be called by the owner.
    // @param _asset Address of the ERC-20 token.
    // @param _allocPoint New AP of the pool.
    function set(address _asset, uint256 _allocPoint) external;

    // @notice View function to see pending REWARD_TOKEN on frontend.
    // @param _asset Address of the ERC-20 token.
    // @param _user Address of user.
    // @return pending REWARD_TOKEN reward for a given user.
    function pendingSushi(address _asset, address _user) external view returns ( uint256 );

    // @notice Update reward variables of the given pool.
    // @param asset Asset address
    // @return pool Returns the pool that was updated.
    function updatePool(address asset) external returns ( PoolInfo memory );

    // @notice Update reward variables for all pools. Be careful of gas spending!
    function updateAllPools() external;

    // @notice analogues to MCV2 Deposit method, but can be called only by trusted address
    // that is trusted to honestly calc how many "virtual" tokens have to be allocated for each user.
    function increaseAmount(address asset, address to, uint256 amountEDecimal, uint256 lockupPeriodSeconds) external;

    // @notice Analogues to MVC2 Withdraw method, that can be called only by trusted address
    // that is trusted to honestly calc how many "virtual" tokens have to be allocated for each user.
    function decreaseAmount(address asset, address to, uint256 amountEDecimal) external;

    function decreaseAmountRewardPenalty(address asset, address to, uint256 amountEDecimal) external view returns (uint256);

    // @notice Harvest proceeds for transaction sender to `to`.
    // @param asset Asset address
    // @param to Receiver of REWARD_TOKEN rewards.
    function harvest(address asset, address to, uint256 newLockupPeriodSeconds) external;

    // TODO: check for exploits
    // @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    // @param asset Asset address
    // @param to The address of the user whose information will be cleared
    function resetAmount(address asset, address to) external;

    //================================VIEW METHODS======================================
    function getPoolApr(address asset) external view  returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";

/**
 * @notice Access control for contracts
 * @dev External interface of AccessControl declared to support ERC165 detection.
 **/
interface ISuAccessControl is IAccessControlUpgradeable {
    /**
     * @dev Transfers all roles from caller to owner, and revoke all roles from the caller.
     **/
    function transferOwnership(address newOwner) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @title SuLendingHelpers
 * @notice Abstract contract that should be in SuManager. Here we have all view and ui-helpers methods.
 * Here we don't change any values.
 **/
interface ISuLendingHelpers {
    /* ===================== ERRORS ===================== */

    error InvalidArgs();

    /* ==================== VIEW METHODS ==================== */

    // @notice view function to check if position is liquidatable
    function isLiquidatablePosition(address asset, address owner) external view returns (bool);

    // @notice Returns information about a liquidating position
    // @param asset The address of the main collateral token of a position
    // @param owner The owner of the collateral
    // @return liquidationBlock The block number when the liquidation was triggered
    // @return collateralEDecimal The amount of collateral
    // @return debtWithFeesE18 The amount of borrowed stablecoins with accumulated fee
    function getPositionInfo(address asset, address owner) external view returns (uint256 liquidationBlock, uint256 collateralEDecimal, uint256 debtWithFeesE18);

    // @notice Returns information about a liquidating position
    // @param asset The address of the main collateral token of a position
    // @param owner The owner of the collateral
    // @return liquidationBlock The block number when the liquidation was triggered
    function getLiquidationBlock(address asset, address owner) external view returns (uint256);

    // @notice USD value of collateral of owner
    function getCollateralUsdValueE18(address asset, address owner) external view returns (uint);

    /* ==================== UI HELPERS ==================== */

    // @notice Returns Loan-To-Value in e18
    function getLTVE18(address asset, address owner) external view returns (uint256);

    // @notice Returns Available to Borrow
    // we have invariant: (collateralAmountEDecimal * collateralPriceE18 / 1e18) * initialCollateralRatioE18 <= debtE18
    // Has similar logic like in _ensurePositionCollateralization
    function getAvailableToBorrowE18(address asset, address owner) external view returns (uint256);

    // @notice Returns Available to Withdraw
    // Has similar invariant like in getAvailableToBorrowE18
    function getAvailableToWithdrawE18(address asset, address owner) external view returns (uint256);

    // @notice calculate liquidation price
    // @dev can be used inside of _isLiquidatablePosition
    function liquidationPriceE18(address asset, address owner) external view returns (uint256);

    function liquidationPriceByAmount(
        address asset,
        address owner,
        uint256 additionalCollateralAmount,
        uint256 additionalStablecoinAmount
    ) external view returns (uint256);

    // @notice view function to show utilization ratio
    // the same function can be used inside of _isLiquidatablePosition
    function utilizationRatioE18(address asset, address owner) external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @title SuLendingLiquidation
 * @notice Abstract contract that should be in SuManager.
 * Here we have all support mutable methods that will be used in SuLiquidation.
 **/
interface ISuLendingLiquidation {
    /* ===================== ERRORS ===================== */

    error PositionIsSafe();
    error LiquidationIsTriggered();
    error LiquidationIsNotTriggered();
    error SmallCollateral();

    /* ==================== MUTABLE METHODS ==================== */

    // @notice Marks a position as to be liquidated
    // @param asset The address of the main collateral token of a position
    // @param owner The owner of a position
    /** @dev
    Emits LiquidationTriggered event.
    Sets the current block as liquidationBlock for the position.
    Can be triggered only once for the position.
    */
    function triggerLiquidation(address asset, address owner) external;

    // @notice Liquidates a position, just cut debt and withdraw user collateral without asking USDPro
    // @dev Supports a partial liquidation
    // @param asset The address of the main collateral token of a position
    // @param owner The owner of the collateral
    // @param repayer The person who repaies by debt and transfers stablecoins to the foundation
    // @param stablecoinsToRepaymentE18 The amount of stablecoins which will be burned as a debt repaymention
    // @param assetAmountEDecimal The position's collateral which be recieved by repayer
    function liquidate(
        address asset,
        address owner,
        address repayer,
        uint256 stablecoinsToRepaymentE18,
        uint256 assetAmountEDecimal
    ) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./ISuManagerParameters.sol";
import "./ISuLendingHelpers.sol";
import "./ISuLendingLiquidation.sol";

/**
 * @title SuManager
 * @notice Manager mighty over the vault. Allows users to interact with their CDPs.
 * User does only interact with manager as proxy to the vault.
 **/
interface ISuManager is ISuManagerParameters, ISuLendingHelpers, ISuLendingLiquidation {
    /* ===================== EVENTS ===================== */
    // @notice Even triggered when user deposit collateral
    event Join(address indexed asset, address indexed owner, uint256 main, uint256 stablecoin);

    // @notice Event triggered when user withdraws collateral
    event Exit(address indexed asset, address indexed owner, uint256 main, uint256 stablecoin);

    /* ===================== ERRORS ===================== */
    error Restricted();
    error UselessTransaction();
    error UnsupportedDecimals();
    error UnderCollateralized();

    /* ==================== METHODS ==================== */
    // @notice this function is called by user to deposit collateral and receive stablecoin
    // @dev before calling this function user has to approve the Vault to take his collateral
    function join(address asset, uint256 assetAmountEDecimal, uint256 stablecoinAmountE18, uint256 lockupPeriodSeconds) external;

    // @notice user can pay back the stablecoin and take his collateral
    // instead of passing both assetAmount and stablecoinAmount
    // better user just to pass one of them
    // also pass preferred rate and maybe acceptable diff percent
    // that's the purpose of passing both to protect user from rate fluctuations
    function exit(address asset, uint256 assetAmountEDecimal, uint256 stablecoinAmountE18) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ISuManagerParameters {
    /* ====================== VARS ====================== */
    // @notice When ratio (debt / usdValue) goes below it user can't withdraw or borrow.
    // Should be >= liquidationRatioE18. 1e18 = 100% ratio. Should be less than 1e18.
    // Is used to calculate available to withdraw and borrow.
    // For example, user can borrow <= usdValue * initialCollateralRatio
    function initialCollateralRatioE18 (address asset) external view returns ( uint256 );

    // @notice Ratio when cdp can be liquidated.
    // 1e18 = 100% ratio. Should be less than 1e18.
    // Is used in isLiquidatablePosition(). It's true when debt / usdValue >= liquidationRatio
    function liquidationRatioE18 (address asset) external view returns ( uint256 );

    // @notice The minimum value of collateral in USD which allowed to be left after partial closure
    function minCollateralInUsdE18 ( ) external view returns ( uint256 );

    /* ===================== ERRORS ===================== */
    error BadLiquidationRatioValue();
    error BadInitialCollateralRatioValue();

    /* ==================== METHODS ==================== */
    function setCollateral (
        address asset,
        uint256 stabilityFeeValueE18,
        uint256 initialCollateralRatioValueE18,
        uint256 liquidationRatioValueE18,
        uint256 stablecoinLimitE18,
        uint256 minCollateralInUsdValueE18
    ) external;

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the initial collateral ratio
     * @param asset The address of the main collateral token
     * @param newValueE18 The collateralization ratio (1e18 = 100%)
     **/
    function setInitialCollateralRatioE18 ( address asset, uint256 newValueE18 ) external;

    /**
     * @notice Only manager is able to call this function
     * @dev Sets the liquidation ratio
     * @param asset The address of the main collateral token
     * @param newValueE18 The liquidation ratio (1e18 = 100%).
     **/
    function setLiquidationRatioE18 ( address asset, uint256 newValueE18 ) external;

    /**
     * @notice Only manager is able to call this function
     * @dev Sets a minimum value of collateral in USD which allowed to be left after partial closure
     * @param newValueE18 The minimum value of collateral in USD
     */
    function setMinCollateralInUsdE18 ( uint256 newValueE18 ) external;
}

// SPDX-License-Identifier: UNLICENSED

// solhint-disable compiler-version
pragma solidity >=0.7.6;

interface ISuOracle {
    /**
     * @notice WARNING! Read this description very carefully!
     *      function getUsdPrice1e18(address asset) returns (uint256) that:
     *          basicAmountOfAsset * getUsdPrice1e18(asset) / 1e18 === $$ * 1e18
     *      in other words, it doesn't matter what's the erc20.decimals is,
     *      you just multiply token balance in basic units on value from oracle and get dollar amount multiplied on 1e18.
     *
     * different assets have different deviation threshold (errors)
     *      for wBTC it's <= 0.5%, read more https://data.chain.link/ethereum/mainnet/crypto-usd/btc-usd
     *      for other asset is can be larger based on particular oracle implementation.
     *
     * examples:
     *       market price of btc = $30k,
     *       for 0.1 wBTC the unit256 amount is 0.1 * 1e18
     *       0.1 * 1e18 * (price1e18 / 1e18) == $3000 == uint256(3000*1e18)
     *       => price1e18 = 30000 * 1e18;
     *
     *       market price of usdt = $0.97,
     *       for 1 usdt uint256 = 1 * 1e6
     *       so 1*1e6 * price1e18 / 1e18 == $0.97 == uint256(0.97*1e18)
     *       => 1*1e6 * (price1e18 / 1e18) / (0.97*1e18)   = 1
     *       =>  price1e18 = 0.97 * (1e18/1e6) * 1e18
     *
     *      assume market price of wBTC = $31,503.77, oracle error = $158
     *
     *       case #1: small amount of wBTC
     *           we have 0.0,000,001 wBTC that is worth v = $0.00315 ± $0.00001 = 0.00315*1e18 = 315*1e13 ± 1*1e13
     *           actual balance on the asset b = wBTC.balanceOf() =  0.0000001*1e18 = 1e11
     *           oracle should return or = oracle.getUsdPrice1e18(wBTC) <=>
     *           <=> b*or = v => v/b = 315*1e13 / 1e11 = 315*1e2 ± 1e2
     *           error = or.error * b = 1e2 * 1e11 = 1e13 => 1e13/1e18 usd = 1e-5 = 0.00001 usd
     *
     *       case #2: large amount of wBTC
     *           v = 2,000,000 wBTC = $31,503.77 * 2m ± 158*2m = $63,007,540,000 ± $316,000,000 = 63,007*1e24 ± 316*1e24
     *           for calc convenience we increase error on 0.05 and have v = 63,000*24 ± 300*1e24 = (630 ± 3)*1e26
     *           b = 2*1e6 * 1e18 = 2*1e24
     *           or = v/b = (630 ± 3)*1e26 / 2*1e24 = 315*1e2 ± 1.5*1e2
     *           error = or.error * b = 1.5*100 * 2*1e24 = 3*1e26 = 3*1e8*1e18 = $300,000,000 ~ $316,000,000
     *
     *      assume the market price of USDT = $0.97 ± $0.00485,
     *
     *       case #3: little amount of USDT
     *           v = USDT amount 0.005 = 0.005*(0.97 ± 0.00485) = 0.00485*1e18 ± 0.00002425*1e18 = 485*1e13 ± 3*1e13
     *           we rounded error up on (3000-2425)/2425 ~= +24% for calculation convenience.
     *           b = USDT.balanceOf() = 0.005*1e6 = 5*1e3
     *           b*or = v => or = v/b = (485*1e13 ± 3*1e13) / 5*1e3 = 970*1e9 ± 6*1e9
     *           error = 6*1e9 * 5*1e3 / 1e18 = 30*1e12/1e18 = 3*1e-5 = $0,00005
     *
     *       case #4: lot of USDT
     *           v = we have 100,000,000,000 USDT = $97B = 97*1e9*1e18 ± 0.5*1e9*1e18
     *           b = USDT.balanceOf() = 1e11*1e6 = 1e17
     *           or = v/b = (97*1e9*1e18 ± 0.5*1e9*1e18) / 1e17 = 970*1e9 ± 5*1e9
     *           error = 5*1e9 * 1e17 = 5*1e26 = 0.5 * 1e8*1e18
     *
     * @param asset - address of erc20 token contract
     * @return usdPrice1e18 such that asset.balanceOf() * getUsdPrice1e18(asset) / 1e18 == $$ * 1e18
     **/
    function getUsdPrice1e18(address asset) external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../lending/SuVaultParameters.sol";
import "../interfaces/ISuVaultParameters.sol";
import "../reward/RewardChefV2.sol";

interface ISuVault is ISuVaultParameters {
    /* ===================== EVENTS ===================== */
    // @notice Event triggered when user destroys cdp
    event PositionLiquidated(address asset, address owner, address repayer, uint256 assetAmountEDecimal, uint256 repaymentE18);

    // @notice Event triggered when user liquidate some part of cdp (debt > 0)
    event PositionLiquidatedPartial(address asset, address owner, address repayer, uint256 assetAmountEDecimal, uint256 repaymentE18);

    // @notice Event triggered when user call repay() function
    event PositionRepaid(address repayer, uint256 repaymentE18, uint256 excessAndFeeE18);

    // @notice Event triggered when user didnt withdraw collateral before price goes down
    event LiquidationTriggered(address indexed asset, address indexed owner);

    /* ===================== ERRORS ===================== */
    error LiquidationIsTriggered();
    error Restricted();
    error WithdrawExceeded();
    error WrongDebt();
    error WrongTotalDebt();
    error UselessTransaction();
    error AssetDebtLimit();

    /* ====================== VARS ====================== */
    // @notice how much collateral the users staked == collaterals[asset][user], i.e deposits
    // EDecimal means that this value in asset denomination, i.e. x{human readable value} * 10^{erc20.decimals()}
    function collateralsEDecimal (address asset, address user) external view returns ( uint256 );

    // @notice stablecoin amount
    function debtsE18 (address asset, address user) external view returns ( uint256 );

    // @notice stablecoin amount + fee accumulated before lastUpdate == debtWithFeesE18[asset][user]
    function debtWithFeesE18 (address asset, address user) external view returns ( uint256 );

    // @notice the last time, when every fee before lastUpdates are calculated in the debt.
    // All data such as fees are from lastUpdate only
    function lastUpdate (address asset, address user) external view returns ( uint256 );

    // @notice asset => user => block number
    function liquidationBlock (address asset, address user) external view returns (uint256);

    // @notice current interest that user pay for stabilityFee[asset][user]
    function stabilityFeeE18 (address asset, address user) external view returns ( uint256 );

    // @notice Stats, how much stablecoins were borrowed against particular asset == tokenDebtsE18[asset]
    function tokenDebtsE18 (address asset) external view returns ( uint256 );

    // @notice tokenDebtsE18[asset] + accumulated fee in all CDPs in this asset
    function tokenDebtsWithFeesE18 (address asset) external view returns ( uint256 );

    /* ==================== MUTABLE METHODS ==================== */
    // @notice borrow usdPRO using selected asset.
    // user expected previously to deposit collateral and then being able to take stablecoin
    // user can't create single position with multiple collaterals?
    function borrow ( address asset, address user, uint256 amountE18 ) external;

    // @notice collateral deposit
    function deposit ( address asset, address user, uint256 amountEDecimal, uint256 lockupPeriodSeconds ) external;

    // @notice only destroy debt info
    // @dev onlyVaultAccess, exit -> _repay -> destroy if debt == 0
    function destroy ( address asset, address user ) external;

    // @notice withdraw in case of some protocol errors, users can always get back their tokens
    function emergencyWithdraw ( address asset, address user, uint256 amountEDecimal ) external;

    // @notice liquidate user position, just cut debt and withdraw user collateral without asking USDPro
    function liquidate(
        address asset,
        address owner,
        address recipient,
        uint256 assetAmountEDecimal,
        uint256 stablecoinAmountE18
    ) external;

    // @notice set new RewardChef contract address
    function setRewardChef(address rewardChef) external;

    // @notice Marks a position as to be liquidated
    // @param asset The address of the main collateral token of a position
    // @param positionOwner The owner of a position
    // @dev Sets the current block as liquidationBlock for the position. Can be triggered only once for the position.
    function triggerLiquidation(address asset, address positionOwner) external;

    // @notice Update all main state vars
    // position is not allowed to be modified during liquidation, because when it's launched -
    // liquidators want to be sure they can participate
    // @dev is called, when user borrows more
    function update ( address asset, address user ) external;

    // @notice collateral withdraw
    function withdraw ( address asset, address user, address recipient, uint256 amountEDecimal ) external;

    // @notice Burns a debt repayment and transfers fees to the foundation.
    // @param repayer The person who repaies by debt and transfers stablecoins to the foundation
    // @param stablecoinsToRepaymentE18 The amount of stablecoins which will be burned as a debt repayment
    // @param stablecoinsToFoundationE18 The amount of stablecoins which will be transfered to the foundation(e.g fees)
    function payFeeAndBurn(address repayer, uint256 stablecoinsToRepaymentE18, uint256 stablecoinsToFoundationE18) external;

    /* ==================== VIEW METHODS ==================== */
    // @notice fee is increased with time. Any call of vault.update would calc fee in debt and restart fee timer
    function calculateFeeE18 ( address asset, address user, uint256 amountE18 ) external view returns ( uint256 );

    // @notice total dept is calculated as current debt with added calculated fee, don't use it in practice
    function getTotalDebtE18 ( address asset, address user ) external view returns ( uint256 );
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @title SuVaultParameters
 * @notice SuVaultParameters is Singleton for Access Control, like configuration contract.
 **/
interface ISuVaultParameters {
    /* ====================== VARS ====================== */
    // @notice Stability fee that is used in calculateFeeE18 to see how much user debt increased.
    // It can be different for each collateral
    function protocolStabilityFeeE18 (address asset) external view returns ( uint256 );

    // @notice Limit for each collateral-asset to manage risk profile
    function tokenDebtLimitE18 (address asset) external view returns ( uint256 );

    /* ===================== ERRORS ===================== */
    error ZeroAddress();

    /* ==================== METHODS ==================== */
    // @notice manager is allowed to add new collaterals and modify existing ones
    // @dev I think creating new collaterals and modifying existing ones should be separate functions for security reason
    function setCollateral (address asset, uint256 stabilityFeeValueE18, uint256 stablecoinLimitE18) external;

    // @notice manager is allowed to change foundation that receive fees and etc
    function setFoundation ( address newFoundation ) external;

    // @notice set fee percentage (1e18 = 100%)
    function setStabilityFeeE18 ( address asset, uint256 newValue ) external;

    // @notice debt limit can be changed for any collateral along with liquidation and stability fees
    function setTokenDebtLimitE18 ( address asset, uint256 limit ) external;
}

// SPDX-License-Identifier: BSL 1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../interfaces/ISuLendingHelpers.sol";
import "../interfaces/ISuVault.sol";
import "../interfaces/ISuManager.sol";
import "../interfaces/ISuOracle.sol";

abstract contract SuLendingHelpers is ISuLendingHelpers {
    ISuVault private _VAULT;
    ISuManager private _MANAGER;
    ISuOracle private _ORACLE;

    function __SuLendingHelpers_init(address _suManager, address _suVault, address _suOracle) internal {
        if (_suOracle == address(0)) revert InvalidArgs();

        _MANAGER = ISuManager(_suManager);
        _VAULT = ISuVault(_suVault);
        _ORACLE = ISuOracle(_suOracle);
    }

    /* ==================== VIEW METHODS ==================== */

    function isLiquidatablePosition(address asset, address owner) public view returns (bool) {
        uint256 usdValueE18 = getCollateralUsdValueE18(asset, owner);

        // calculate current debt to be returned
        uint256 debtE18 = _VAULT.getTotalDebtE18(asset, owner);

        if (debtE18 == 0) return false;
        // make sure its not under collaterazied
        return debtE18 * 1e18 / usdValueE18 >= _MANAGER.liquidationRatioE18(asset);
    }

    function getPositionInfo(address asset, address owner) external view returns (
        uint256 liquidationBlock,
        uint256 collateralEDecimal,
        uint256 debtWithFeesE18
    ) {
        liquidationBlock = _VAULT.liquidationBlock(asset, owner);
        collateralEDecimal = _VAULT.collateralsEDecimal(asset, owner);
        debtWithFeesE18 = _VAULT.debtWithFeesE18(asset, owner);
    }

    function getLiquidationBlock(address asset, address owner) external view returns (uint256) {
        return _VAULT.liquidationBlock(asset, owner);
    }

    function getCollateralUsdValueE18(address asset, address owner) public view returns (uint) {
        uint256 assetAmountEDecimal = _VAULT.collateralsEDecimal(asset, owner);

        return _ORACLE.getUsdPrice1e18(asset) * assetAmountEDecimal / 1e18;
    }

    /* ====================== UI HELPERS ====================== */

    function getLTVE18(address asset, address owner) external view returns (uint256) {
        uint256 usdValueE18 = getCollateralUsdValueE18(asset, owner);
        if (usdValueE18 == 0) return 0;

        uint256 debtWithFeesE18 = _VAULT.debtWithFeesE18(asset, owner);

        return debtWithFeesE18 * 1e18 / usdValueE18;
    }

    function getAvailableToBorrowE18(address asset, address owner) external view returns (uint256) {
        uint256 usdValueE18 = getCollateralUsdValueE18(asset, owner);
        uint256 usdLimitE18 = usdValueE18 * _MANAGER.initialCollateralRatioE18(asset) / 1e18;

        uint256 totalDebtWithFeeE18 = _VAULT.getTotalDebtE18(asset, owner);

        if (usdLimitE18 <= totalDebtWithFeeE18) return 0;

        return usdLimitE18 - totalDebtWithFeeE18;
    }

    function getAvailableToWithdrawE18(address asset, address owner) external view returns (uint256) {
        uint256 collateralAmountEDecimal = _VAULT.collateralsEDecimal(asset, owner);
        uint256 collateralPriceE18 = _ORACLE.getUsdPrice1e18(asset);
        if (collateralPriceE18 == 0) return 0;
        uint256 debtWithFeesE18 = _VAULT.debtWithFeesE18(asset, owner);

        uint256 minCollateralAmountEDecimal = debtWithFeesE18 * (10 ** IERC20Metadata(asset).decimals()) * 1e18 / (collateralPriceE18 * _MANAGER.initialCollateralRatioE18(asset));

        return collateralAmountEDecimal - minCollateralAmountEDecimal;
    }

    function liquidationPriceE18(address asset, address owner) external view returns (uint256) {
        uint256 debtE18 = _VAULT.getTotalDebtE18(asset, owner);
        if (debtE18 == 0) return type(uint256).max;

        uint256 collateralLiqPriceE18 = debtE18 * 1e18 / _MANAGER.liquidationRatioE18(asset);

        return collateralLiqPriceE18 * 1e18 / _VAULT.collateralsEDecimal(asset, owner) / 10 ** (18 - IERC20Metadata(asset).decimals());
    }

    function liquidationPriceByAmount(
        address asset,
        address owner,
        uint256 additionalCollateralAmount,
        uint256 additionalStablecoinAmount
    ) external view returns (uint256) {
        uint256 debtE18 = _VAULT.getTotalDebtE18(asset, owner) + additionalStablecoinAmount;
        if (debtE18 == 0) return type(uint256).max;

        uint256 collateralLiqPriceE18 = debtE18 * 1e18 / _MANAGER.liquidationRatioE18(asset);
        uint256 collaterals = _VAULT.collateralsEDecimal(asset, owner) + additionalCollateralAmount;

        return collateralLiqPriceE18 * 1e18 / collaterals / 10 ** (18 - IERC20Metadata(asset).decimals());
    }

    function utilizationRatioE18(address asset, address owner) public view returns (uint256) {
        uint256 debtE18 = _VAULT.getTotalDebtE18(asset, owner);
        if (debtE18 == 0) return 0;

        uint256 usdValueE18 = getCollateralUsdValueE18(asset, owner);

        return debtE18 * 1e18 / usdValueE18;
    }
}

// SPDX-License-Identifier: BSL 1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interfaces/ISuLendingLiquidation.sol";
import "../interfaces/ISuVault.sol";
import "../interfaces/ISuManager.sol";

import "../access-control/SuAuthenticated.sol";

abstract contract SuLendingLiquidation is ReentrancyGuardUpgradeable, SuAuthenticated, ISuLendingLiquidation {
    ISuVault private _vault;
    ISuManager private _manager;

    function __SuLendingLiquidation_init(address _suManager, address _suVault) internal onlyInitializing {
        __ReentrancyGuard_init();

        _manager = ISuManager(_suManager);
        _vault = ISuVault(_suVault);
    }

    function triggerLiquidation(address asset, address owner) external {
        if (_vault.liquidationBlock(asset, owner) > 0) revert LiquidationIsTriggered();
        if (!_manager.isLiquidatablePosition(asset, owner)) revert PositionIsSafe();

        // summarize debt with accumulated fees
        _vault.update(asset, owner);

        // then vault will trigger liquidation and auction begins
        _vault.triggerLiquidation(asset, owner);
    }

    function liquidate(
        address asset,
        address owner,
        address repayer,
        uint256 stablecoinsToRepaymentE18,
        uint256 assetAmountEDecimal
    ) public nonReentrant onlyLiquidationAccess {
        if (_vault.liquidationBlock(asset, owner) == 0) revert LiquidationIsNotTriggered();

        _vault.liquidate(asset, owner, repayer, assetAmountEDecimal, stablecoinsToRepaymentE18);

        // not allowed to left some dust after partial closure the position
        _ensureMinCollateralThreshold(asset, msg.sender);
    }

    // after partial closure should be made sure it is not left too little amount of collateral
    function _ensureMinCollateralThreshold(address asset, address owner) internal view {
        uint256 usdValueE18 = _manager.getCollateralUsdValueE18(asset, owner);

        if (usdValueE18 > 0 && usdValueE18 <= _manager.minCollateralInUsdE18()) revert SmallCollateral();
    }
}

// SPDX-License-Identifier: BSL 1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../interfaces/ISuVault.sol";
import "../interfaces/ISuManager.sol";
import "./SuManagerParameters.sol";
import "./SuLendingHelpers.sol";
import "./SuLendingLiquidation.sol";

contract SuManager is ReentrancyGuardUpgradeable, SuManagerParameters, SuLendingLiquidation, SuLendingHelpers, ISuManager {
    ISuVault public vault;

    function initialize(address _vault, address _suOracle) public initializer {
        __ReentrancyGuard_init();
        __SuManagerParameters_init(_vault);
        __SuLendingLiquidation_init(address(this), _vault);
        __SuLendingHelpers_init(address(this), _vault, _suOracle);

        vault = ISuVault(_vault);
    }

    // wrapper ether only, no native
    receive() external payable {
        revert Restricted();
    }

    function join(address asset, uint256 assetAmountEDecimal, uint256 stablecoinAmountE18, uint256 lockupPeriodSeconds) public nonReentrant {
        if (stablecoinAmountE18 == 0 && assetAmountEDecimal == 0) revert UselessTransaction();
        if (IERC20Metadata(asset).decimals() > 18) revert UnsupportedDecimals();

        if (stablecoinAmountE18 == 0) {
            vault.deposit(asset, msg.sender, assetAmountEDecimal, lockupPeriodSeconds);
        } else {
            if (assetAmountEDecimal != 0) {
                vault.deposit(asset, msg.sender, assetAmountEDecimal, lockupPeriodSeconds);
            }

            vault.borrow(asset, msg.sender, stablecoinAmountE18);

            _ensurePositionCollateralization(asset, msg.sender);
        }

        // not allowed to left some dust after partial closure the position
        _ensureMinCollateralThreshold(asset, msg.sender);

        emit Join(asset, msg.sender, assetAmountEDecimal, stablecoinAmountE18);
    }

    function exit(address asset, uint256 assetAmountEDecimal, uint256 stablecoinAmountE18) public nonReentrant {
        if (vault.liquidationBlock(asset, msg.sender) > 0) revert LiquidationIsTriggered();

        // not to pay more stablecoin than debt
        uint256 debtWithFeesE18 = vault.debtWithFeesE18(asset, msg.sender);
        if (stablecoinAmountE18 > debtWithFeesE18) { stablecoinAmountE18 = debtWithFeesE18; }

        // calculate and charge fee
        uint256 feeE18 = vault.calculateFeeE18(asset, msg.sender, stablecoinAmountE18);

        vault.liquidate(asset, msg.sender, msg.sender, assetAmountEDecimal, stablecoinAmountE18);

        // not allowed to left some dust after partial closure the position
        _ensureMinCollateralThreshold(asset, msg.sender);

        vault.payFeeAndBurn(msg.sender, stablecoinAmountE18, feeE18);

        if (vault.debtWithFeesE18(asset, msg.sender) > 0) {
            // TODO: check that withdrawals lead to update
            vault.update(asset, msg.sender);

            // dont need to check this after full repayment
            _ensurePositionCollateralization(asset, msg.sender);
        }

        emit Exit(asset, msg.sender, assetAmountEDecimal, stablecoinAmountE18);
    }

    // after partial repayment should be made sure its still collateralized enough
    function _ensurePositionCollateralization(address asset, address owner) internal view {
        // calculate value in usd from collateral position
        uint256 usdValueE18 = getCollateralUsdValueE18(asset, owner);

        // multiply value in usd to the collateral ratio, then divide by 1e18
        uint256 usdLimitE18 = usdValueE18 * initialCollateralRatioE18[asset] / 1e18;

        // make sure calculated allowed limit is higher than the actual debt
        if (vault.getTotalDebtE18(asset, owner) > usdLimitE18) revert UnderCollateralized();
    }
}

// SPDX-License-Identifier: BSL 1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity ^0.8.0;

import "./SuVaultParameters.sol";
import "../access-control/SuAccessControlSingleton.sol";
import "../interfaces/ISuManagerParameters.sol";

abstract contract SuManagerParameters is SuAuthenticated, ISuManagerParameters {
    mapping(address => uint256) public initialCollateralRatioE18;
    mapping(address => uint256) public liquidationRatioE18;
    uint256 public minCollateralInUsdE18;

    SuVaultParameters public vaultParameters;

    function __SuManagerParameters_init(address _vaultParameters) internal onlyInitializing {
        __SuAuthenticated_init(address(SuAuthenticated(_vaultParameters).ACCESS_CONTROL_SINGLETON()));

        vaultParameters = SuVaultParameters(_vaultParameters);
        minCollateralInUsdE18 = 5 * 1e18;
    }

    function setCollateral(
        address asset,
        uint256 stabilityFeeValueE18,
        uint256 initialCollateralRatioValueE18,
        uint256 liquidationRatioValueE18,
        uint256 stablecoinLimitE18,
        uint256 minCollateralInUsdValueE18
    ) external onlyOwner {
        vaultParameters.setCollateral(asset, stabilityFeeValueE18, stablecoinLimitE18);
        setInitialCollateralRatioE18(asset, initialCollateralRatioValueE18);
        setLiquidationRatioE18(asset, liquidationRatioValueE18);
        setMinCollateralInUsdE18(minCollateralInUsdValueE18);
    }

    function setInitialCollateralRatioE18(address asset, uint256 newValueE18) public onlyOwner {
        if (newValueE18 == 0 || newValueE18 > 1e18) revert BadInitialCollateralRatioValue();
        initialCollateralRatioE18[asset] = newValueE18;
    }

    function setLiquidationRatioE18(address asset, uint256 newValueE18) public onlyOwner {
        if (newValueE18 == 0 || newValueE18 < initialCollateralRatioE18[asset]) revert BadLiquidationRatioValue();
        liquidationRatioE18[asset] = newValueE18;
    }

    function setMinCollateralInUsdE18(uint256 newValueE18) public onlyOwner {
        minCollateralInUsdE18 = newValueE18;
    }
}

// SPDX-License-Identifier: BSL 1.1

import "../access-control/SuAccessControlSingleton.sol";
import "../access-control/SuAuthenticated.sol";
import "../interfaces/ISuVaultParameters.sol";

pragma solidity ^0.8.0;

abstract contract SuVaultParameters is SuAuthenticated, ISuVaultParameters {
    mapping(address => uint256) public protocolStabilityFeeE18;
    mapping(address => uint256) public tokenDebtLimitE18;
    address public foundation;
    address public vault;

    // how can vault address be known at this moment?
    // Precult based on CREATE spec
    // can be created another function to set vault address once deployed?
    // Yes, possibly with some logic change
    function __SuVaultParameters_init(
        address _authControl,
        address payable _vault,
        address _foundation
    )  internal onlyInitializing {
        if (_vault == address(0) || _foundation == address(0)) revert ZeroAddress();

        __SuAuthenticated_init(_authControl);
        vault = _vault;
        foundation = _foundation;
    }

    function setFoundation(address newFoundation) external onlyOwner {
        if (newFoundation == address(0)) revert ZeroAddress();
        foundation = newFoundation;
    }

    function setCollateral(address asset, uint256 stabilityFeeValueE18, uint256 stablecoinLimitE18) external onlyOwner {
        // stability fee should be validated in range, what is stability fee should be described here?
        setStabilityFeeE18(asset, stabilityFeeValueE18);
        // why debt limit for collateral is necessary? to manage risks in case of collateral failure?
        setTokenDebtLimitE18(asset, stablecoinLimitE18);
    }

    function setStabilityFeeE18(address asset, uint256 newValue) public onlyOwner {
        protocolStabilityFeeE18[asset] = newValue;
    }

    function setTokenDebtLimitE18(address asset, uint256 limit) public onlyOwner {
        tokenDebtLimitE18[asset] = limit;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "../access-control/SuAuthenticated.sol";
import "../interfaces/IRewardChefV2.sol";
import "../interfaces/ISuOracle.sol";

contract RewardChefV2 is IRewardChefV2, SuAuthenticated {
    using SafeCastUpgradeable for uint256;
    using SafeCastUpgradeable for uint128;
    using SafeCastUpgradeable for uint64;
    using SafeCastUpgradeable for int256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    // SuDAO: instead of pool Ids (pid) we use address of the asset directly.
    //        Also, there aren't just LPs but regular assets as well
    // @notice Info of each MCV2 pool. PoolInfo memory pool = poolInfo[_pid]
    //    PoolInfo[] public poolInfo;
    mapping(address => PoolInfo) public poolInfo;

    // @notice Info of each user that stakes tokens. userInfo[_asset][_user]
    mapping(address => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint;

    // @notice Address of the LP token for each MCV2 pool.
    //    IERC20Upgradeable[] public lpTokens;
    // @notice Set of reward-able assets
    EnumerableSetUpgradeable.AddressSet private assetSet;
    uint256 private constant ACC_REWARD_TOKEN_PRECISION = 1e12; // TODO*: make it 1e18? check values overflow

    // ==========================REWARDER================================
    // @notice Address of REWARD_TOKEN contract.
    IERC20Upgradeable public REWARD_TOKEN;
    ISuOracle public ORACLE;
    uint256 public rewardPerBlock;
    uint256 public rewardEndBlock;

    function refillReward(uint256 amount, uint64 endBlock) public onlyOwner {
        require(endBlock > block.number, "EndBlock should be greater than current block");
        // TODO: gas optimization
        updateAllPools();

        REWARD_TOKEN.safeTransferFrom(msg.sender, address(this), amount);
        uint256 rewardLeftAmount;
        // if there are active rewards leftovers
        if (rewardEndBlock > 0) {
            // if we call refillReward before old endBlock ends
            if (block.number < rewardEndBlock) {
                rewardLeftAmount = rewardPerBlock * (rewardEndBlock - block.number);
            } else {
                // if we start the new reward interval that has nothing in common with the old noe
                rewardLeftAmount = 0;
            }
        }
        rewardPerBlock = (rewardLeftAmount + amount) / (endBlock - block.number);
        rewardEndBlock = endBlock;
    }

    function rewardsBetweenBlocks(uint256 startBlock, uint256 endBlock) public view returns (uint256) {
        // if all rewards were allocation before our range - then answer is 0
        if (rewardEndBlock <= startBlock) {
            return 0;
        } else {
            // if rewards allocates on the whole range, than just calc rectangle area
            if (endBlock < rewardEndBlock) {
                return (endBlock - startBlock) * rewardPerBlock;
            } else {
                // other-vice, rewards end its allocation during our rage, so we have to calc only until rewardEndBlock
                return (rewardEndBlock - startBlock) * rewardPerBlock;
            }
        }
    }

    /* ==========================LOCKUP LOGIC========================================= */
    mapping(uint256 => uint256) public multiplicator1e18ForLockupPeriod;
    EnumerableSetUpgradeable.UintSet private possibleLockupPeriodsSeconds;

    function getPossibleLockupPeriodsSeconds() external view returns (ILockupPeriod[] memory) {
        uint256[] memory periods = possibleLockupPeriodsSeconds.values();
        uint256 len = periods.length;
        ILockupPeriod[] memory lockupPeriods = new ILockupPeriod[](len);
        for (uint256 i = 0; i < len; i++) {
            lockupPeriods[i] = ILockupPeriod({
            lockupPeriodSeconds : periods[i],
            multiplicator1e18 : multiplicator1e18ForLockupPeriod[periods[i]]
            });
        }
        return lockupPeriods;
    }

    function setPossibleLockupPeriodsSeconds(uint256 lockupPeriodSeconds, uint256 multiplicator1e18) external onlyOwner {
        require(lockupPeriodSeconds != 0, "Lockup period equils zero seconds");
        multiplicator1e18ForLockupPeriod[lockupPeriodSeconds] = multiplicator1e18;
        if (multiplicator1e18 == 0) {
            possibleLockupPeriodsSeconds.remove(lockupPeriodSeconds);
        } else {
            possibleLockupPeriodsSeconds.add(lockupPeriodSeconds);
        }
    }
    /* =================================================================== */

    // @param _rewardToken The REWARD_TOKEN token contract address.
    function initialize(address _authControl, IERC20Upgradeable _rewardToken, ISuOracle _oracle) public initializer {
        __SuAuthenticated_init(_authControl);

        REWARD_TOKEN = _rewardToken;
        ORACLE = _oracle;
    }

    function add(uint256 allocPoint, address _asset) public onlyOwner {
        // check for possible duplications
        require(poolInfo[_asset].lastRewardBlock == 0, "Pool already exist");

        uint256 lastRewardBlock = block.number;
        totalAllocPoint = totalAllocPoint + allocPoint;
        //        lpTokens.push(_lpToken);
        assetSet.add(_asset);

        poolInfo[_asset] = PoolInfo({
        allocPoint : allocPoint.toUint64(),
        lastRewardBlock : lastRewardBlock.toUint64(),
        accSushiPerShare : 0,
        lpSupply : 0
        });

        emit LogPoolAddition(_asset, allocPoint);
    }

    function set(address _asset, uint256 _allocPoint) public onlyOwner {
        require(poolInfo[_asset].lastRewardBlock != 0, "Pool doesn't exist");
        // TODO: why was it in legal in MVC2 to call this function without mandatory update method?
        updatePool(_asset);

        uint64 oldAllocPoint = poolInfo[_asset].allocPoint;
        totalAllocPoint = totalAllocPoint - oldAllocPoint + _allocPoint;
        poolInfo[_asset].allocPoint = _allocPoint.toUint64();
        if (_allocPoint == 0) {
            // we don't need to call updatePool(_asset) again
            // because the result of the second time call in the same block doesn't change anything
            assetSet.remove(_asset);
        } else if (oldAllocPoint == 0) {
            // when pool exists, but asset was removed from assetSet
            assetSet.add(_asset);
        }
        emit LogSetPool(_asset, _allocPoint);
    }

    function pendingSushi(address _asset, address _user) public view returns (uint256 pending) {
        PoolInfo memory pool = poolInfo[_asset];
        UserInfo memory user = userInfo[_asset][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        // we don't have real balances anymore, so instead of
        //        uint256 lpSupply = lpTokens[_pid].balanceOf(address(this));
        // we use virtual total balance
        uint256 lpSupply = poolInfo[_asset].lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0 && totalAllocPoint != 0) {
            // how much reward were minted since last update pool.lastRewardBlock
            uint256 totalSushiReward = rewardsBetweenBlocks(pool.lastRewardBlock, block.number);
            uint256 poolSushiReward = totalSushiReward * pool.allocPoint / totalAllocPoint;
            // account it into share value
            accSushiPerShare = accSushiPerShare + (poolSushiReward * ACC_REWARD_TOKEN_PRECISION / lpSupply);
        }
        pending = ((user.amount * accSushiPerShare / ACC_REWARD_TOKEN_PRECISION).toInt256() - user.rewardDebt).toUint256();
    }

    function updatePool(address asset) public returns (PoolInfo memory pool) {
        pool = poolInfo[asset];
        if (block.number > pool.lastRewardBlock) {
            // uint256 lpSupply = lpTokens[pid].balanceOf(address(this));
            uint256 lpSupply = pool.lpSupply;
            if (lpSupply > 0 && pool.allocPoint > 0) {
                // calc how much rewards are minted since pool.lastRewardBlock for the pool
                uint256 totalSushiReward = rewardsBetweenBlocks(pool.lastRewardBlock, block.number);
                uint256 poolSushiReward = totalSushiReward * pool.allocPoint / totalAllocPoint;
                pool.accSushiPerShare = pool.accSushiPerShare + (poolSushiReward * ACC_REWARD_TOKEN_PRECISION / lpSupply).toUint128();
            }
            pool.lastRewardBlock = block.number.toUint64();
            poolInfo[asset] = pool;
            emit LogUpdatePool(asset, pool.lastRewardBlock, lpSupply, pool.accSushiPerShare);
        }
    }

    function updateAllPools() public {
        address[] memory assets = assetSet.values();
        uint256 len = assets.length;
        for (uint256 i = 0; i < len; i++) {
            updatePool(assets[i]);
        }
    }

    function increaseAmount(address asset, address to, uint256 amountEDecimal, uint256 lockupPeriodSeconds) public onlyOwner {
        PoolInfo memory pool = updatePool(asset);
        UserInfo storage user = userInfo[asset][to];

        if (user.lockupPeriodSeconds == 0) {// it means there's no deposit yet
            user.multiplicator1e18 = multiplicator1e18ForLockupPeriod[lockupPeriodSeconds];
            user.lockupPeriodSeconds = lockupPeriodSeconds;
            user.lockupStartTimestamp = block.timestamp;
        } else {
            require(user.lockupPeriodSeconds == lockupPeriodSeconds, "Existing deposit has different lockup");
        }

        require(user.multiplicator1e18 != 0, "User multiplicator equils zero");

        // Effects
        // user.amount = user.amount + amountEDecimal;
        uint256 additionalAmount = amountEDecimal * user.multiplicator1e18 / 1e18;
        user.amount = user.amount + additionalAmount;
        user.rewardDebt = user.rewardDebt + (additionalAmount * pool.accSushiPerShare / ACC_REWARD_TOKEN_PRECISION).toInt256();

        // we don't need, since the balances are virtual
        // lpToken[pid].safeTransferFrom(msg.sender, address(this), amount);
        // but we need to calc total supply of virtual tokens
        pool.lpSupply = pool.lpSupply + additionalAmount;
        poolInfo[asset] = pool;

        emit VirtualDeposit(to, asset, additionalAmount);
    }

    function decreaseAmount(address asset, address to, uint256 amountEDecimal) public onlyOwner {
        PoolInfo memory pool = updatePool(asset);
        UserInfo storage user = userInfo[asset][to];

        require(user.multiplicator1e18 != 0, "User multiplicator equils zero");

        // how much penalty?
        uint256 penalty = 0;
        if (block.timestamp < user.lockupStartTimestamp + user.lockupPeriodSeconds) {
           // if we decreasing before time-lock is over
            penalty = decreaseAmountRewardPenalty(asset, to, amountEDecimal);
        }

        // Effects
        uint256 subtractAmount = amountEDecimal * user.multiplicator1e18 / 1e18;
        user.rewardDebt = user.rewardDebt - (subtractAmount * pool.accSushiPerShare / ACC_REWARD_TOKEN_PRECISION).toInt256() + penalty.toInt256();
        user.amount = user.amount - subtractAmount;

        if (user.amount == 0 && user.rewardDebt == 0) {
            // Reset lockupPeriod
            user.lockupStartTimestamp = block.timestamp;
            user.lockupPeriodSeconds = 0;
            user.multiplicator1e18 = 0;
        }

        // lpTokens[pid].safeTransfer(to, amount);
        pool.lpSupply = pool.lpSupply - subtractAmount;
        poolInfo[asset] = pool;

        emit VirtualWithdraw(to, asset, subtractAmount);
    }

    function decreaseAmountRewardPenalty(address asset, address to, uint256 amountEDecimal) public view returns (uint256) {
        UserInfo memory user = userInfo[asset][to];

        if (user.multiplicator1e18 == 0) {
            return 0;
        }

        uint256 subtractAmount = amountEDecimal * user.multiplicator1e18 / 1e18;

        uint256 pending = pendingSushi(asset, to);
        return pending * subtractAmount / user.amount;
    }

    function harvest(address asset, address to, uint256 newLockupPeriodSeconds) public {
        PoolInfo memory pool = updatePool(asset);
        UserInfo storage user = userInfo[asset][msg.sender];

        require(user.lockupStartTimestamp + user.lockupPeriodSeconds <= block.timestamp, "Can't harvest before lockup is over");
        require(user.multiplicator1e18 != 0, "User multiplicator equils zero");

        int256 accumulatedSushi = (user.amount * pool.accSushiPerShare / ACC_REWARD_TOKEN_PRECISION).toInt256();
        uint256 _pendingSushi = (accumulatedSushi - user.rewardDebt).toUint256();

        // Effects
        user.rewardDebt = accumulatedSushi;
        // accumulatedSushi = user.rewardDebt + _pendingSushi;

        // Interactions
        if (_pendingSushi > 0) {
            REWARD_TOKEN.safeTransfer(to, _pendingSushi);
        }

        // Reset lockupPeriod
        user.lockupStartTimestamp = block.timestamp;
        // it's possible to remove code duplicates by using signed amount, but for simplicity I'll leave as it is
        uint256 newMultiplicator1e18 = multiplicator1e18ForLockupPeriod[newLockupPeriodSeconds];
        require(newMultiplicator1e18 != 0, "New multiplicator equils zero");
        if (user.multiplicator1e18 < newMultiplicator1e18) {
            // since multiplicator increases, we need to increase amount
            uint256 additionalAmount = user.amount * newMultiplicator1e18 / user.multiplicator1e18 - user.amount;

            user.amount = user.amount + additionalAmount;
            user.rewardDebt = user.rewardDebt + (additionalAmount * pool.accSushiPerShare / ACC_REWARD_TOKEN_PRECISION).toInt256();
        } else if (user.multiplicator1e18 > newMultiplicator1e18) {
            uint256 subtractAmount = user.amount - user.amount * newMultiplicator1e18 / user.multiplicator1e18;

            user.rewardDebt = user.rewardDebt - (subtractAmount * pool.accSushiPerShare / ACC_REWARD_TOKEN_PRECISION).toInt256();
            user.amount = user.amount - subtractAmount;
        }
        user.multiplicator1e18 = newMultiplicator1e18;

        emit Harvest(msg.sender, asset, _pendingSushi);
    }

    function resetAmount(address asset, address to) public {
        PoolInfo storage pool = poolInfo[asset];
        UserInfo storage user = userInfo[asset][msg.sender];

        uint256 userAmount = user.amount;
        uint256 userLockupPeriodSeconds = user.lockupPeriodSeconds;

        pool.lpSupply = pool.lpSupply - userAmount;
        poolInfo[asset] = pool;
        user.amount = 0;
        user.rewardDebt = 0;

        // Reset lockupPeriod
        user.lockupStartTimestamp = block.timestamp;
        user.lockupPeriodSeconds = 0;
        user.multiplicator1e18 = 0;

        emit ResetAmount(msg.sender, asset, to, userAmount, userLockupPeriodSeconds);
    }

    /* ================================VIEW METHODS====================================== */

    function getPoolApr(address asset) public view returns (uint256) {
        require(poolInfo[asset].lpSupply != 0, "RewardChef: Pool doesn't have liquidity");
        require(totalAllocPoint != 0, "RewardChef: Total allocation point is 0");
        require(rewardEndBlock > block.number, "RewardChef: Vesting is already finished");

        uint256 rewardPerBlockForPool = rewardPerBlock * poolInfo[asset].allocPoint / totalAllocPoint;
        uint256 rewardTokenPrice = ORACLE.getUsdPrice1e18(address(REWARD_TOKEN));
        uint256 usdRewardYearForPool = rewardPerBlockForPool * 4 * 60 * 24 * 366 * rewardTokenPrice;
        // TODO: fix decimals and unify oracle answer
        uint256 usdValuePool = ORACLE.getUsdPrice1e18(asset) * poolInfo[asset].lpSupply / 10 ** IERC20Metadata(asset).decimals();
        return usdRewardYearForPool / usdValuePool;
    }
}