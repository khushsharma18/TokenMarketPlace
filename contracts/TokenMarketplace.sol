
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenMarketPlace {
    uint256 public constant TOKEN_PRICE = 1 ether;
    uint256 private reseverdOrderedTokens;

    error TokenMarketPlace_ZeroNumberOfTokens(uint256 numberOfTokens);
    error TokenMarketPlace_InsufficientEthPayment(uint256 ExpectedPayment, uint256 ActualPayment);

       function _isZeroNumberOfToken(uint256 numberOfTokens) internal pure{
           if(numberOfTokens==0){
            revert TokenMarketPlace_ZeroNumberOfTokens(numberOfTokens);
           }
        }
        function _CheckEthPayment(uint256 numberOfTokens) internal view {
            if(numberOfTokens*TOKEN_PRICE>msg.value) {
            revert TokenMarketPlace_InsufficientEthPayment(numberOfTokens*TOKEN_PRICE, msg.value);
            }
        }
       function buyTokensFromMarketPlace(uint256 numberOfTokens) external payable{
                _isZeroNumberOfToken(numberOfTokens);
                _CheckEthPayment(numberOfTokens);
        }
}