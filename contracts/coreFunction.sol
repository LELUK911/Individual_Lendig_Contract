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


       //-----> Search function user 
    function _listContractXuser(address _user) internal view returns(uint[] memory){
       return listContractUser[_user];
    }
    function _findContractLending(address _to,uint _id)internal view returns(LendingContract memory){
        return userLendingContract[_to][_id];
    }
     function _findArrayindexContract(address _to,uint deleteId)internal view returns(uint,bool){
            for(uint i=0 ;i<listContractUser[_to].length;i++){
                if (deleteId == listContractUser[_to][i]){
                    return (i,true);
                }
            }
            return (0,false);
  
    }
    function _findContractAvvalible(uint _IdFind)internal view returns(uint,bool){
     
         for(uint i=0 ;i<listContract.length;i++){
             if (_IdFind == listContract[i]){
                return (i,true);
             }
         }
        return (0,false); 
    }

     //------> Search function Borrower
    function _serchIndexBorrowerXContract(uint _idContract,address _borrower) internal view returns(bool,uint){
      for(uint i =0; i<borrowersXid[_idContract].length;i++ ){
          if(borrowersXid[_idContract][i].owner == _borrower){
              return (true,i);
          }
      }
      return (false,0);
    }
    function _serchBorrowerPositionXContract(uint _idContract,address _borrower) internal view returns(Borrower memory){
       for(uint i =0; i<borrowersXid[_idContract].length;i++ ){
           if(borrowersXid[_idContract][i].owner == _borrower){
               return (borrowersXid[_idContract][i]);
           }
       }
       revert("Borrower for this contract not present");
    }

}