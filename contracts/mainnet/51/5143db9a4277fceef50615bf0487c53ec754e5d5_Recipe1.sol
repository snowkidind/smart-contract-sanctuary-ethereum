// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../../../libraries/LibAppStorage.sol";
import "../../../interfaces/IERC20.sol";

// Recipe 1. ---* Short USDT with USDC on AAVE *--- //

contract Recipe1 {

    constructor() {}

    function recipe1(
        address _onBehalf, 
        uint _amount,
        uint _leverage,
        bytes calldata data
    ) 
        public 
        returns (bytes memory txData) 
    {
        txData = _handleApprovals(txData, _amount, _onBehalf);
        
        // Get amounts 
        uint[] memory amounts = _getAmounts(_amount,_leverage);
        // Get actions
        bytes[] memory actions = _getActions(amounts,_leverage,_onBehalf);

        // final action that closes the loop
        actions[actions.length-1] = abi.encodePacked(uint8(0),0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9,uint256(0),uint256(132),abi.encodeWithSignature(
            "deposit(address,uint256,address,uint16)", 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,amounts[amounts.length-1],_onBehalf,0));
        
        for (uint i=0; i< actions.length; i++){
            txData = abi.encodePacked(txData,actions[i]);
        }

        return txData;
    }

    /* Handle Approvals - Approve protocols if needed */
    function _handleApprovals(bytes memory txData, uint _amount, address _onBehalf) internal returns (bytes memory){
        // address lendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
        // address curvePool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
        // address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; 
        // address usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7; 
        
        if (IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).allowance(_onBehalf,0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9) < _amount ){
            bytes memory approve1 = abi.encodePacked(uint8(0),0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,uint256(0),uint256(68),abi.encodeWithSignature(
            "approve(address,uint256)", 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9, type(uint256).max));
            txData = abi.encodePacked(approve1);
            if (IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).allowance(_onBehalf,0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7) < _amount ){
                bytes memory approve2 = abi.encodePacked(uint8(0),0xdAC17F958D2ee523a2206206994597C13D831ec7,uint256(0),uint256(68),abi.encodeWithSignature(
                "approve(address,uint256)", 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7, type(uint256).max));
                txData = abi.encodePacked(approve1,approve2);
            }
        } else if (IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).allowance(_onBehalf,0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7) < _amount ){
                bytes memory approve2 = abi.encodePacked(uint8(0),0xdAC17F958D2ee523a2206206994597C13D831ec7,uint256(0),uint256(68),abi.encodeWithSignature(
                "approve(address,uint256)", 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7, type(uint256).max));
                txData = abi.encodePacked(approve2);
        }
        return txData;
    }

    function _getAmounts(
        uint _amount,
        uint _leverage
    ) 
        internal 
        view 
        returns (uint[] memory)
    {
        uint[] memory amounts = new uint[](7*_leverage);
        for (uint i=0; i<amounts.length; i++){
            if (i == 0) {
                // first element
                amounts[i] = _amount;
            } else if (i % 7 == 1 || i % 7 == 4) {
                // elements at index 1 and 4 and all other multiples of 7
                amounts[i] = amounts[i - 1] *618026/1000000;
            }  else {
                // all other elements
                amounts[i] = amounts[i-1];
            }
        }
        return amounts;
    }

    function _getActions(
        uint[] memory amounts,
        uint _leverage,
        address _onBehalf
    ) 
        internal 
        view 
        returns (bytes[] memory)
    {
        bytes[] memory actions = new bytes[](7*_leverage);
        for (uint i=0; i<actions.length; i+=7){
            actions[0+i] = abi.encodePacked(uint8(0),0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9,uint256(0),uint256(132),abi.encodeWithSignature(
                "deposit(address,uint256,address,uint16)", 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, amounts[0+i],_onBehalf,0));
            actions[1+i] = abi.encodePacked(uint8(0),0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9,uint256(0),uint256(164),abi.encodeWithSignature(
                "borrow(address,uint256,uint256,uint16,address)", 0xdAC17F958D2ee523a2206206994597C13D831ec7, amounts[1+i],2,0,_onBehalf));
            actions[2+i] = abi.encodePacked(uint8(0),0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7,uint256(0),uint256(132),abi.encodeWithSignature(
                "exchange(int128,int128,uint256,uint256)", 2, 1, amounts[2+i],0));
            actions[3+i] = abi.encodePacked(uint8(0),0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9,uint256(0),uint256(132),abi.encodeWithSignature(
                "deposit(address,uint256,address,uint16)", 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, amounts[3+i],_onBehalf,0));
            actions[4+i] = abi.encodePacked(uint8(0),0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9,uint256(0),uint256(164),abi.encodeWithSignature(
                "borrow(address,uint256,uint256,uint16,address)", 0xdAC17F958D2ee523a2206206994597C13D831ec7, amounts[4+i],2,0,_onBehalf));
            actions[5+i] = abi.encodePacked(uint8(0),0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7,uint256(0),uint256(132),abi.encodeWithSignature(
                "exchange(int128,int128,uint256,uint256)", 2, 1, amounts[5+i],0));
        }
        return actions;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: MIT

// Vendored from OpenZeppelin contracts with minor modifications:
// - Modified Solidity version
// - Formatted code
// - Added `name`, `symbol` and `decimals` function declarations
// <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/IERC20.sol>

pragma solidity >=0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./LibDiamond.sol";


struct Recipe {
    uint id;
    string name;
    bytes4 sig;
    bytes data;
}

struct AppStorage {
    uint256 idCounter;
    //recipeId to Recipe struct
    mapping(uint => Recipe) recipes;
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}


contract Modifiers {
    AppStorage internal s;

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import "../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // uint16 selectorCount = uint16(diamondStorage().selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
            ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
            ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            removeFunction(oldFacetAddress, selector);
            // add function
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            selectorPosition++;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(oldFacetAddress, selector);
        }
    }

    function removeFunction(address _facetAddress, bytes4 _selector) internal {
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
        // an immutable function is a function defined directly in a diamond
        require(_facetAddress != address(this), "LibDiamondCut: Can't remove immutable function");
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint16(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = uint16(facetAddressPosition);
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}