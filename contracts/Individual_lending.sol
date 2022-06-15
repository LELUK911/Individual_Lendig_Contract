// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract lendingPage is Ownable,ReentrancyGuard {
    using Counters for Counters.Counter;
    
    
    //function variable
    Counters.Counter private Id; // id every lending contract
    address[] private assetAvvalible; // asset add from Owner (only asset present in chainLink oracle)
    uint private minPenality;
    
    // User
    struct LendingContract {
        address asset;
        uint amount;
        uint amountAvvalible;
        uint apr;
        uint deadline;
        uint penality;
        address collateral;
    }
    mapping(address => mapping(uint=>LendingContract)) private userLendingContract;



    //-------------------------------//

    constructor(uint _minpenality) Ownable() ReentrancyGuard(){
        Id.increment();
        minPenality = _minpenality;
    }

    // INTERNAL FUNCTION 

    function _setAssettAvvalible(address _newAsset) internal{
        require(_newAsset != address(0), "invalid address");
        assetAvvalible.push(_newAsset);
        emit NewAssetAvvalible(_newAsset, block.timestamp);   
    }

    function _findAsset(address _asset) internal view returns(bool){
        for(uint i = 0; i<assetAvvalible.length; i++){
            if(assetAvvalible[i]==_asset){
                return true;
            }
        }
        return false;
    }


    function _deposit(address _to,address _asset,uint _amount,uint _apr,uint _deadline,uint _penality,address _collateral)internal {
        //check
        require(_to != address(0), "invalid address");
        require(_findAsset(_asset),"asset don't found");
        require(_findAsset(_collateral),"collateral don't found");
        require(IERC20(_asset).balanceOf(_to) >= _amount,"balance user low");
        require(IERC20(_asset).allowance(_to, address(this)) >= _amount,"alowance user low");
        require(_deadline > 0,"deadline must have geatee 0");
        require(_penality >=  minPenality,"penality must have geatee 0");    
        // action
        uint balanceContract = IERC20(_asset).balanceOf(address(this)); 
        IERC20(_asset).transferFrom(_to,address(this), _amount);
        require(balanceContract+_amount == IERC20(_asset).balanceOf(address(this)));
        // prepare local variable
        LendingContract memory newContract= LendingContract(
            _asset,
            _amount,
            _amount,
            _apr,
            _deadline,
            _penality,
            _collateral
        );
        // update status global variable
        userLendingContract[_to][Id.current()] = newContract;
        emit NewContractDeposit(
            Id.current(),_asset,_amount,_apr,_deadline,_penality, _collateral
        );
        Id.increment();


    }

    function _findContractLending(address _to,uint _id)internal view returns(LendingContract memory){
        return userLendingContract[_to][_id];
    }


    // EVENT 

     event NewAssetAvvalible(address indexed asset, uint timeStart);
     event NewContractDeposit(
        uint Id,
        address indexed asset,
        uint indexed amount,
        uint apr,
        uint  deadline,
        uint  penality,
        address indexed collateral
     );



    // EXTERNAL FUNCTION
    function setAssettAvvalible(address _newAsset) external nonReentrant() onlyOwner() {
        _setAssettAvvalible(_newAsset);
    } 

    function findAsset(address _asset) external view returns(bool){
        return _findAsset(_asset);
    }

    function deposit(address _asset,uint _amount,uint _apr,uint _deadline,uint _penality,address _collateral) external nonReentrant() {
        _deposit(msg.sender, _asset, _amount, _apr, _deadline, _penality, _collateral);
    }



    
}


/**
 nonReentrant()
 onlyOwner()
 
 
 
 */
