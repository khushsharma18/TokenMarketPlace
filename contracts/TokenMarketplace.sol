
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {OrderInfo} from "./types/trade.sol";
contract TokenMarketPlace {
    uint256 public constant TOKEN_PRICE = 1 ether;
    uint256 private reseverdOrderedTokens;
    IERC20 public slvToken;

    mapping(uint256=>OrderInfo) private orders;
    uint256 private nextOrderId;

    error TokenMarketPlace_ZeroNumberOfTokens(uint256 numberOfTokens);
    error TokenMarketPlace_InsufficientEthPayment(uint256 expectedPayment, uint256 actualPayment);
    error TokenMarketPlace_InsufficientTokenBalance(uint256 expectedToken, uint256 actualToken);
    error TokenMarketPlace_InsufficientBalance(uint256 actualTokens, uint256 expectedTokens);
    error TokenMarketPlace_InsufficientAllowance(uint256 allowedTokens, uint256 tokenToTransfer);
    error TokenMarketPlace_OrderIsNotActive(uint256 OrderId);
    error TokenMarketPlace_NotEnoughTokensInOrder(uint256 expectedTokens,uint256 actualTokens);
    error TokenMarketPlace_EthTransferfailed();
    constructor(address _slvToken) {
        slvToken = IERC20(_slvToken);
    }
    function _getSlvTokenBalanceMarketPlace() internal view returns(uint256) {
        return slvToken.balanceOf(address(this));
    }

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
                if(_getSlvTokenBalanceMarketPlace()>numberOfTokens){
                    revert TokenMarketPlace_InsufficientTokenBalance(numberOfTokens, _getSlvTokenBalanceMarketPlace());

                }
                slvToken.transfer(msg.sender, numberOfTokens);
    }

    function _checkSellerSlvTokenBalance(uint256 numberOfTokens) internal view {
            uint256 balance = slvToken.balanceOf(msg.sender);

            if(numberOfTokens> balance) {
                revert TokenMarketPlace_InsufficientBalance(balance,numberOfTokens);
            }
    }

    function createSellOrder(uint256 numberOfTokenToSell) external {
              _isZeroNumberOfToken(numberOfTokenToSell);
             _checkSellerSlvTokenBalance(numberOfTokenToSell);
             uint256 allowance = slvToken.allowance(msg.sender,address(this));

             if(allowance<numberOfTokenToSell){
                revert TokenMarketPlace_InsufficientAllowance(allowance,numberOfTokenToSell);
             }

         OrderInfo memory order = OrderInfo({
                orderId: nextOrderId,
                seller: msg.sender,
                numberOfTokensToSell:numberOfTokenToSell,
                isActive:true
             });
        orders[nextOrderId] = order;
        nextOrderId++;
        slvToken.transferFrom(msg.sender, address(this), numberOfTokenToSell);
        reseverdOrderedTokens+= numberOfTokenToSell;
    }

    function buyTokensFromSellOrderCreated(uint256 orderId, uint256 numberOfTokensToBuy) external payable {
        _isZeroNumberOfToken(numberOfTokensToBuy);
        OrderInfo memory order = orders[orderId];
        if(order.isActive == false) {
            revert TokenMarketPlace_OrderIsNotActive(orderId);
        }

        if(order.numberOfTokensToSell<numberOfTokensToBuy) {
            revert TokenMarketPlace_NotEnoughTokensInOrder(order.numberOfTokensToSell,numberOfTokensToBuy);
        }
        order.numberOfTokensToSell-=numberOfTokensToBuy;

        if(order.numberOfTokensToSell==0){
            order.isActive=false;
        }
        slvToken.transfer(msg.sender, numberOfTokensToBuy);

        (bool success,) = order.seller.call{value: msg.value}("");
        if(!success){
            revert TokenMarketPlace_EthTransferfailed();
        }

    }

}