// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract lendingPage is Ownable,ReentrancyGuard {
    //library
    using Counters for Counters.Counter;
    //function variable
    Counters.Counter private Id; // id every lending contract
    address[] private assetAvvalible; // asset add from Owner (only asset present in chainLink oracle)
    uint private minPenality;
    // User
    struct LendingContract {
        uint id;
        address owner;
        address asset;
        //uint amount;
        uint amountAvvalible;
        uint apr;
        uint deadline;
        uint penality;
        address collateral;
        uint _amountBorrow;
    }
    mapping(address => mapping(uint=>LendingContract)) private userLendingContract;
    mapping(address => uint[])listContractUser;
    //-------------------------------//
    constructor(uint _minpenality) Ownable() ReentrancyGuard(){
        Id.increment();
        minPenality = _minpenality;
    }
    // INTERNAL FUNCTION 
    function _setAssettAvvalible(address _newAsset) internal{
        require(_newAsset != address(0), "invalid address");
        require(!_findAsset(_newAsset),"Assett already in list");
        assetAvvalible.push(_newAsset);
        emit NewAssetAvvalible(_newAsset, block.timestamp);   
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
 
    //-----> Search function user 
    function _listContractXuser(address _user) internal view returns(uint[] memory){
       return listContractUser[_user];
    }
     function _findContractLending(address _to,uint _id)internal view returns(LendingContract memory){
        return userLendingContract[_to][_id];
    }
     function _findArrayindexContract(address _to,uint deleteId)internal view returns(uint,bool){
            uint index = 0;
            bool response = false;
            for(uint i=0 ;i<listContractUser[_to].length;i++){
                if (deleteId == listContractUser[_to][i]){
                    index = i;
                    response = true;
                }
            }
            return (index,response);
        
    }
    // ----> User Function

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
            Id.current(),
            _to,
            _asset,
            //_amount,
            _amount,
            _apr,
            _deadline,
            _penality,
            _collateral,
            0
        );
        // update status global variable
        userLendingContract[_to][Id.current()] = newContract;
        emit NewContractDeposit(
            Id.current(),_to,_asset,_amount,_apr,_deadline,_penality, _collateral
        );
        listContractUser[_to].push(Id.current());
        Id.increment();


    }


    function _increasDeposit(address _to,uint _idContract, uint _increasAmount) internal  contractOwner(_to, _idContract){
        require(_increasAmount > 0, "increas must be plus 0");
        require(IERC20(_findContractLending(_to,_idContract).asset).balanceOf(_to) >= _increasAmount,"balance user low");
        require(IERC20(_findContractLending(_to,_idContract).asset).allowance(_to, address(this)) >= _increasAmount,"alowance user low");
        
        uint balanceContract = IERC20(_findContractLending(_to,_idContract).asset).balanceOf(address(this)); 
        IERC20(_findContractLending(_to,_idContract).asset).transferFrom(_to,address(this), _increasAmount);
        require(balanceContract+_increasAmount == IERC20(_findContractLending(_to,_idContract).asset).balanceOf(address(this)));

        userLendingContract[_to][_idContract].amountAvvalible += _increasAmount; 

        emit IncreasContractDeposit(
            _findContractLending(_to,_idContract).id,
            _findContractLending(_to,_idContract).amountAvvalible - _increasAmount,
            _findContractLending(_to,_idContract).amountAvvalible  
        );
    }
    function _decreasDeposit(address _to,uint _idContract, uint _decreasAmount) internal contractOwner(_to, _idContract){
        require(_decreasAmount > 0, "increas must be plus 0");
        require(
            _findContractLending(_to,_idContract).amountAvvalible >= _decreasAmount, "Assett avvalible insufficient for thios whidrow"
        );

        userLendingContract[_to][_idContract].amountAvvalible -= _decreasAmount;

        uint balanceContract = IERC20(_findContractLending(_to,_idContract).asset).balanceOf(address(this)); 
        IERC20(_findContractLending(_to,_idContract).asset).transfer(_to,_decreasAmount);
        require(balanceContract -_decreasAmount == IERC20(_findContractLending(_to,_idContract).asset).balanceOf(address(this)));

        emit DecreasContractDeposit(
            _findContractLending(_to,_idContract).id,
            _findContractLending(_to,_idContract).amountAvvalible + _decreasAmount,
            _findContractLending(_to,_idContract).amountAvvalible
            
        );

    }
    function _deleteContract(address _to,uint _idContract)internal contractOwner(_to, _idContract){
       require(
            _findContractLending(_to,_idContract)._amountBorrow == 0, "Contract have asset in borrow"
        ); 
        uint amountRepay = userLendingContract[_to][_idContract].amountAvvalible;
        uint deleteId = userLendingContract[_to][_idContract].id;
        address assetWidrow =_findContractLending(_to,_idContract).asset;
        delete userLendingContract[_to][_idContract];
        if(listContractUser[_to].length > 0){
             // serch index of delete
            (uint indexDelete, bool response) = _findArrayindexContract(_to, deleteId);
            if(response){
                //clean array
                listContractUser[_to][indexDelete]=listContractUser[_to][listContractUser[_to].length -1];
                listContractUser[_to].pop();
            }
        }else{
            listContractUser[_to].pop(); // clean array
        }

       

        uint balanceContract = IERC20(assetWidrow).balanceOf(address(this)); 
        IERC20(assetWidrow).transfer(_to,amountRepay);
        require(balanceContract -amountRepay == IERC20(assetWidrow).balanceOf(address(this)));

        emit DeleteContractDeposit(_to, deleteId);


    }

   
    // EVENT 

     event NewAssetAvvalible(address indexed asset, uint timeStart);
     event NewContractDeposit(
        uint Id,
        address indexed owner,
        address indexed asset,
        uint amount,
        uint apr,
        uint  deadline,
        uint  penality,
        address indexed collateral
     );
     event IncreasContractDeposit(
        uint Id,
        uint indexed amount,
        uint indexed newAmount
     );
     event DecreasContractDeposit(
        uint Id,
        uint indexed amount,
        uint indexed newAmount
     );

     event DeleteContractDeposit(
        address indexed owner,
        uint indexed id
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
    function listContractXuser(address _user) external view returns(uint[] memory){
        return _listContractXuser(_user);
    }
    function getAssettAvvalible()external view returns (address[] memory ){
        return _getAssettAvvalible(); 
    }
    function findContractLending(address _to,uint _id)external view returns(LendingContract memory){
        return _findContractLending(_to, _id);
    }
    //// ^^^^^TESTED^^^^^
    /// vvvvvvNON TESTEDvvvvv
     function increasDeposit(uint _idContract, uint _increasAmount) external nonReentrant(){
        _increasDeposit(msg.sender, _idContract, _increasAmount);
    }
    function decreasDeposit(uint _idContract, uint _decreasAmount) external nonReentrant(){
        _decreasDeposit(msg.sender, _idContract, _decreasAmount);
    }
    function deleteContract(uint _idContract) external nonReentrant(){
        _deleteContract(msg.sender, _idContract);
    }


    // MODIFIER

    modifier contractOwner(address _to,uint _idContract){
        require(
           _findContractLending(_to,_idContract).owner == _to, "Not owner this contract" 
        );
        _;
    }


 



    
}


/**
 nonReentrant()
 onlyOwner()
 


 // REMEBER

 --> GESTIRE  
    A. caso in cui si ripaga il prestito + interessi e si ha un avvalible + alto di amount
    B. + borrowers x contratto
    C.  
 
 
 */
