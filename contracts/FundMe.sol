// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PriceConverter} from "../library/PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant minUsd = 5e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minUsd, "not enough eth");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withDraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset array
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
        revert();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"sender is not owner!");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    //
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
