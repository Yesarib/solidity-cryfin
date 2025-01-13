// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PriceConverter} from "../library/PriceConverter.sol";


contract FundMe {
    using PriceConverter for uint256;
    uint256 public minUsd = 5e18;

    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;
    address public owner;
    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minUsd, "not enough eth");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withDraw() public {
        require(msg.sender == owner, "must be owner.");
        for(uint256 funderIndex = 0; funderIndex<funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset array
        funders = new address[](0);

        (bool callSuccess,) = payable (msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call failed");
    }
}