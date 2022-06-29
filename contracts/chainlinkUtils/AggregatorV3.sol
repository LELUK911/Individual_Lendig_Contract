// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    
    function getLatestPrice(address _priceFeed) public view returns (int) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeed);
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}
