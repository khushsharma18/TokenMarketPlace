// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
struct Orderinfo{
    uint256 orderId;
    address seller;
    uint256 numberOfTokensToSell;
    bool isActive;
}