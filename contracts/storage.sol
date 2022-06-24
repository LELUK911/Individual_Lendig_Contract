// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";


contract Storage {


    //Proxy variable
    address internal coreFunction;
    address internal depositFunction;
    address internal borrowFunction;



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
    //mapping ( uint => bool) internal lock;

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
    //mapping(address => mapping(uint=>Borrower)) private BorrowerContract;

    //mapping (address=> mapping(address=> uint)) internal liquidationContract;

    Counters.Counter internal Id; // id every lending contract


}