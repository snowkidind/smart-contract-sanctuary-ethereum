// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IDepositContract {
    function get_deposit_root() external view returns (bytes32 rootHash);
}

interface ILightNode {
    function depositBufferedEther(uint256 maxDeposits) external;
}


interface INodeOperatorsRegistry {
    function getKeysOpIndex() external view returns (uint256 index);
}


contract DepositSecurityModule {
    /**
     * Short ECDSA signature as defined in https://eips.ethereum.org/EIPS/eip-2098.
     */
    struct Signature {
        bytes32 r;
        bytes32 vs;
    }

    event OwnerChanged(address newValue);
    event NodeOperatorsRegistryChanged(address newValue);
    event PauseIntentValidityPeriodBlocksChanged(uint256 newValue);
    event MaxDepositsChanged(uint256 newValue);
    event MinDepositBlockDistanceChanged(uint256 newValue);
    event GuardianQuorumChanged(uint256 newValue);
    event GuardianAdded(address guardian);
    event GuardianRemoved(address guardian);
    event DepositsPaused(address guardian);
    event DepositsUnpaused();


    bytes32 public immutable ATTEST_MESSAGE_PREFIX;
    bytes32 public immutable PAUSE_MESSAGE_PREFIX;

    address public immutable LIGHTNODE;
    address public immutable DEPOSIT_CONTRACT;

    address internal nodeOperatorsRegistry;
    uint256 internal maxDepositsPerBlock;
    uint256 internal minDepositBlockDistance;
    uint256 internal pauseIntentValidityPeriodBlocks;

    address internal owner;

    address[] internal guardians;
    mapping(address => uint256) internal guardianIndicesOneBased; // 1-based
    uint256 internal quorum;

    bool internal paused;
    uint256 internal lastDepositBlock;


    constructor(
        address _lightNode,
        address _depositContract,
        address _nodeOperatorsRegistry,
        uint256 _networkId,
        uint256 _maxDepositsPerBlock,
        uint256 _minDepositBlockDistance,
        uint256 _pauseIntentValidityPeriodBlocks
    ) {
        require(_lightNode != address(0), "LIGHTNODE_ZERO_ADDRESS");
        require(_depositContract != address(0), "DEPOSIT_CONTRACT_ZERO_ADDRESS");
        LIGHTNODE = _lightNode;
        DEPOSIT_CONTRACT = _depositContract;

        ATTEST_MESSAGE_PREFIX = keccak256(abi.encodePacked(
            // keccak256("lightNode.DepositSecurityModule.ATTEST_MESSAGE")
            bytes32(0x1085395a994e25b1b3d0ea7937b7395495fb405b31c7d22dbc3976a6bd01f2bf),
            _networkId
        ));

        PAUSE_MESSAGE_PREFIX = keccak256(abi.encodePacked(
            // keccak256("lightNode.DepositSecurityModule.PAUSE_MESSAGE")
            bytes32(0x9c4c40205558f12027f21204d6218b8006985b7a6359bcab15404bcc3e3fa122),
            _networkId
        ));

        _setOwner(msg.sender);
        _setNodeOperatorsRegistry(_nodeOperatorsRegistry);
        _setMaxDeposits(_maxDepositsPerBlock);
        _setMinDepositBlockDistance(_minDepositBlockDistance);
        _setPauseIntentValidityPeriodBlocks(_pauseIntentValidityPeriodBlocks);
    }

    /**
     * Returns the owner address.
     */
    function getOwner() external view returns (address) {
        return owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not an owner");
        _;
    }

    /**
     * Sets new owner. Only callable by the current owner.
     */
    function setOwner(address newValue) external onlyOwner {
        _setOwner(newValue);
    }

    function _setOwner(address newValue) internal {
        require(newValue != address(0), "invalid value for owner: must be different from zero address");
        owner = newValue;
        emit OwnerChanged(newValue);
    }


    /**
     * Returns NodeOperatorsRegistry contract address.
     */
    function getNodeOperatorsRegistry() external view returns (address) {
        return nodeOperatorsRegistry;
    }

    /**
     * Sets NodeOperatorsRegistry contract address. Only callable by the owner.
     */
    function setNodeOperatorsRegistry(address newValue) external onlyOwner {
        _setNodeOperatorsRegistry(newValue);
    }

    function _setNodeOperatorsRegistry(address newValue) internal {
        nodeOperatorsRegistry = newValue;
        emit NodeOperatorsRegistryChanged(newValue);
    }


    /**
     * Returns current `pauseIntentValidityPeriodBlocks` contract parameter (see `pauseDeposits`).
     */
    function getPauseIntentValidityPeriodBlocks() external view returns (uint256) {
        return pauseIntentValidityPeriodBlocks;
    }

    /**
     * Sets `pauseIntentValidityPeriodBlocks`. Only callable by the owner.
     */
    function setPauseIntentValidityPeriodBlocks(uint256 newValue) external onlyOwner {
        _setPauseIntentValidityPeriodBlocks(newValue);
    }

    function _setPauseIntentValidityPeriodBlocks(uint256 newValue) internal {
        require(newValue > 0, "invalid value for pauseIntentValidityPeriodBlocks: must be greater then 0");
        pauseIntentValidityPeriodBlocks = newValue;
        emit PauseIntentValidityPeriodBlocksChanged(newValue);
    }


    /**
     * Returns `maxDepositsPerBlock` (see `depositBufferedEther`).
     */
    function getMaxDeposits() external view returns (uint256) {
        return maxDepositsPerBlock;
    }

    /**
     * Sets `maxDepositsPerBlock`. Only callable by the owner.
     */
    function setMaxDeposits(uint256 newValue) external onlyOwner {
        _setMaxDeposits(newValue);
    }

    function _setMaxDeposits(uint256 newValue) internal {
        maxDepositsPerBlock = newValue;
        emit MaxDepositsChanged(newValue);
    }


    /**
     * Returns `minDepositBlockDistance`  (see `depositBufferedEther`).
     */
    function getMinDepositBlockDistance() external view returns (uint256) {
        return minDepositBlockDistance;
    }

    /**
     * Sets `minDepositBlockDistance`. Only callable by the owner.
     */
    function setMinDepositBlockDistance(uint256 newValue) external onlyOwner {
        _setMinDepositBlockDistance(newValue);
    }

    function _setMinDepositBlockDistance(uint256 newValue) internal {
        require(newValue > 0, "invalid value for minDepositBlockDistance: must be greater then 0");
        if (newValue != minDepositBlockDistance) {
            minDepositBlockDistance = newValue;
            emit MinDepositBlockDistanceChanged(newValue);
        }
    }


    /**
     * Returns number of valid guardian signatures required to vet (depositRoot, keysOpIndex) pair.
     */
    function getGuardianQuorum() external view returns (uint256) {
        return quorum;
    }

    function setGuardianQuorum(uint256 newValue) external onlyOwner {
        _setGuardianQuorum(newValue);
    }

    function _setGuardianQuorum(uint256 newValue) internal {
        // we're intentionally allowing setting quorum value higher than the number of guardians
        quorum = newValue;
        emit GuardianQuorumChanged(newValue);
    }


    /**
     * Returns guardian committee member list.
     */
    function getGuardians() external view returns (address[] memory) {
        return guardians;
    }

    /**
     * Checks whether the given address is a guardian.
     */
    function isGuardian(address addr) external view returns (bool) {
        return _isGuardian(addr);
    }

    function _isGuardian(address addr) internal view returns (bool) {
        return guardianIndicesOneBased[addr] > 0;
    }

    /**
     * Returns index of the guardian, or -1 if the address is not a guardian.
     */
    function getGuardianIndex(address addr) external view returns (int256) {
        return _getGuardianIndex(addr);
    }

    function _getGuardianIndex(address addr) internal view returns (int256) {
        return int256(guardianIndicesOneBased[addr]) - 1;
    }

    /**
     * Adds a guardian address and sets a new quorum value.
     * Reverts if the address is already a guardian.
     *
     * Only callable by the owner.
     */
    function addGuardian(address addr, uint256 newQuorum) external onlyOwner {
        _addGuardian(addr);
        _setGuardianQuorum(newQuorum);
    }

    /**
     * Adds a set of guardian addresses and sets a new quorum value.
     * Reverts any of them is already a guardian.
     *
     * Only callable by the owner.
     */
    function addGuardians(address[] memory addresses, uint256 newQuorum) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; ++i) {
            _addGuardian(addresses[i]);
        }
        _setGuardianQuorum(newQuorum);
    }

    function _addGuardian(address addr) internal {
        require(addr != address(0), "guardian zero address");
        require(!_isGuardian(addr), "duplicate address");
        guardians.push(addr);
        guardianIndicesOneBased[addr] = guardians.length;
        emit GuardianAdded(addr);
    }

    /**
     * Removes a guardian with the given address and sets a new quorum value.
     *
     * Only callable by the owner.
     */
    function removeGuardian(address addr, uint256 newQuorum) external onlyOwner {
        uint256 indexOneBased = guardianIndicesOneBased[addr];
        require(indexOneBased != 0, "not a guardian");

        uint256 totalGuardians = guardians.length;
        assert(indexOneBased <= totalGuardians);

        if (indexOneBased != totalGuardians) {
            address addrToMove = guardians[totalGuardians - 1];
            guardians[indexOneBased - 1] = addrToMove;
            guardianIndicesOneBased[addrToMove] = indexOneBased;
        }

        guardianIndicesOneBased[addr] = 0;
        guardians.pop();

        _setGuardianQuorum(newQuorum);

        emit GuardianRemoved(addr);
    }


    /**
     * Returns whether deposits were paused.
     */
    function isPaused() external view returns (bool) {
        return paused;
    }

    /**
     * Pauses deposits given that both conditions are satisfied (reverts otherwise):
     *
     *   1. The function is called by the guardian with index guardianIndex OR sig
     *      is a valid signature by the guardian with index guardianIndex of the data
     *      defined below.
     *
     *   2. block.number - blockNumber <= pauseIntentValidityPeriodBlocks
     *
     * The signature, if present, must be produced for keccak256 hash of the following
     * message (each component taking 32 bytes):
     *
     * | PAUSE_MESSAGE_PREFIX | blockNumber
     */
    function pauseDeposits(uint256 blockNumber, Signature memory sig) external {
        // In case of an emergency function `pauseDeposits` is supposed to be called
        // by all guardians. Thus only the first call will do the actual change. But
        // the other calls would be OK operations from the point of view of protocol’s logic.
        // Thus we prefer not to use “error” semantics which is implied by `require`.
        if (paused) {
            return;
        }

        address guardianAddr = msg.sender;
        int256 guardianIndex = _getGuardianIndex(msg.sender);

        if (guardianIndex == -1) {
            bytes32 msgHash = keccak256(abi.encodePacked(PAUSE_MESSAGE_PREFIX, blockNumber));
            guardianAddr = ECDSA.recover(msgHash, sig.r, sig.vs);
            guardianIndex = _getGuardianIndex(guardianAddr);
            require(guardianIndex != -1, "invalid signature");
        }

        require(
            block.number - blockNumber <= pauseIntentValidityPeriodBlocks,
            "pause intent expired"
        );

        paused = true;
        emit DepositsPaused(guardianAddr);
    }

    /**
     * Unpauses deposits.
     *
     * Only callable by the owner.
     */
    function unpauseDeposits() external onlyOwner {
        if (paused) {
            paused = false;
            emit DepositsUnpaused();
        }
    }


    /**
     * Returns the last block that contains a deposit performed via this security module.
     */
    function getLastDepositBlock() external view returns (uint256) {
        return lastDepositBlock;
    }


    /**
     * Sets `lastDepositBlock`. Only callable by the owner.
     */
    function setLastDepositBlock(uint256 newLastDepositBlock) external onlyOwner {
        lastDepositBlock = newLastDepositBlock;
    }


    /**
     * Returns whether depositBufferedEther can be called, given that the caller will provide
     * guardian attestations of non-stale deposit root and `keysOpIndex`, and the number of
     * such attestations will be enough to reach quorum.
     */
    function canDeposit() external view returns (bool) {
        return !paused && quorum > 0 && block.number - lastDepositBlock >= minDepositBlockDistance;
    }


    /**
     * Calls LightNode.depositBufferedEther(maxDepositsPerBlock).
     *
     * Reverts if any of the following is true:
     *   1. IDepositContract.get_deposit_root() != depositRoot.
     *   2. INodeOperatorsRegistry.getKeysOpIndex() != keysOpIndex.
     *   3. The number of guardian signatures is less than getGuardianQuorum().
     *   4. An invalid or non-guardian signature received.
     *   5. block.number - getLastDepositBlock() < minDepositBlockDistance.
     *   6. blockhash(blockNumber) != blockHash.
     *
     * Signatures must be sorted in ascending order by index of the guardian. Each signature must
     * be produced for keccak256 hash of the following message (each component taking 32 bytes):
     *
     * | ATTEST_MESSAGE_PREFIX | depositRoot | keysOpIndex | blockNumber | blockHash |
     */
    function depositBufferedEther(
        bytes32 depositRoot,
        uint256 keysOpIndex,
        uint256 blockNumber,
        bytes32 blockHash,
        Signature[] memory sortedGuardianSignatures
    ) external {
        bytes32 onchainDepositRoot = IDepositContract(DEPOSIT_CONTRACT).get_deposit_root();
        require(depositRoot == onchainDepositRoot, "deposit root changed");

        require(!paused, "deposits are paused");
        require(quorum > 0 && sortedGuardianSignatures.length >= quorum, "no guardian quorum");

        require(block.number - lastDepositBlock >= minDepositBlockDistance, "too frequent deposits");
        require(blockHash != bytes32(0) && blockhash(blockNumber) == blockHash, "unexpected block hash");

        uint256 onchainKeysOpIndex = INodeOperatorsRegistry(nodeOperatorsRegistry).getKeysOpIndex();
        require(keysOpIndex == onchainKeysOpIndex, "keys op index changed");

        _verifySignatures(
            depositRoot,
            keysOpIndex,
            blockNumber,
            blockHash,
            sortedGuardianSignatures
        );

        ILightNode(LIGHTNODE).depositBufferedEther(maxDepositsPerBlock);
        lastDepositBlock = block.number;
    }


    function _verifySignatures(
        bytes32 depositRoot,
        uint256 keysOpIndex,
        uint256 blockNumber,
        bytes32 blockHash,
        Signature[] memory sigs
    )
        internal view
    {
        bytes32 msgHash = keccak256(abi.encodePacked(
            ATTEST_MESSAGE_PREFIX,
            depositRoot,
            keysOpIndex,
            blockNumber,
            blockHash
        ));

        address prevSignerAddr = address(0);

        for (uint256 i = 0; i < sigs.length; ++i) {
            address signerAddr = ECDSA.recover(msgHash, sigs[i].r, sigs[i].vs);
            require(_isGuardian(signerAddr), "invalid signature");
            require(signerAddr > prevSignerAddr, "signatures not sorted");
            prevSignerAddr = signerAddr;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}