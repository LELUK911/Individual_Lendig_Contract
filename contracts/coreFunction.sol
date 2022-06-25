// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./storage.sol";
import "./interestCalculator.sol";

contract CoreFunction is Storage,Ownable,ReentrancyGuard {
    //library

    using Counters for Counters.Counter;
    //function variable
    
    //-------------------------------//
  
    // INTERNAL FUNCTION 
    function _setAssettAvvalible(address _newAsset) internal{
        require(_newAsset != address(0), "invalid address");
        require(!_findAsset(_newAsset),"Assett already in list");
        assetAvvalible.push(_newAsset);
           
    }
    function _healFactor(uint _priceCollateralETH, uint _priceBorrowEth) internal pure returns(uint){
        return (_priceCollateralETH/_priceBorrowEth);
    }
    function _liquidationThresold( uint _priceBorrowEth,uint _rateLiquidation) internal pure returns(uint){
        return (
            //uint _priceCollateralETH,
            //(_priceCollateralETH * _priceBorrowEth)/(_rateLiquidation * _priceBorrowEth)
            _priceBorrowEth * _rateLiquidation 

        );
    }
    //-----> Serch function  
    function _findAsset(address _asset) internal view returns(bool){
        for(uint i = 0; i<assetAvvalible.length; i++){
            if(assetAvvalible[i]==_asset){
                return true;
            }
        }
        return false;
    }
    function _getAssettAvvalible()internal view returns (address[] memory ){
        return assetAvvalible; 
    }

    event widrowFeeEvent(address indexed asset,uint amount);
    
    function _widrowFeeContract(address _asset)internal onlyOwner(){
      uint widrow = balanceFee[_asset];
      balanceFee[_asset] = 0;
      IERC20(_asset).transfer(owner(),widrow);
      emit widrowFeeEvent(_asset, widrow);
    }

}