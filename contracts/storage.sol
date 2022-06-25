// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";


contract Storage {

    address[] internal assetAvvalible; // asset add from Owner (only asset present in chainLink oracle)
    uint internal minPenality;
    // User
    struct LendingContract {
        uint id;
        address owner;
        bool lock;
        address asset;
        //uint amount;
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
    uint[] internal listContract;
    mapping (address => mapping(address => uint)) internal userCreditExpire;



    // borrower

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
  

  // contract var

    Counters.Counter internal Id; // id every lending contract

    mapping(address => uint) internal balanceFee;

}