
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenMarketPlace {
    uint256 public constant TOKEN_PRICE = 1 ether;
    uint256 private reseverdOrderedTokens;

    error TokenMarketPlace_ZeroNumberOfTokens(uint256 numberOfTokens);
    error TokenMarketPlace_InsufficientEthPayment(uint256 ExpectedPayment, uint256 ActualPayment);

       function buyTokensFromMarketPlace(uint256 numberOfTokens) external payable{
         if(numberOfTokens==0){
            revert TokenMarketPlace_ZeroNumberOfTokens(numberOfTokens);
        }
         if(numberOfTokens*TOKEN_PRICE>msg.value) {
            revert TokenMarketPlace_InsufficientEthPayment(numberOfTokens*TOKEN_PRICE, msg.value);

         }

    }
}