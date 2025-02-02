// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./PriceConverter.sol";

// outside of contract
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address public immutable OWNER; // same as your metamask acc

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        OWNER = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // calculator: 50 / currentEthPrice > 0.03 (current price $1700)
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    // address is a data type
    address[] public funders;
    // stores key/value pair
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        // require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough");
        // because PriceConverter is a library
        // ethAmount is already passed as msg.value.getConversionRate
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didn't send enough"
        );

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    // withdraw all the ETH that's funded by funders
    function withdraw() public onlyOnwer {
        // require(msg.sender == owner);

        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        // transfer the balance to whomever calling the withdraw()
        // visit https://solidity-by-example.org/sending-ether/ to learn more on transfer(), send()
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOnwer() {
        if (msg.sender != OWNER) {
            revert NotOwner();
        }
        require(msg.sender == OWNER, "Sender is not owner!");
        _; // execute the rest of the code
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// see code in github
// https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // gives you current eth price for given network/chains
    // this getPrice() is in the getConversionRate() below
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // comment out (already done this)
        // priceFeed = AggregatorV3Interface(priceFeedAddress);
        // in PriceConverter.sol > constructor

        // address of ETH Goreli pair
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        // );
        (, int price, , , ) = priceFeed.latestRoundData();
        // return price; // 1681.06996547

        // 1681.069965470000000000
        return uint256(price * 1e10); // 1**10 == 10000000000
        // return priceFeed.version();
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // current ETH price
        // without / 1e18, you end up with 36 0's, try using calculator
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}