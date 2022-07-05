// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";


contract Storage {

    // User
    struct LendingContract {
        uint id;
        address owner;
        bool lock;
        address asset;
        uint amountAvvalible;
        uint apr;
        uint duration;
        uint penality;
        address collateral;
        uint amountBorrow;
        uint rateCollateral;
        uint amountCollateral;
    }
    mapping(address => mapping(uint=>LendingContract)) internal userLendingContract;
    mapping(address => uint[])listContractUser;
    mapping (address => mapping(address => uint)) internal userCreditExpire;

    // VAR BORROWER ---CORRECT NAME VAR.

    struct Borrower{
        address owner;
        uint idContract;
        address assetBorrow;
        uint ammounBorrow; // da correggere
        //uint heltBorrow;
        address assetCollaterl;
        uint amountCollateral;
        uint liquidationThreshold;
        uint expiration;
        uint blockStart;
        uint aprLoan;
        address lender;
    }
    mapping(uint => Borrower[]) internal borrowersXid;
  

  // VAR CONTRACT

    Counters.Counter internal Id; // id every lending contract
    address[] internal assetAvvalible; // asset add from Owner (only asset present in chainLink oracle)
    uint internal minPenality;
    mapping(address => uint) internal balanceFee;
          //Asset => priceFeed
    mapping(address=>address) internal  addressPriceFeed;
    // assett/usd price
    uint[] internal listContract;

}