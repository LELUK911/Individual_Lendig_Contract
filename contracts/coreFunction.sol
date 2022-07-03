// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./storage.sol";
import "./interestCalculator.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./chainlinkUtils/AggregatorV3.sol";

contract CoreFunction is Storage,Ownable,ReentrancyGuard,PriceConsumerV3 {
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
    function _healFactor(uint _valueCollateral, uint _valueBorrow) internal pure returns(uint){
        return (_valueCollateral/_valueBorrow);
    }
    function _liquidationThresold(
         uint _valueLoan,
         uint _rateLiquidation,
         uint _amountCollateral) internal pure returns(uint){
        return (

             //loan *rate => ltv / total collateral
            (_valueLoan * _rateLiquidation)/_amountCollateral

           
          
            //_priceBorrowEth * _rateLiquidation 

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
    function _widrowFeeContract(address _asset)internal {
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
     function _findArrayindexContract(address _to,uint _Id)internal view returns(uint,bool){
            for(uint i=0 ;i<listContractUser[_to].length;i++){
                if (_Id == listContractUser[_to][i]){
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

     event widrowFeeEvent(address indexed asset,uint amount);

    function widrowFeeContract(address _asset)external onlyOwner() nonReentrant(){
        _widrowFeeContract(_asset);
    }

    // FUNCTION SET PRICE FEED //
   
    function _addAddressPriceeFeed(address _asset,address _addressPriceFeed) internal {
        require(_asset != address(0) && _addressPriceFeed != address(0), "Set correct address" );
        require(_findAsset(_asset),"insert new asset before set address PriceFeed");
        addressPriceFeed[_asset] = _addressPriceFeed;
    }

    //mock oracle
    mapping(address=>uint) public mockprice;
    function setMockPrice(address _asset,uint _price) public{
        mockprice[_asset] = _price;
    }

    function setTimeExpire(address _to,uint _idContract,uint _time) external{
        userLendingContract[_to][_idContract].duration += _time; 
    }



    /////



    function oraclePrice(address _asset)internal view returns(uint) {
        //return (SafeCast.toUint256(getLatestPrice(addressPriceFeed[_asset])))*10**10; 
        
        ////mock
        return mockprice[_asset];
        ///
    }


    function addAddressPriceeFeed(address _asset,address _addressPriceFeed) external onlyOwner(){
        _addAddressPriceeFeed(_asset,_addressPriceFeed);
    }



}






/**
    weth = 1.100$


    prendo in prestito 20.000 usdc e do a collaterale con un fattore di 3  60 weth ( prezzo 1.000  minimo) 


    valore 66k
    loan *rate => ltv / total collateral
    20.000 * 3 => 60.000 / amount weth



 */