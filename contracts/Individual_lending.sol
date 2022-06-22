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
    mapping(address => mapping(uint=>LendingContract)) private userLendingContract;
    mapping(address => uint[])listContractUser;
    uint[] private listContract;
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
    mapping(uint => Borrower[]) private borrowersXid;
    //mapping(address => mapping(uint=>Borrower)) private BorrowerContract;


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
    function _findContractAvvalible(uint _IdFind)internal view returns(uint,bool){
         uint index = 0;
         bool response = false;
         for(uint i=0 ;i<listContract.length;i++){
             if (_IdFind == listContract[i]){
                 index = i;
                 response = true;
             }
         }
         return (index,response);
     
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
   
    // ----> User Function
    function _deposit(address _to,address _asset,uint _amount,uint _apr,uint _deadline,uint _penality,address _collateral,uint _rateCollateral)internal {
        //check
        require(_to != address(0), "invalid address");
        require(_asset != _collateral, "collateral not valid");
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
            false,
            _asset,
            //_amount,
            _amount,
            _apr,
            _deadline,
            _penality,
            _collateral,
            0,
            _rateCollateral,
            0
        );
        // update status global variable
        userLendingContract[_to][Id.current()] = newContract;
        emit NewContractDeposit(
            Id.current(),_to,_asset,_amount,_apr,_deadline,_penality, _collateral
        );
        listContractUser[_to].push(Id.current());
        listContract.push(Id.current());
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
            _findContractLending(_to,_idContract).amountAvvalible >= _decreasAmount, "Assett avvalible insufficient for this whidrow"
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
            _findContractLending(_to,_idContract).amountBorrow == 0, "Contract have asset in borrow"
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
          if(listContract.length > 0){
             // serch index of delete
            (uint indexDelete, bool response) = _findContractAvvalible(_idContract);
            if(response){
                //clean array
                listContract[indexDelete] = listContract[listContract.length -1];
                listContract.pop();
            }
        }else{
            listContract.pop(); // clean array
        }
        uint balanceContract = IERC20(assetWidrow).balanceOf(address(this)); 
        IERC20(assetWidrow).transfer(_to,amountRepay);
        require(balanceContract -amountRepay == IERC20(assetWidrow).balanceOf(address(this)));

        emit DeleteContractDeposit(_to, deleteId);
    }
    function _lockNewBorrow(address _to,uint _idContract,bool _lock)internal contractOwner(_to, _idContract){
             lock[_idContract] = _lock;
            //userLendingContract[_to][_idContract].lock = _lock;   
       
    }
  
    //BORROW FUNCTION
    function _executeBorrow(address _to,uint _idContract,address _lender,uint _amountBorrow,address _assettCollateral,uint _amountCollateral) internal {
        require(lock[_idContract] == false, "questo funziona");
        require(userLendingContract[_to][_idContract].lock == false,"This lender has blocked the issuance of new Loan");
        (,bool response) = _findArrayindexContract(_lender,_idContract);
        require(response,"contract dont exist");
        require(userLendingContract[_lender][_idContract].amountAvvalible >= _amountBorrow,"Amount avvalible low");
        //// controll and utility  local var
        //uint _priceCollateralETH = _mockOracleCollateral();// fix with true oracle
        uint _priceBorrowEth = _mockOracleBorrow();// fix with true oracle
        uint _rateLiquidation = userLendingContract[_lender][_idContract].rateCollateral;
        (bool responseSrc,uint indexBorrow) = _serchIndexBorrowerXContract(_idContract, _to);
        //check before act borrow 
      
    
        if(!responseSrc){
            _newBorrower(_to,_lender, _idContract, _assettCollateral, _amountCollateral, _amountBorrow, _rateLiquidation);
        }else{
            require(_liquidationThresold(
                          //_priceCollateralETH*borrowersXid[_idContract][indexBorrow].ammounBorrow,
                          _priceBorrowEth*borrowersXid[_idContract][indexBorrow].amountCollateral,
                           _rateLiquidation) > _mockOracleBorrow());
            _oldBorrower(_to, _lender, _idContract, _assettCollateral, _amountCollateral, _amountBorrow, _rateLiquidation, indexBorrow);

        }

        emit Borrow(_to, _idContract, _amountBorrow);
    }

    function _oldBorrower(address _to,address _lender,uint _idContract,address _assettCollateral,uint _amountCollateral,uint _amountBorrow, uint _rateLiquidation,uint indexBorrow)internal {
        // gia cliente??
        // aggiorniamo i conti vecchi 
        // aggiungere al controllo le coin gia depositate e prese in prestito 
        require(_to == borrowersXid[_idContract][indexBorrow].owner, "Not owner this loan" );
        require(_healFactor(_mockOracleCollateral() *(borrowersXid[_idContract][indexBorrow].amountCollateral + _amountCollateral),
                             _mockOracleBorrow() *(borrowersXid[_idContract][indexBorrow].ammounBorrow + _amountBorrow)
                             )> userLendingContract[_lender][_idContract].rateCollateral); 

        uint balanceBefore = IERC20(_assettCollateral).balanceOf(address(this));
            IERC20(_assettCollateral).transferFrom(_to, address(this), _amountCollateral);
            require( balanceBefore + _amountCollateral == IERC20(_assettCollateral).balanceOf(address(this)));

            borrowersXid[_idContract][indexBorrow].ammounBorrow += _amountBorrow;// aggiornata la variabile globale
            borrowersXid[_idContract][indexBorrow].amountCollateral += _amountCollateral;// aggiornata la variabile globale
            // updata thresoldLiquidation 
            borrowersXid[_idContract][indexBorrow].liquidationThreshold =
                    _liquidationThresold(
                        //_mockOracleCollateral()*borrowersXid[_idContract][indexBorrow].amountCollateral,
                        _mockOracleBorrow()*borrowersXid[_idContract][indexBorrow].ammounBorrow,
                         _rateLiquidation);

            userLendingContract[_lender][_idContract].amountAvvalible -=_amountBorrow;// togliamo le coin prestare
            userLendingContract[_lender][_idContract].amountBorrow += _amountBorrow; // incrementiamo il capitale prestato
            userLendingContract[_lender][_idContract].amountCollateral += _amountCollateral;// aggiungiamo la quantita di collaterale presente nel contratto
            //BorrowerContract[_to][indexBorrow] = borrowersXid[_idContract][indexBorrow];
            IERC20(userLendingContract[_lender][_idContract].asset).transfer(_to, _amountBorrow);

    }

    function _newBorrower(address _to,address _lender,uint _idContract,address _assettCollateral,uint _amountCollateral,uint _amountBorrow, uint _rateLiquidation)internal {
        // nuovo cliente????
        // conti nuovi
        require(_healFactor(_mockOracleCollateral() * _amountCollateral, _mockOracleBorrow()*_amountBorrow) > userLendingContract[_lender][_idContract].rateCollateral);
        // spreco di gas????
        uint balanceBefore = IERC20(_assettCollateral).balanceOf(address(this));
        IERC20(_assettCollateral).transferFrom(_to, address(this), _amountCollateral);
        require( balanceBefore + _amountCollateral == IERC20(_assettCollateral).balanceOf(address(this)));
        // preparazione dei dati del borrower non ancora settat nella variabile locale
        Borrower memory newBorrower = Borrower(
                                            _to,
                                            _idContract,
                                            userLendingContract[_lender][_idContract].asset,
                                            _amountBorrow,
                                            //uint heltBorrow;
                                            _assettCollateral,
                                            _amountCollateral,
                                            _liquidationThresold(
                                                //_mockOracleCollateral()*_amountCollateral,
                                                 _mockOracleBorrow()*_amountBorrow,
                                                 _rateLiquidation),
                                            block.timestamp + userLendingContract[_lender][_idContract].duration,
                                            block.timestamp,
                                            _findContractLending(_lender,_idContract).apr,
                                            _lender

                                            );

        borrowersXid[_idContract].push(newBorrower);// aggiornata la variabile locale
        // aggiorniamo i dati del lender

        userLendingContract[_lender][_idContract].amountAvvalible -=_amountBorrow;// togliamo le coin prestare
        userLendingContract[_lender][_idContract].amountBorrow += _amountBorrow; // incrementiamo il capitale prestato
        userLendingContract[_lender][_idContract].amountCollateral += _amountCollateral;// aggiungiamo la quantita di collaterale presente nel contratto
        //BorrowerContract[_to][borrowersXid[_idContract].length] = newBorrower;
        IERC20(userLendingContract[_lender][_idContract].asset).transfer(_to, _amountBorrow);
    }
    
    // EXTERNAL FUNCTION
    function setAssettAvvalible(address _newAsset) external nonReentrant() onlyOwner() {
        _setAssettAvvalible(_newAsset);
    } 
    function findAsset(address _asset) external view returns(bool){
        return _findAsset(_asset);
    }
    function deposit(address _asset,uint _amount,uint _apr,uint _deadline,uint _penality,address _collateral,uint _rateCollateral) external nonReentrant() {
        _deposit(msg.sender, _asset, _amount, _apr, _deadline, _penality, _collateral,_rateCollateral);
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
     function increasDeposit(uint _idContract, uint _increasAmount) external nonReentrant(){
        _increasDeposit(msg.sender, _idContract, _increasAmount);
    }
    function decreasDeposit(uint _idContract, uint _decreasAmount) external nonReentrant(){
        _decreasDeposit(msg.sender, _idContract, _decreasAmount);
    }
    function deleteContract(uint _idContract) external nonReentrant(){
        _deleteContract(msg.sender, _idContract);
    }
     function executeBorrow(uint _idContract,address _lender,uint _amountBorrow,address _assettCollateral,uint _amountCollateral) external nonReentrant(){
        _executeBorrow(msg.sender, _idContract, _lender, _amountBorrow, _assettCollateral, _amountCollateral);
    }
    function serchBorrowerPositionXContract(uint _idContract,address _borrower) external view returns (Borrower memory){
        return _serchBorrowerPositionXContract(_idContract, _borrower);

    }
    function serchIndexBorrowerXContract(uint _idContract,address _borrower)external view returns(uint){
        (,uint idFind) = _serchIndexBorrowerXContract(_idContract, _borrower);
        return idFind;
    }
    mapping ( uint => bool) private lock;
    function lockNewBorrow(address _to,uint _idContract,bool _lock)external nonReentrant(){
       
        _lockNewBorrow(_to, _idContract,_lock);
    }

    //// ^^^^^TESTED^^^^^
    /// vvvvvvNON TESTEDvvvvv
   
    // MODIFIER
    modifier contractOwner(address _to,uint _idContract){
        require(
           _findContractLending(_to,_idContract).owner == _to, "Not owner this contract" 
        );
        _;
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
     event Borrow( address indexed Borrower,uint indexed Id_Contract, uint amount);

    // mock function

    function _mockOracleBorrow() internal pure returns(uint price){
        price = 2;
    }

    function _mockOracleCollateral() internal pure returns(uint price){
        price = 1;

    }


    //wiew amount of repay 
    function viewAmountLoan(address  _borrower,uint _idContract) external view returns(uint loanCompouse) {
        Borrower memory loanSituation = _serchBorrowerPositionXContract(_idContract, _borrower);
        uint apr = loanSituation.aprLoan;
        uint blockStart = loanSituation.blockStart; 
        loanCompouse= _getTotalLoan(loanSituation.ammounBorrow,apr,blockStart); 
        }


    // return loan + interest
    function _getTotalLoan(uint _loan,uint _apr,uint _blockStart) internal  view returns(uint) {
    uint deltaTime = block.timestamp - _blockStart;
    uint loanCompouse = _loan + uint((_loan*_apr*deltaTime) / (100*365*24*60*60)) + 1;
    //uint interestLoan = loanCompouse - _loan;
    return loanCompouse;
    }

    // return only interest
    function _getinterest(uint _loan,uint _apr,uint _blockStart) internal  view returns(uint interestLoan) {
        interestLoan = _getTotalLoan(_loan, _apr, _blockStart) - _loan;
    }
  

    function _executeRepay(address _to, uint _idContract,uint _amount) internal {
        Borrower memory loanSituation = _serchBorrowerPositionXContract(_idContract, _to);
        require(_to  == loanSituation.owner ,"Not owner this loan");

        if(block.timestamp > loanSituation.expiration){
            require(_penalityLoan(loanSituation, _amount, _to, _idContract));// gestire la penalità
        }else{
            require(_repay(loanSituation, _amount, _to, _idContract),"Repay error");
        }
    }

    function _repay(Borrower memory loanSituation, uint _amount,address _to,uint _idContract) internal returns(bool){
        // portiamo ad adesso la situazione
            loanSituation.ammounBorrow = _getTotalLoan(
                loanSituation.ammounBorrow,loanSituation.aprLoan,loanSituation.blockStart);
            // ripagando si ricomincia il calcolo degli interessi come fosse un prestito nuovo
            require(loanSituation.ammounBorrow >= _amount, "You can only Loan amount");

            uint Balance = IERC20(loanSituation.assetBorrow).balanceOf(address(this));
            IERC20(loanSituation.assetBorrow).transferFrom(_to,address(this), _amount);
            assert(Balance + _amount == IERC20(loanSituation.assetBorrow).balanceOf(address(this)));

            // receipt the "ternis" update the data lender and borrower
            address _lender = loanSituation.lender;
            userLendingContract[_lender][_idContract].amountBorrow -= _amount;
            userLendingContract[_lender][_idContract].amountAvvalible += _amount;

            (,uint indexBorrow) = _serchIndexBorrowerXContract(_idContract, _to);


            borrowersXid[_idContract][indexBorrow].ammounBorrow -= _amount;
            borrowersXid[_idContract][indexBorrow].blockStart = block.timestamp;
            borrowersXid[_idContract][indexBorrow].liquidationThreshold = 
                _liquidationThresold(
                      borrowersXid[_idContract][indexBorrow].ammounBorrow * _mockOracleBorrow(),
                      userLendingContract[_lender][_idContract].rateCollateral);
            return true;
    }
      function _penalityLoan (Borrower memory loanSituation, uint _amount,address _to,uint _idContract) internal returns(bool){
        require(loanSituation.expiration < block.timestamp, "This loan not expired");
        //penality 2% of pay
        uint new_amount = (_amount *88)/100;
        // per ora va tutto al lendere ma poi ci applichiamo delle fee
        userLendingContract[loanSituation.lender][_idContract].amountAvvalible += _amount - new_amount;// tutto /2
        // balanceContract[assett] += (_amount - new_amount)/2
        require(_repay(loanSituation, new_amount, _to, _idContract));
        return true;
    }
    

    function _increaseTimeExpire(address _to,uint _idContract, uint _timeIncreas)internal contractOwner(_to, _idContract){
            userLendingContract[_to][_idContract].duration += _timeIncreas;     
    }
    function _decreaseTimeExpire(address _to,uint _idContract, uint _timeIncreas)internal contractOwner(_to, _idContract){
            require(userLendingContract[_to][_idContract].amountBorrow == 0);
            userLendingContract[_to][_idContract].duration += _timeIncreas;     
    }


    function _liquidationCall(address _to,uint _idContract,uint _idBorrow) internal contractOwner(_to, _idContract) {
        require(borrowersXid[_idContract][_idBorrow].liquidationThreshold <= _mockOracleCollateral(),"thresold Liquidation price not achieved");
        // 1/4 viene lioquidato
        uint liquidationAmount = borrowersXid[_idContract][_idBorrow].amountCollateral /4; // parte da liquidare
        // tolgo dalla posizione del borrower il collaterale liquidato (quidni non puo prelevare)
        borrowersXid[_idContract][_idBorrow].amountCollateral -= liquidationAmount;
        // dallo status contratto tolgo il collaterale perche diventa prelevabile
        userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountCollateral -= liquidationAmount;
        // riduco il credito del lender
        userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountBorrow -= liquidationAmount * _mockOracleCollateral();
        // riduco il debito del borrower
        borrowersXid[_idContract][_idBorrow].ammounBorrow -= liquidationAmount * _mockOracleCollateral();
        // aggiorniamo il ThresoldLiquidation
        borrowersXid[_idContract][_idBorrow].liquidationThreshold = _liquidationThresold(
             _mockOracleBorrow() * borrowersXid[_idContract][_idBorrow].ammounBorrow,
             userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].rateCollateral
             );
        // rendo prelevabile il collaterale
        liquidationContract[borrowersXid[_idContract][_idBorrow].owner][borrowersXid[_idContract][_idBorrow].assetCollaterl] += liquidationAmount;

     
    }

    mapping (address=> mapping(address=> uint)) liquidationContract;








    function executeRepay(uint _idContract,uint _amount) external nonReentrant(){
        _executeRepay(msg.sender, _idContract, _amount);
    }







    function increaseTimeExpire(uint _idContract, uint _timeIncreas)external nonReentrant(){
          _increaseTimeExpire(msg.sender, _idContract, _timeIncreas);
    }
    function decreaseTimeExpire(uint _idContract, uint _timeIncreas)external nonReentrant(){
          _decreaseTimeExpire(msg.sender, _idContract, _timeIncreas);
    }

/**
    3 -> Ripagare il Borrow e cambiare il margine
            -> Applicare qui la Fee ? 

    4 -> Liquidazione collatterale, 
            -> problema -> Calcolo matematico 
            -> Quanto liquidare?
            -> Come cambiano i valori dopo la liquidazione?
            -> Voglio dare al lender la possibilità di vendere a mercato la liquidazione? 
            -> Gestione delle fee da pagare al protocollo 
    
    5 -> a carico di chi sono le fee? lender o borrower ?
            -> dove prendere le fee? 
                -> dall interesse del lender
                    -> come lo calcolo?
                    -> quando le prendo ?
                -> dal pagamento del debito ? 
                    -> è più vantaggioso progettualmente
                    -> è competitiva come strategia?
            -> HOW MUCH ????
                -> 0.50% su ogni pagamento ???? -> tariffa standard
                -> 1% fino al 5%        Tariffa liquidazione
                -> 2% dal 5% al 10%     Tariffa liquidazione
                -> 4% dal 10% al 20%    Tariffa liquidazione
                -> 5% dal 20% al 30%    Tariffa liquidazione
                -> 6% dal 30% al 100%   Tariffa liquidazione
                    -> Vendere a mercato e realizare subito usd?
                    -> detenere gli asset? 
                    -> miso detenere blue chips e dumpare il resto.ò
 

 nonReentrant()
 onlyOwner()
 


 
 */
}