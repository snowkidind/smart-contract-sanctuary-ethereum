// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {OperatorFilterer} from "./OperatorFilterer.sol";
import {CANONICAL_CORI_SUBSCRIPTION} from "./lib/Constants.sol";
/**
 * @title  DefaultOperatorFilterer
 * @notice Inherits from OperatorFilterer and automatically subscribes to the default OpenSea subscription.
 * @dev    Please note that if your token contract does not provide an owner with EIP-173, it must provide
 *         administration methods on the contract itself to interact with the registry otherwise the subscription
 *         will be locked to the options set during construction.
 */

abstract contract DefaultOperatorFilterer is OperatorFilterer {
    /// @dev The constructor that is called when the contract is being deployed.
    constructor() OperatorFilterer(CANONICAL_CORI_SUBSCRIPTION, true) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IOperatorFilterRegistry {
    /**
     * @notice Returns true if operator is not filtered for a given token, either by address or codeHash. Also returns
     *         true if supplied registrant address is not registered.
     */
    function isOperatorAllowed(address registrant, address operator) external view returns (bool);

    /**
     * @notice Registers an address with the registry. May be called by address itself or by EIP-173 owner.
     */
    function register(address registrant) external;

    /**
     * @notice Registers an address with the registry and "subscribes" to another address's filtered operators and codeHashes.
     */
    function registerAndSubscribe(address registrant, address subscription) external;

    /**
     * @notice Registers an address with the registry and copies the filtered operators and codeHashes from another
     *         address without subscribing.
     */
    function registerAndCopyEntries(address registrant, address registrantToCopy) external;

    /**
     * @notice Unregisters an address with the registry and removes its subscription. May be called by address itself or by EIP-173 owner.
     *         Note that this does not remove any filtered addresses or codeHashes.
     *         Also note that any subscriptions to this registrant will still be active and follow the existing filtered addresses and codehashes.
     */
    function unregister(address addr) external;

    /**
     * @notice Update an operator address for a registered address - when filtered is true, the operator is filtered.
     */
    function updateOperator(address registrant, address operator, bool filtered) external;

    /**
     * @notice Update multiple operators for a registered address - when filtered is true, the operators will be filtered. Reverts on duplicates.
     */
    function updateOperators(address registrant, address[] calldata operators, bool filtered) external;

    /**
     * @notice Update a codeHash for a registered address - when filtered is true, the codeHash is filtered.
     */
    function updateCodeHash(address registrant, bytes32 codehash, bool filtered) external;

    /**
     * @notice Update multiple codeHashes for a registered address - when filtered is true, the codeHashes will be filtered. Reverts on duplicates.
     */
    function updateCodeHashes(address registrant, bytes32[] calldata codeHashes, bool filtered) external;

    /**
     * @notice Subscribe an address to another registrant's filtered operators and codeHashes. Will remove previous
     *         subscription if present.
     *         Note that accounts with subscriptions may go on to subscribe to other accounts - in this case,
     *         subscriptions will not be forwarded. Instead the former subscription's existing entries will still be
     *         used.
     */
    function subscribe(address registrant, address registrantToSubscribe) external;

    /**
     * @notice Unsubscribe an address from its current subscribed registrant, and optionally copy its filtered operators and codeHashes.
     */
    function unsubscribe(address registrant, bool copyExistingEntries) external;

    /**
     * @notice Get the subscription address of a given registrant, if any.
     */
    function subscriptionOf(address addr) external returns (address registrant);

    /**
     * @notice Get the set of addresses subscribed to a given registrant.
     *         Note that order is not guaranteed as updates are made.
     */
    function subscribers(address registrant) external returns (address[] memory);

    /**
     * @notice Get the subscriber at a given index in the set of addresses subscribed to a given registrant.
     *         Note that order is not guaranteed as updates are made.
     */
    function subscriberAt(address registrant, uint256 index) external returns (address);

    /**
     * @notice Copy filtered operators and codeHashes from a different registrantToCopy to addr.
     */
    function copyEntriesOf(address registrant, address registrantToCopy) external;

    /**
     * @notice Returns true if operator is filtered by a given address or its subscription.
     */
    function isOperatorFiltered(address registrant, address operator) external returns (bool);

    /**
     * @notice Returns true if the hash of an address's code is filtered by a given address or its subscription.
     */
    function isCodeHashOfFiltered(address registrant, address operatorWithCode) external returns (bool);

    /**
     * @notice Returns true if a codeHash is filtered by a given address or its subscription.
     */
    function isCodeHashFiltered(address registrant, bytes32 codeHash) external returns (bool);

    /**
     * @notice Returns a list of filtered operators for a given address or its subscription.
     */
    function filteredOperators(address addr) external returns (address[] memory);

    /**
     * @notice Returns the set of filtered codeHashes for a given address or its subscription.
     *         Note that order is not guaranteed as updates are made.
     */
    function filteredCodeHashes(address addr) external returns (bytes32[] memory);

    /**
     * @notice Returns the filtered operator at the given index of the set of filtered operators for a given address or
     *         its subscription.
     *         Note that order is not guaranteed as updates are made.
     */
    function filteredOperatorAt(address registrant, uint256 index) external returns (address);

    /**
     * @notice Returns the filtered codeHash at the given index of the list of filtered codeHashes for a given address or
     *         its subscription.
     *         Note that order is not guaranteed as updates are made.
     */
    function filteredCodeHashAt(address registrant, uint256 index) external returns (bytes32);

    /**
     * @notice Returns true if an address has registered
     */
    function isRegistered(address addr) external returns (bool);

    /**
     * @dev Convenience method to compute the code hash of an arbitrary contract
     */
    function codeHashOf(address addr) external returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOperatorFilterRegistry} from "./IOperatorFilterRegistry.sol";
import {CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS} from "./lib/Constants.sol";
/**
 * @title  OperatorFilterer
 * @notice Abstract contract whose constructor automatically registers and optionally subscribes to or copies another
 *         registrant's entries in the OperatorFilterRegistry.
 * @dev    This smart contract is meant to be inherited by token contracts so they can use the following:
 *         - `onlyAllowedOperator` modifier for `transferFrom` and `safeTransferFrom` methods.
 *         - `onlyAllowedOperatorApproval` modifier for `approve` and `setApprovalForAll` methods.
 *         Please note that if your token contract does not provide an owner with EIP-173, it must provide
 *         administration methods on the contract itself to interact with the registry otherwise the subscription
 *         will be locked to the options set during construction.
 */

abstract contract OperatorFilterer {
    /// @dev Emitted when an operator is not allowed.
    error OperatorNotAllowed(address operator);

    IOperatorFilterRegistry public constant OPERATOR_FILTER_REGISTRY =
        IOperatorFilterRegistry(CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS);

    /// @dev The constructor that is called when the contract is being deployed.
    constructor(address subscriptionOrRegistrantToCopy, bool subscribe) {
        // If an inheriting token contract is deployed to a network without the registry deployed, the modifier
        // will not revert, but the contract will need to be registered with the registry once it is deployed in
        // order for the modifier to filter addresses.
        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {
            if (subscribe) {
                OPERATOR_FILTER_REGISTRY.registerAndSubscribe(address(this), subscriptionOrRegistrantToCopy);
            } else {
                if (subscriptionOrRegistrantToCopy != address(0)) {
                    OPERATOR_FILTER_REGISTRY.registerAndCopyEntries(address(this), subscriptionOrRegistrantToCopy);
                } else {
                    OPERATOR_FILTER_REGISTRY.register(address(this));
                }
            }
        }
    }

    /**
     * @dev A helper function to check if an operator is allowed.
     */
    modifier onlyAllowedOperator(address from) virtual {
        // Allow spending tokens from addresses with balance
        // Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred
        // from an EOA.
        if (from != msg.sender) {
            _checkFilterOperator(msg.sender);
        }
        _;
    }

    /**
     * @dev A helper function to check if an operator approval is allowed.
     */
    modifier onlyAllowedOperatorApproval(address operator) virtual {
        _checkFilterOperator(operator);
        _;
    }

    /**
     * @dev A helper function to check if an operator is allowed.
     */
    function _checkFilterOperator(address operator) internal view virtual {
        // Check registry code length to facilitate testing in environments without a deployed registry.
        if (address(OPERATOR_FILTER_REGISTRY).code.length > 0) {
            // under normal circumstances, this function will revert rather than return false, but inheriting contracts
            // may specify their own OperatorFilterRegistry implementations, which may behave differently
            if (!OPERATOR_FILTER_REGISTRY.isOperatorAllowed(address(this), operator)) {
                revert OperatorNotAllowed(operator);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

address constant CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS = 0x000000000000AAeB6D7670E522A718067333cd4E;
address constant CANONICAL_CORI_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;

// SPDX-License-Identifier: Unlicense
// Creator: 0xYeety/YEETY.eth - Co-Founder/CTO, Virtue Labs

pragma solidity ^0.8.17;

enum HeartColor {
    Red,
    Blue,
    Green,
    Yellow,
    Orange,
    Purple,
    Black,
    White,
    Length
}

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import "lib/openzeppelin-contracts/contracts/utils/Address.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "./HeartColors.sol";

contract IH is Ownable, ERC165, DefaultOperatorFilterer {
    using Address for address;
    using Strings for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error InviteeInviteError(
        bool noDuplicateInvites,
        bool senderInvited,
        bool withinInviteLimit
    );
    error PuzzleInviteError(
        bool puzzleSolved,
        bool arrayLengthsMatch,
        bool withinInviteLimit,
        bool ownColorNotUsed,
        bool validColorsUsed,
        bool noDuplicateInvites,
        bool noSelfInvite,
        bool noDuplicateColors
    );
    error PuzzleSolveError(
        bool notYetSolved,
        bool hasCrudeBorneEggs,
        bool puzzleIsSet,
        bool correctPuzzleSolution,
        bool validColor
    );
    error InviteMintError(
        bool mintStatusOpen,
        bool isInvited,
        bool mintNotYetUsed,
        bool fiveInvitesGiven,
        bool correctMsgValue
    );
    error PuzzleMintError(
        bool authorizedToMint,
        bool mintNotYetUsed,
        bool fiveInvitesGiven
    );

    CrudeBorneEggs public cbEggs;
    PuzzleProto public puzzle;
    address public ACTIVE_HEARTS_ADDRESS;

    struct ClaimInfo {
        address inviter;
        uint48 auxData;
        uint48 inviteDepth;
    }

    mapping(address => ClaimInfo) private _inviteeData;
    mapping(address => ClaimInfo) private _solverData;
    mapping(address => uint256) private _freeActivations;

    uint256 private _hcNonce;

    uint256 public mintPrice;

    string private _name;
    string private _symbol;

    string public collectionDescription;
    string public collectionImg;
    string public externalLink;

    string public imageBase;
    string public imagePostfix;

    address public STORAGE_LAYER_ADDRESS;
    address public BURN_REWARDS_ADDRESS;
    address public POOL_ADDRESS_1;
    address public POOL_ADDRESS_2;
    uint256 public p_addr_2_bp;


    uint256 private secondsPerMonth = 2629800;

    ImageDataGetter public imageDataGetter;
    mapping(uint256 => uint256) private _imageMode;

    mapping(uint256 => string) private _colorToString;

    modifier onlyStorage() {
        _isStorageContract();
        _;
    }

    function _isStorageContract() internal view virtual {
        require(msg.sender == STORAGE_LAYER_ADDRESS, "nsl");
    }

    enum MintStatus {
        OnlyOwner,
        Open,
        Paused,
        Closed
    }

    MintStatus public mintStatus = MintStatus.OnlyOwner;

    constructor(
        address cbAddy_,
        uint256 mintPrice_,
        string memory name_,
        string memory symbol_,
        string memory description_,
        string memory image_,
        string memory link_,
        address storageLayerAddress_,
        address puzzleAddress_
    ) {
        cbEggs = CrudeBorneEggs(cbAddy_);
        mintPrice = mintPrice_;
        _name = name_;
        _symbol = symbol_;
        collectionDescription = description_;
        collectionImg = image_;
        externalLink = link_;
        STORAGE_LAYER_ADDRESS = storageLayerAddress_;
        puzzle = PuzzleProto(puzzleAddress_);

        _colorToString[0] = "Red";
        _colorToString[1] = "Blue";
        _colorToString[2] = "Green";
        _colorToString[3] = "Yellow";
        _colorToString[4] = "Orange";
        _colorToString[5] = "Purple";
        _colorToString[6] = "Black";
        _colorToString[7] = "White";
    }

    function setMintStatus(MintStatus newMintStatus) public onlyOwner {
        require(newMintStatus != MintStatus.OnlyOwner, "ms");
        require(mintStatus != MintStatus.Closed);
        mintStatus = newMintStatus;
    }

    /**
     * @dev Produces a random heart color
    **/
    function _randHeartColor() private view returns (HeartColor, uint256) {
        uint256 rand = uint256(
            keccak256(
                abi.encode(
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - (((_hcNonce>>128)%256) + 1)),
                    address(this),
                    _hcNonce%(1<<128)
                )
            )
        );

        return (HeartColor(rand%(uint8(HeartColor.Length))), rand);
    }

    /**
     * @dev Produces a random heart color
    **/
    function _randHeartColors(uint256 howMany) private view returns (HeartColor[] memory, uint256) {
        require(howMany > 0 && howMany <= 5, "hm");
        uint256 rand = uint256(
            keccak256(
                abi.encode(
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - (((_hcNonce>>128)%256) + 1)),
                    address(this),
                    _hcNonce%(1<<128)
                )
            )
        );

        HeartColor[] memory toReturn = new HeartColor[](howMany);
        for (uint256 i = 0; i < howMany; i++) {
            toReturn[i] = HeartColor((rand>>(i*10))%(uint8(HeartColor.Length)));
        }

        return (toReturn, rand);
    }

    /**
     * @dev Returns whether an address has been invited to mint
    **/
    function invited(address addr) public view returns (bool) {
        return (_inviteeData[addr].auxData%2 == 1);
    }

    /**
     * @dev Returns the color that an address was invited to mint for
     *   - Bit-shifted to occupy bits 1-3
    **/
    function invitedColor(address addr) public view returns (HeartColor) {
//        return HeartColor(uint8((_inviteeData[invitee]>>5)%8));
        return HeartColor((_inviteeData[addr].auxData>>1)%8);
    }

    /**
     * @dev Returns whether an address has already used its invite in order to mint
     *   - Bit-shifted to occupy bit 4
    **/
    function inviteMintUsed(address addr) public view returns (bool) {
        return ((_inviteeData[addr].auxData>>4)%2 == 1);
    }

    /**
     * @dev Returns how many invites an address has given to other addresses
     *   - Bit-shifted to occupy bits 5-7
    **/
    function inviteeInvitesGiven(address addr) public view returns (uint256) {
        return ((_inviteeData[addr].auxData>>5)%8);
    }

    function inviterOf(address addr) public view returns (address) {
        return _inviteeData[addr].inviter;
    }

    function inviteDepthOf(address addr) public view returns (uint256) {
        return uint256(_inviteeData[addr].inviteDepth);
    }

    /**
     * @dev Returns whether an address has solved the puzzle with an egg
    **/
    function puzzleSolved(address addr) public view returns (bool) {
//        return ((_solverData[addr]%2) == 1);
        return ((_solverData[addr].auxData%2) == 1);
    }

    /**
     * @dev Returns which color egg was designated by a puzzle solution
     *   - Bit-shifted to occupy bits 1-3
    **/
    function puzzleColor(address addr) public view returns (HeartColor) {
        return HeartColor((_solverData[addr].auxData>>1)%8);
    }

    /**
     * @dev Returns whether an address has already used its puzzle solution to mint
     *   - Bit-shifted to occupy bit 4
    **/
    function puzzleMintUsed(address addr) public view returns (bool) {
        return (((_solverData[addr].auxData>>4)%2) == 1);
    }

    /**
     * @dev Returns how many invites a puzzle solver has given to other addresses
     *   - Bit-shifted to occupy bits 5-7
    **/
    function puzzleInvitesGiven(address addr) public view returns (uint256) {
        return ((_solverData[addr].auxData>>5)%8);
    }

    /**
     * @dev Returns whether a puzzle solver has already invited someone else to a given color
     *   - Bit-shifted to occupy bit(s) 8 + (indexOf(color))
    **/
    function puzzleInviteColorUsed(address inviter, HeartColor color) public view returns (bool) {
        return ((_solverData[inviter].auxData>>(8 + uint8(color)))%2 == 1);
    }

    /**
     * @dev Invites a list of invitees to mint (for someone who was themselves invited)
     * @notice Invite up to 5 invitees to mint; Invites for a given heart color
     *   may not be used multiple times; Note that
    **/
    function inviteeInvite(address[] calldata invitees) public {
//        require(invited(msg.sender), "ni");
//        require(inviteeInvitesGiven(msg.sender) + invitees.length <= 5, "aiu");

        bool alreadyInvited = false;
//        for (uint256 i = 0; i < invitees.length; i++) {
//            alreadyInvited = (alreadyInvited || invited(invitees[i]));
//        }

        bool senderInvited = invited(msg.sender);
        bool withinInviteLimit = ((inviteeInvitesGiven(msg.sender) + invitees.length) <= 5);

        (HeartColor[] memory colors, uint256 rand) = _randHeartColors(invitees.length);
        _hcNonce = (_hcNonce ^ rand) | 1;

        for (uint256 i = 0; i < invitees.length; i++) {
            address invitee = invitees[i];
            HeartColor color = colors[i];
//            require(!invited(invitee), "ai");
            alreadyInvited = (alreadyInvited || invited(invitee));

            uint256 setForInvitee = 1;
            setForInvitee += (uint8(color)<<1);

            ClaimInfo memory inviteeClaimInfo = _inviteeData[invitee];

//            _inviteeData[invitee].auxData = uint48(setForInvitee);
//            _inviteeData[invitee].inviter = msg.sender;
//            _inviteeData[invitee].inviteDepth = (uint48(inviteDepthOf(msg.sender)) + 1);
            inviteeClaimInfo.auxData = uint48(setForInvitee);
            inviteeClaimInfo.inviter = msg.sender;
            inviteeClaimInfo.inviteDepth = (uint48(inviteDepthOf(msg.sender)) + 1);

            _inviteeData[invitee] = inviteeClaimInfo;
        }

        if (alreadyInvited || (!senderInvited) || (!withinInviteLimit)) {
            revert InviteeInviteError(!alreadyInvited, senderInvited, withinInviteLimit);
        }

        _inviteeData[msg.sender].auxData += uint48(invitees.length<<5);
    }

    /**
     * @dev Invites a list of invitees to mint (for someone who solved the puzzle)
     * @notice Invite up to 5 invitees to mint; Invites for a given heart color
     *   may not be used multiple times; Only callable by those who have solved the puzzle
    **/
    function puzzleInvite(
        address[] calldata invitees,
        HeartColor[] calldata inviteeColors
    ) public {
//        require(invitees.length == inviteeColors.length, "lm");
//        require(puzzleSolved(msg.sender), "ni");
//        require(puzzleInvitesGiven(msg.sender) + invitees.length <= 5, "aiu");

        bool solved = puzzleSolved(msg.sender);
        bool lengthsMatch = (invitees.length == inviteeColors.length);
        bool withinInviteLimit = ((puzzleInvitesGiven(msg.sender) + invitees.length) <= 5);

        HeartColor ownColor = puzzleColor(msg.sender);
        uint256 addToMsgSenderSolverData = 0;

        bool notOwnColor = true;
        bool validColors = true;
        bool alreadyInvited = false;
        bool noSelfInvite = true;
        bool alreadyUsedColor = false;

        for (uint256 i = 0; i < invitees.length; i++) {
            address invitee = invitees[i];
            HeartColor color = inviteeColors[i];
//            require(!puzzleInviteColorUsed(msg.sender, color), "cu");
            alreadyUsedColor = (alreadyUsedColor || puzzleInviteColorUsed(msg.sender, color));
//            require((color != ownColor) && (color != HeartColor.Length), "oc/bhc");
            notOwnColor = (notOwnColor && (color != ownColor));
            validColors = (validColors && (color != HeartColor.Length));
//            require(!invited(invitee), "ai");
            alreadyInvited = (alreadyInvited || invited(invitee));
//            require(invitee != msg.sender, "self");
            noSelfInvite = (noSelfInvite && (invitee != msg.sender));

            addToMsgSenderSolverData += (1<<(8 + uint8(color)));

            uint256 setForInvitee = 1;
//            setForInvitee += (1<<(8 + uint8(color)));
            setForInvitee += (uint8(color)<<1);
//            _inviteeData[invitee].auxData = uint48(setForInvitee);
//            _inviteeData[invitee].inviter = msg.sender;
//            _inviteeData[invitee].inviteDepth = 1;

            ClaimInfo memory inviteeClaimInfo = _inviteeData[invitee];

            inviteeClaimInfo.auxData = uint48(setForInvitee);
            inviteeClaimInfo.inviter = msg.sender;
            inviteeClaimInfo.inviteDepth = 1;

            _inviteeData[invitee] = inviteeClaimInfo;
        }

        if (!(solved && lengthsMatch && withinInviteLimit && notOwnColor &&
        validColors && (!alreadyInvited) && noSelfInvite && (!alreadyUsedColor))) {
            revert PuzzleInviteError(
                solved,
                    lengthsMatch,
                    withinInviteLimit,
                    notOwnColor,
                    validColors,
                    !alreadyInvited,
                    noSelfInvite,
                    !alreadyUsedColor
            );
        }

        _solverData[msg.sender].auxData += uint48(addToMsgSenderSolverData + (invitees.length<<5));
    }

    /**
     * @dev Solves a puzzle with a given solution string set
    **/
    function solvePuzzle(
        string[] calldata solution,
        HeartColor ownColor
    ) public {
//        require(_solverData[msg.sender].auxData == 0, "solved");
//        require(cbEggs.balanceOf(msg.sender) > 0, "noEggz");
//        require(address(puzzle) != address(0), "ns");
//        require(puzzle.checkSolution(solution), "wrong");
//        require(ownColor != HeartColor.Length, "bhc");

        bool notYetSolved = (_solverData[msg.sender].auxData == 0);
        bool hasCrudeBorneEggs = (cbEggs.balanceOf(msg.sender) > 0);
        bool puzzleIsSet = (address(puzzle) != address(0));
        bool correctPuzzleSolution = puzzle.checkSolution(solution);
        bool validColor = (ownColor != HeartColor.Length);

        if (!(notYetSolved && hasCrudeBorneEggs && puzzleIsSet && correctPuzzleSolution && validColor)) {
            revert PuzzleSolveError(
                notYetSolved,
                    hasCrudeBorneEggs,
                    puzzleIsSet,
                    correctPuzzleSolution,
                    validColor
            );
        }

        _solverData[msg.sender].auxData += (uint8(ownColor)<<1) + 1;
    }

    /**
     * @dev Mints a new inactive heart corresponding to an invite
     * @notice Requires payment, whether egg holder or not - costs 0.01 $ETH
    **/
    function mintFromInvite() public payable {
//        require(mintStatus == MintStatus.Open, "ms");
//        require(invited(msg.sender), "i");
//        require(!inviteMintUsed(msg.sender), "imu");
//        require(inviteeInvitesGiven(msg.sender) == 5, "iig5");
//        require(msg.value == mintPrice, "tooRekt");

        bool mintStatusOpen = (mintStatus == MintStatus.Open);
        bool isInvited = invited(msg.sender);
        bool mintAlreadyUsed = inviteMintUsed(msg.sender);
        bool fiveInvitesGiven = (inviteeInvitesGiven(msg.sender) == 5);
        bool correctMsgValue = (msg.value == mintPrice);

        if (!(mintStatusOpen && isInvited && (!mintAlreadyUsed) && fiveInvitesGiven && correctMsgValue)) {
            revert InviteMintError(
                mintStatusOpen,
                    isInvited,
                    !mintAlreadyUsed,
                    fiveInvitesGiven,
                    correctMsgValue
            );
        }

        _freeActivations[msg.sender] += 1;
        _inviteeData[msg.sender].auxData += (1<<4);

        uint256 newHeartId = StorageLayerProto(
            STORAGE_LAYER_ADDRESS
        ).mint(msg.sender, invitedColor(msg.sender), 0, inviteDepthOf(msg.sender), inviterOf(msg.sender));

        BurnRewardsProto(BURN_REWARDS_ADDRESS).storeReward{value: msg.value/10}(newHeartId);

        (bool success1, ) = payable(_inviteeData[msg.sender].inviter).call{value: msg.value/5}("");
        require(success1, "pf1");

        if (POOL_ADDRESS_1 != address(0)) {
            (bool success2, ) = payable(POOL_ADDRESS_1).call{value: msg.value/10}("");
            require(success2, "pf2");
        }

        if (POOL_ADDRESS_2 != address(0)) {
            if (p_addr_2_bp > 0) {
                (bool success3, ) = payable(
                    POOL_ADDRESS_2
                ).call{value: (msg.value*p_addr_2_bp)/10000}("");
                require(success3, "pf3");
            }
        }
    }

    /**
     * @dev Mints a new inactive heart corresponding to a puzzle solution
     * @notice Puzzle mints are free - solve the puzzle to be able to call this function!
    **/
    function mintFromPuzzle() public {
//        require(mintStatus == MintStatus.Open || (mintStatus == MintStatus.OnlyOwner && msg.sender == owner()));
////        require(puzzleSolved(msg.sender), "ps");
//        require(!puzzleMintUsed(msg.sender), "pmu");
//        require(puzzleInvitesGiven(msg.sender) == 5, "pig5");

        bool authorizedToMint = (mintStatus == MintStatus.Open || (mintStatus == MintStatus.OnlyOwner && msg.sender == owner()));
        bool puzzleMintAlreadyUsed = puzzleMintUsed(msg.sender);
        bool fiveInvitesGiven = (puzzleInvitesGiven(msg.sender) == 5);

        if ((!authorizedToMint) || puzzleMintAlreadyUsed || (!fiveInvitesGiven)) {
            revert PuzzleMintError(authorizedToMint, !puzzleMintAlreadyUsed, fiveInvitesGiven);
        }

        _freeActivations[msg.sender] += 1;
        _solverData[msg.sender].auxData += (1<<4);

        StorageLayerProto(STORAGE_LAYER_ADDRESS).mint(msg.sender, puzzleColor(msg.sender), 0, 0, address(0));
    }

    /******************/

    function activationCost(uint256 numToActivate, address addr) public view returns (uint256) {
        uint256 toPay = mintPrice*numToActivate;
        uint256 freeActivations = _freeActivations[addr];

        while ((toPay > 0) && (freeActivations > 0)) {
            toPay -= mintPrice;
            freeActivations -= 1;
        }

        return toPay;
    }

    function activate(uint256 heartId) public payable {
        uint256 toPay = mintPrice;
        if (_freeActivations[msg.sender] > 0) {
            toPay -= mintPrice;
            _freeActivations[msg.sender] -= 1;
        }

        require(msg.value == toPay, "rekt");

        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_activate(heartId);

        BurnRewardsProto(BURN_REWARDS_ADDRESS).storeReward{value: msg.value/10}(heartId);

        if (POOL_ADDRESS_1 != address(0)) {
            (bool success1, ) = payable(POOL_ADDRESS_1).call{value: msg.value/10}("");
            require(success1, "pf1");
        }

        if (POOL_ADDRESS_2 != address(0)) {
            if (p_addr_2_bp > 0) {
                (bool success2, ) = payable(
                    POOL_ADDRESS_2
                ).call{value: (msg.value*p_addr_2_bp)/10000}("");
                require(success2, "pf2");
            }
        }
    }

    function batchActivate(uint256[] calldata heartIds) public payable {
        uint256 toPay = mintPrice*(heartIds.length);
        uint256 freeActivations = _freeActivations[msg.sender];
        uint256 freeUsed = 0;

        while ((toPay > 0) && (freeActivations > 0)) {
            toPay -= mintPrice;
            freeActivations -= 1;
            freeUsed += 1;
        }

        require(msg.value == toPay, "rekt");
        _freeActivations[msg.sender] -= freeUsed;

        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_batchActivate(heartIds);

        BurnRewardsProto(BURN_REWARDS_ADDRESS).batchStoreReward{value: msg.value/10}(heartIds);

        if (POOL_ADDRESS_1 != address(0)) {
            (bool success1, ) = payable(POOL_ADDRESS_1).call{value: msg.value/10}("");
            require(success1, "pf1");
        }

        if (POOL_ADDRESS_2 != address(0)) {
            if (p_addr_2_bp > 0) {
                (bool success2, ) = payable(
                    POOL_ADDRESS_2
                ).call{value: (msg.value*p_addr_2_bp)/10000}("");
                require(success2, "pf2");
            }
        }
    }

    function isExpired(uint256 heartId) public view returns (bool) {
        return ((block.timestamp - lastTransferred(heartId)) > secondsPerMonth);
    }

    function getExpiryTime(uint256 heartId) public view returns (uint256) {
        return (lastTransferred(heartId) + secondsPerMonth);
    }

    function burn(uint256 heartId) public {
        require(StorageLayerProto(
            STORAGE_LAYER_ADDRESS
        ).storage_balanceOf(true, msg.sender) > 0, "need active <3's...");

        require((block.timestamp - lastTransferred(heartId)) > secondsPerMonth, "exp_burn");

        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_burn(heartId);

        BurnRewardsProto(BURN_REWARDS_ADDRESS).disburseBurnReward(heartId, msg.sender);
    }

    function batchBurn(uint256[] calldata heartIds) public {
        require(StorageLayerProto(
            STORAGE_LAYER_ADDRESS
        ).storage_balanceOf(true, msg.sender) > 0, "need active <3's...");

        uint256 month = secondsPerMonth;

        bool allExpired = true;
        for (uint256 i = 0; i < heartIds.length; i++) {
            allExpired = allExpired && ((block.timestamp - lastTransferred(heartIds[i])) > month);
        }
        require(allExpired, "exp_batch_burn");

        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_batchBurn(heartIds);

        BurnRewardsProto(BURN_REWARDS_ADDRESS).batchDisburseBurnReward(heartIds, msg.sender);
    }

    /******************/

    function setMintPrice(uint256 newMintPrice) public onlyOwner {
        mintPrice = newMintPrice;
    }

    /******************/

    function setActiveHeartsContract(address _activeHearts) public onlyOwner {
        ACTIVE_HEARTS_ADDRESS = _activeHearts;
    }

    function setBurnRewardsAddress(address burnRewardsAddress) public onlyOwner {
        BURN_REWARDS_ADDRESS = burnRewardsAddress;
    }

    function setPuzzleAddress(address puzzleAddress) public onlyOwner {
        puzzle = PuzzleProto(puzzleAddress);
    }

    function setPoolAddress1(address poolAddress1) public onlyOwner {
        POOL_ADDRESS_1 = poolAddress1;
    }

    function setPoolAddress2(address poolAddress2) public onlyOwner {
        POOL_ADDRESS_2 = poolAddress2;
    }

    function setPA2BP(uint256 pa2bp) public onlyOwner {
        require(pa2bp <= 6000);
        p_addr_2_bp = pa2bp;
    }

    /******************/

    function withdraw(address to) public onlyOwner {
        (bool success, ) = payable(to).call{value: address(this).balance}("");
        require(success, "Payment failed!");
    }

    function withdrawTokens(address to, address tokenAddress) public onlyOwner {
        IERC20(tokenAddress).transfer(to, IERC20(tokenAddress).balanceOf(address(this)));
    }

    /******************/

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /******************/

    function emitTransfer(address from, address to, uint256 tokenId) public onlyStorage {
        emit Transfer(from, to, tokenId);
    }

    function batchEmitTransfers(
        address[] calldata from,
        address[] calldata to,
        uint256[] calldata tokenIds
    ) public onlyStorage {
        for (uint256 i = 0; i < from.length; i++) {
            emit Transfer(from[i], to[i], tokenIds[i]);
        }
    }

    function emitApproval(address owner, address approved, uint256 tokenId) public onlyStorage {
        emit Approval(owner, approved, tokenId);
    }

    function emitApprovalForAll(address owner, address operator, bool approved) public onlyStorage {
        emit ApprovalForAll(owner, operator, approved);
    }

    /******************/

    /**
     * Main portion of ERC721-compatible functionality.
     * Modified to function smoothly with the top-level
     * interface of Virtue (Inactive) Hearts.
    **/

    function balanceOf(address owner) public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_balanceOf(false, owner);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_ownerOf(false, tokenId);
    }

    function colorOf(uint256 tokenId) public view returns (HeartColor) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_colorOf(false, tokenId);
    }

    function parentOf(uint256 tokenId) public view returns (address) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_parentOf(false, tokenId);
    }

    function lineageDepthOf(uint256 tokenId) public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_lineageDepthOf(false, tokenId);
    }

    function numChildrenOf(uint256 tokenId) public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_numChildrenOf(false, tokenId);
    }

    function rawGenomeOf(uint256 tokenId) public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_rawGenomeOf(false, tokenId);
    }

    function genomeOf(uint256 tokenId) public view returns (string memory) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_genomeOf(false, tokenId);
    }

    function lastTransferred(uint256 tokenId) public view returns (uint64) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_lastTransferred(false, tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS)._exists(false, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyAllowedOperator(from) {
//    ) public {
        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_transferFrom(msg.sender, from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public onlyAllowedOperator(from) {
//    ) public {
        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_safeTransferFrom(msg.sender, from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyAllowedOperator(from) {
//    ) public {
        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_safeTransferFrom(msg.sender, from, to, tokenId);
    }

    function approve(
        address to,
        uint256 tokenId
    ) public onlyAllowedOperatorApproval(to) {
//    ) public {
        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_approve(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_getApproved(false, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool _approved
    ) public onlyAllowedOperatorApproval(operator) {
//    ) public {
        StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_setApprovalForAll(msg.sender, operator, _approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_isApprovedForAll(false, owner, operator);
    }

    /********/

    function totalSupply() public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_totalSupply(false);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_tokenOfOwnerByIndex(false, owner, index);
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        return StorageLayerProto(STORAGE_LAYER_ADDRESS).storage_tokenByIndex(false, index);
    }

    /********/

    function name() public view returns (string memory) {
        return _name;
    }

    function setName(string calldata newName) public onlyOwner {
        _name = newName;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function setSymbol(string calldata newSymbol) public onlyOwner {
        _symbol = newSymbol;
    }

    function setImage(string calldata newImage) public onlyOwner {
        collectionImg = newImage;
    }

    function setExternalLink(string calldata newLink) public onlyOwner {
        externalLink = newLink;
    }

    function imageMode(uint256 heartId) public view returns (uint256) {
        return (_imageMode[heartId/256]>>(heartId%256))%2;
    }

    function flipImageMode(uint256 heartId) public {
        require(msg.sender == ownerOf(heartId), "o");
        if (imageMode(heartId) == 0) {
            _imageMode[heartId/256] += (1<<(heartId%256));
        }
        else {
            _imageMode[heartId/256] -= (1<<(heartId%256));
        }
    }

    function imageURI(uint256 tokenId) private view returns (string memory) {
        return string(abi.encodePacked(imageBase, "/", tokenId.toString(), imagePostfix));
    }

    function setImageBase(string memory newImageBase) public onlyOwner {
        imageBase = newImageBase;
    }

    function setImagePostfix(string memory newImagePostfix) public onlyOwner {
        imagePostfix = newImagePostfix;
    }

    /**
     * @dev Returns an on-chain token URI (which also points to an off-chain image URI)
     * for a given token
    **/
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        HeartColor color = colorOf(tokenId);

        string memory toReturn = string(
            abi.encodePacked(
                "data:application/json;utf8,{\"name\":\"Heart #", tokenId.toString(), "\",",
                    "\"description\":\"This is a ", _colorToString[uint256(uint8(color))], " Heart. It's dangerous to go alone.\",",
                    "\"image\":\"",
                    ((imageMode(tokenId) == 0) ? string(abi.encodePacked(
                        "data:image/svg+xml;utf8,", imageDataGetter.getImageData(color)
                    )) : imageURI(tokenId))
            )
        );

        toReturn = string(
            abi.encodePacked(
                toReturn,
                "\",\"attributes\":[{\"trait_type\":\"Heart Color\",\"value\":\"", _colorToString[uint256(uint8(color))],
                "\"},{\"trait_type\":\"Genome\",\"value\":\"", genomeOf(tokenId),
                "\"},{\"trait_type\":\"Lineage Parent\",\"value\":\"", uint256(uint160(parentOf(tokenId))).toHexString(20),
                "\"},{\"trait_type\":\"Lineage Depth\",\"value\":\"", lineageDepthOf(tokenId).toString()
            )
        );

        toReturn = string(
            abi.encodePacked(
                toReturn,
                    "\"},{\"trait_type\":\"Number of Children\",\"value\":\"", numChildrenOf(tokenId).toString(),
                    "\"},{\"trait_type\":\"Expiration Date\",\"display_type\":\"date\",\"value\":\"", getExpiryTime(tokenId).toString(), "\"}",
                    (isExpired(tokenId) ? ",{\"value\":\"Expired\"}" : ""),
                    "],\"external_url\":\"https://hearts.virtue.wtf/hearts?id=", tokenId.toString(), "\"}"
            )
        );

        return toReturn;
    }

    function setIDG(address newIDGAddress) public onlyOwner {
        imageDataGetter = ImageDataGetter(newIDGAddress);
    }

    function contractURI() public view returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;utf8,{\"name\":\"", name(),"\",",
                "\"description\":\"", collectionDescription, "\",",
                "\"image\":\"", collectionImg, "\",",
                "\"external_link\":\"", externalLink, "\",",
                "\"seller_fee_basis_points\":500,\"fee_recipient\":\"",
                uint256(uint160(address(this))).toHexString(), "\"}"
            )
        );
    }

    /******************/

    bool private rs = true;

    modifier onlyAllowedOperator(address from) virtual override {
        if (rs) {
            if (from != msg.sender) {
                _checkFilterOperator(msg.sender);
            }
        }
        _;
    }

    modifier onlyAllowedOperatorApproval(address operator) virtual override {
        if (rs) {
            _checkFilterOperator(operator);
        }
        _;
    }

    function flipRS() public onlyOwner {
        rs = !rs;
    }
}

////////////////////

abstract contract CrudeBorneEggs {
    function balanceOf(address owner) public view virtual returns (uint256);
//    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256);
//    function ownerOf(uint256 tokenId) public view virtual returns (address);
}

//////////

abstract contract PuzzleProto {
    function checkSolution(string[] calldata solution) public view virtual returns (bool);
}

//////////

abstract contract StorageLayerProto {
    uint256 public _nextToMint;

    function storage_balanceOf(
        bool active,
        address owner
    ) public view virtual returns (uint256);

    function storage_ownerOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (address);

    function storage_colorOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (HeartColor);

    function storage_parentOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (address);

    function storage_lineageDepthOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (uint256);

    function storage_numChildrenOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (uint256);

    function storage_rawGenomeOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (uint256);

    function storage_genomeOf(
        bool active,
        uint256 tokenId
    ) public view virtual returns (string memory);

    function storage_lastTransferred(
        bool active,
        uint256 tokenId
    ) public view virtual returns (uint64);

    function storage_transferFrom(
        address msgSender,
        address from,
        address to,
        uint256 tokenId
    ) public virtual;

    function storage_safeTransferFrom(
        address msgSender,
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public virtual;

    function storage_safeTransferFrom(
        address msgSender,
        address from,
        address to,
        uint256 tokenId
    ) public virtual;

    function storage_approve(
        address msgSender,
        address to,
        uint256 tokenId
    ) public virtual;

    function storage_getApproved(
        bool active,
        uint256 tokenId
    ) public view virtual returns (address);

    function storage_setApprovalForAll(
        address msgSender,
        address operator,
        bool _approved
    ) public virtual;

    function storage_isApprovedForAll(
        bool active,
        address owner,
        address operator
    ) public view virtual returns (bool);

    /********/

    function storage_totalSupply(bool active) public view virtual returns (uint256);

    function storage_tokenOfOwnerByIndex(
        bool active,
        address owner,
        uint256 index
    ) public view virtual returns (uint256);

    function storage_tokenByIndex(
        bool active,
        uint256 index
    ) public view virtual returns (uint256);

    /********/

//    function mint(
//        address to,
//        HeartColor color,
//        uint256 lineageToken
//    ) public virtual returns (uint256);

    function mint(
        address to,
        HeartColor color,
        uint256 lineageToken,
        uint256 lineageDepth,
        address parent
    ) public virtual returns (uint256);

    function storage_activate(uint256 tokenId) public virtual;

    function storage_batchActivate(uint256[] calldata tokenIds) public virtual;

    function storage_burn(uint256 tokenId) public virtual;

    function storage_batchBurn(uint256[] calldata tokenIds) public virtual;

    /********/

    function _exists(bool active, uint256 tokenId) public view virtual returns (bool);
}

//////////

abstract contract BurnRewardsProto {
    function storeReward(uint256 heartId) public payable virtual;

    function disburseBurnReward(uint256 heartId, address to) public virtual;

    function batchStoreReward(uint256[] calldata heartIds) public payable virtual;

    function batchDisburseBurnReward(uint256[] calldata heartIds, address to) public virtual;
}

//////////

abstract contract ImageDataGetter {
    function getImageData(HeartColor color) public view virtual returns (string memory);
}

////////////////////////////////////////