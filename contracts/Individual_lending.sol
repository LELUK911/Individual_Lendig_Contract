// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./storage.sol";
import "./interestCalculator.sol";
import "./coreFunction.sol";


contract lendingPage is CoreFunction {
    //library
    using Counters for Counters.Counter;
    //function variable
    //-------------------------------//
    constructor(uint _minpenality){
        Id.increment();
        minPenality = _minpenality;
    }
 
    // ----> User Function
    function _deposit(address _to,address _asset,uint _amount,uint _apr,uint _deadline,uint _penality,address _collateral,uint _rateCollateral)internal {
        require(_to != address(0), "invalid address");
        require(_asset != _collateral, "collateral not valid");
        require(_findAsset(_asset),"asset don't found");
        //TEST require(addressPriceFeed[_asset] != address(0),"Pricefeed address miss, whait owner set address priceFeed for this asset");
        require(_findAsset(_collateral),"collateral don't found");
        require(IERC20(_asset).balanceOf(_to) >= _amount,"balance user low");
        require(IERC20(_asset).allowance(_to, address(this)) >= _amount,"alowance user low");
        require(_deadline > 0,"deadline must have geatee 0");
        require(_penality >=  minPenality,"penality must have geate 0");    
        IERC20(_asset).transferFrom(_to,address(this), _amount);
        // fee 0.10%
        uint contractFee = ((_amount * 10)/10000)+1;
        balanceFee[_asset] += contractFee;
        //
        LendingContract memory newContract= LendingContract(
            Id.current(),
            _to,
            false,
            _asset,
            _amount - contractFee,
            _apr,
            _deadline,
            _penality,
            _collateral,
            0,
            _rateCollateral,
            0
        );
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
        IERC20(_findContractLending(_to,_idContract).asset).transferFrom(_to,address(this), _increasAmount);
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

        IERC20(_findContractLending(_to,_idContract).asset).transfer(_to,_decreasAmount);

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
            (uint indexDelete, bool response) = _findArrayindexContract(_to, deleteId);
            if(response){
                listContractUser[_to][indexDelete]=listContractUser[_to][listContractUser[_to].length -1];
                listContractUser[_to].pop();
            }
        }else{
            listContractUser[_to].pop();
        }
          if(listContract.length > 0){
            (uint indexDelete, bool response) = _findContractAvvalible(_idContract);
            if(response){
                listContract[indexDelete] = listContract[listContract.length -1];
                listContract.pop();
            }
        }else{
            listContract.pop();
        }
        IERC20(assetWidrow).transfer(_to,amountRepay);
        emit DeleteContractDeposit(_to, deleteId);
    }
    function _lockNewBorrow(address _to,uint _idContract,bool _lock)internal contractOwner(_to, _idContract){
            userLendingContract[_to][_idContract].lock = _lock;   
       
    }
    function _increaseTimeExpire(address _to,uint _idContract, uint _timeIncreas)internal contractOwner(_to, _idContract){
            userLendingContract[_to][_idContract].duration += _timeIncreas;  
            emit newTimeExpireIncreas(_idContract, _timeIncreas);   
    }
    function _decreaseTimeExpire(address _to,uint _idContract, uint _timeIncreas)internal contractOwner(_to, _idContract){
            //require(userLendingContract[_to][_idContract].amountBorrow == 0);
            userLendingContract[_to][_idContract].duration += _timeIncreas;
            emit newTimeExpireDecreas(_idContract, _timeIncreas);     
    }
    function _liquidationCall(address _to,uint _idContract,uint _idBorrow) internal contractOwner(_to, _idContract) {
        require(borrowersXid[_idContract][_idBorrow].liquidationThreshold <= oraclePrice(borrowersXid[_idContract][_idBorrow].assetCollaterl),"thresold Liquidation price not achieved");
                 
        // 1/4 collateral
        uint liquidationAmount = borrowersXid[_idContract][_idBorrow].amountCollateral /4; // parte da liquidare
        borrowersXid[_idContract][_idBorrow].amountCollateral -= liquidationAmount;
        userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountCollateral -= liquidationAmount;
        uint premiumLiquidation = ((liquidationAmount * 5)/100)+1;
        liquidationAmount -= premiumLiquidation;
        userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountBorrow -= liquidationAmount * oraclePrice(borrowersXid[_idContract][_idBorrow].assetCollaterl);
        borrowersXid[_idContract][_idBorrow].ammounBorrow -= liquidationAmount * oraclePrice(borrowersXid[_idContract][_idBorrow].assetCollaterl);
        borrowersXid[_idContract][_idBorrow].liquidationThreshold = _liquidationThresold(
             oraclePrice(borrowersXid[_idContract][_idBorrow].assetBorrow) * borrowersXid[_idContract][_idBorrow].ammounBorrow,
             userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].rateCollateral,
             borrowersXid[_idContract][_idBorrow].amountCollateral
             );
        IERC20(borrowersXid[_idContract][_idBorrow].assetCollaterl).transfer(
            borrowersXid[_idContract][_idBorrow].owner,
            liquidationAmount + premiumLiquidation);
     
     emit LiquidationCall(_idContract,_idBorrow,borrowersXid[_idContract][_idBorrow].assetCollaterl,liquidationAmount + premiumLiquidation);
    }
    function _collateralSeizure(uint _idContract,uint _idBorrow) internal returns(uint){
        require(borrowersXid[_idContract][_idBorrow].expiration > block.timestamp,"loan not expired");
        uint collateral = borrowersXid[_idContract][_idBorrow].amountCollateral;
        uint borrowExpired = borrowersXid[_idContract][_idBorrow].ammounBorrow;
        borrowersXid[_idContract][_idBorrow].amountCollateral = 0;
        borrowersXid[_idContract][_idBorrow].blockStart = 0;
        borrowersXid[_idContract][_idBorrow].ammounBorrow = 0;
        if(collateral * oraclePrice(borrowersXid[_idContract][_idBorrow].assetCollaterl)<=  borrowExpired){
            userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountCollateral -= collateral;
            userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountBorrow -= borrowExpired;
            return collateral;   
        }else {
            uint contractFee = ((((collateral * oraclePrice(borrowersXid[_idContract][_idBorrow].assetCollaterl)
                    - borrowExpired *oraclePrice(borrowersXid[_idContract][_idBorrow].assetBorrow))
                    / oraclePrice(borrowersXid[_idContract][_idBorrow].assetCollaterl))*20)/100)+1;
                    
            userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountCollateral -= collateral;
            userLendingContract[borrowersXid[_idContract][_idBorrow].lender][_idContract].amountBorrow -= borrowExpired;
            balanceFee[borrowersXid[_idContract][_idBorrow].assetCollaterl] += contractFee;
            return collateral - contractFee;   
        }
    }
    function _widrowCreditExpire(address _to,uint _idContract)internal contractOwner(_to, _idContract){
        require(userLendingContract[_to][_idContract].lock == true);
        require(userLendingContract[_to][_idContract].amountCollateral ==0);
        uint widrow = userCreditExpire[_to][userLendingContract[_to][_idContract].collateral];
        userCreditExpire[_to][userLendingContract[_to][_idContract].collateral] = 0;
        IERC20(userLendingContract[_to][_idContract].collateral).transfer(_to, widrow);

        emit WidrowCredit(_to, _idContract, userLendingContract[_to][_idContract].collateral, widrow);
    }
    function _RecoverCreditsExpired(address _to,uint _idContract)internal contractOwner(_to, _idContract) {
        _lockNewBorrow(_to,_idContract,true);
        uint creditExpired;
        for(uint i; i < borrowersXid[_idContract].length ; i++){
            creditExpired+=_collateralSeizure( _idContract,i);
        }
        delete borrowersXid[_idContract] ;
        userCreditExpire[_to][userLendingContract[_to][_idContract].collateral] += creditExpired;
        emit RecoveryCredit(_idContract, userLendingContract[_to][_idContract].collateral, userCreditExpire[_to][userLendingContract[_to][_idContract].collateral]);
    }
     function _RecoverSingleCreditExpired(address _to,uint _idContract,uint _idBorrow)internal contractOwner(_to, _idContract) {
        _lockNewBorrow(_to,_idContract,true);
        
        uint singleCreditExpired;
        singleCreditExpired +=_collateralSeizure( _idContract, _idBorrow);
        
        borrowersXid[_idContract][_idBorrow] = borrowersXid[_idContract][borrowersXid[_idContract].length -1];
        borrowersXid[_idContract].pop();

        userCreditExpire[_to][userLendingContract[_to][_idContract].collateral] += singleCreditExpired; 
        emit RecoverySingleCredit(_idContract, userLendingContract[_to][_idContract].collateral, userCreditExpire[_to][userLendingContract[_to][_idContract].collateral]);
    }
    
    //BORROW FUNCTION
    function _executeBorrow(address _to,uint _idContract,address _lender,uint _amountBorrow,address _assettCollateral,uint _amountCollateral) internal {
        require(userLendingContract[_lender][_idContract].lock == false,"This lender has blocked the issuance of new Loan");
        (,bool response) = _findArrayindexContract(_lender,_idContract);
        require(response,"contract dont exist");
        require(userLendingContract[_lender][_idContract].amountAvvalible >= _amountBorrow,"Amount avvalible low");
        uint _rateLiquidation = userLendingContract[_lender][_idContract].rateCollateral;
        (bool responseSrc,uint indexBorrow) = _serchIndexBorrowerXContract(_idContract, _to);
        //check before act borrow 
        if(!responseSrc){
            _newBorrower(_to,_lender, _idContract, _assettCollateral, _amountCollateral, _amountBorrow, _rateLiquidation);
        }else{
            _oldBorrower(_to, _lender, _idContract, _assettCollateral, _amountCollateral, _amountBorrow, _rateLiquidation, indexBorrow);
        }
        emit Borrow(_to, _idContract, _amountBorrow);
    }
    function _oldBorrower(address _to,address _lender,uint _idContract,address _assettCollateral,uint _amountCollateral,uint _amountBorrow, uint _rateLiquidation,uint indexBorrow)internal {
        require(_to == borrowersXid[_idContract][indexBorrow].owner, "Not owner this loan" );
        require(
            _healFactor(
                oraclePrice( _assettCollateral)*borrowersXid[_idContract][indexBorrow].amountCollateral + _amountCollateral,
                oraclePrice(borrowersXid[_idContract][indexBorrow].assetBorrow)*(borrowersXid[_idContract][indexBorrow].ammounBorrow + _amountBorrow))
                >userLendingContract[_lender][_idContract].rateCollateral,"insufficient collateral qui"
        );
        IERC20(_assettCollateral).transferFrom(_to, address(this), _amountCollateral);
        borrowersXid[_idContract][indexBorrow].ammounBorrow += _amountBorrow;// aggiornata la variabile globale
        borrowersXid[_idContract][indexBorrow].amountCollateral += _amountCollateral;// aggiornata la variabile globale
        borrowersXid[_idContract][indexBorrow].liquidationThreshold =
                _liquidationThresold(
                    oraclePrice(borrowersXid[_idContract][indexBorrow].assetBorrow)
                    *borrowersXid[_idContract][indexBorrow].ammounBorrow,
                    _rateLiquidation,borrowersXid[_idContract][indexBorrow].amountCollateral
                    );
        userLendingContract[_lender][_idContract].amountAvvalible -=_amountBorrow;// togliamo le coin prestare
        userLendingContract[_lender][_idContract].amountBorrow += _amountBorrow; // incrementiamo il capitale prestato
        userLendingContract[_lender][_idContract].amountCollateral += _amountCollateral;// aggiungiamo la quantita di collaterale presente nel contratto
        IERC20(userLendingContract[_lender][_idContract].asset).transfer(_to, _amountBorrow);

    }
    function _newBorrower(address _to,address _lender,uint _idContract,address _assettCollateral,uint _amountCollateral,uint _amountBorrow, uint _rateLiquidation)internal {
        require(_healFactor(
            oraclePrice(_assettCollateral)*_amountCollateral,
             oraclePrice(userLendingContract[_lender][_idContract].asset)*_amountBorrow )
            > userLendingContract[_lender][_idContract].rateCollateral,"insufficient collateral amount");
        
        IERC20(_assettCollateral).transferFrom(_to, address(this), _amountCollateral);
        Borrower memory newBorrower = Borrower(
                                            _to,
                                            _idContract,
                                            userLendingContract[_lender][_idContract].asset,
                                            _amountBorrow,
                                            _assettCollateral,
                                            _amountCollateral,
                                            _liquidationThresold(
                                                oraclePrice(userLendingContract[_lender][_idContract].asset) *_amountBorrow,
                                                 _rateLiquidation,
                                                 _amountCollateral
                                                 ),
                                            block.timestamp + userLendingContract[_lender][_idContract].duration,
                                            block.timestamp,
                                            _findContractLending(_lender,_idContract).apr,
                                            _lender
                                            );
        borrowersXid[_idContract].push(newBorrower);
        userLendingContract[_lender][_idContract].amountAvvalible -=_amountBorrow;// togliamo le coin prestare
        userLendingContract[_lender][_idContract].amountBorrow += _amountBorrow; // incrementiamo il capitale prestato
        userLendingContract[_lender][_idContract].amountCollateral += _amountCollateral;// aggiungiamo la quantita di collaterale presente nel contratto
        IERC20(userLendingContract[_lender][_idContract].asset).transfer(_to, _amountBorrow);
    }
    function _executeRepay(address _to, uint _idContract,uint _amount) internal {
        require(_to  ==  _serchBorrowerPositionXContract(_idContract, _to).owner ,"Not owner this loan");
        if(block.timestamp >  _serchBorrowerPositionXContract(_idContract, _to).expiration){
            require(_penalityLoan(_amount, _to, _idContract));// gestire la penalità
        }else{
            require(_repay( _amount, _to, _idContract),"Repay error");
        }
        emit repay(_to, _idContract, _amount);
    }
    function _repay(uint _amount,address _to,uint _idContract) internal returns(bool){
            (,uint indexBorrow) = _serchIndexBorrowerXContract(_idContract, _to);

            borrowersXid[_idContract][indexBorrow].ammounBorrow = InterestCalculator._getTotalLoan(
                borrowersXid[_idContract][indexBorrow].ammounBorrow,
                borrowersXid[_idContract][indexBorrow].aprLoan,
                borrowersXid[_idContract][indexBorrow].blockStart);
            require(borrowersXid[_idContract][indexBorrow].ammounBorrow >= _amount, "You can only Loan amount");

            IERC20(borrowersXid[_idContract][indexBorrow].assetBorrow).transferFrom(_to,address(this), _amount);
               // fee 0.20%
                uint contractFee = ((_amount * 20)/10000)+1;
                balanceFee[borrowersXid[_idContract][indexBorrow].assetBorrow] += contractFee;
                //
            address _lender = borrowersXid[_idContract][indexBorrow].lender;
            userLendingContract[_lender][_idContract].amountBorrow -= _amount - contractFee;
            userLendingContract[_lender][_idContract].amountAvvalible += _amount - contractFee;
            borrowersXid[_idContract][indexBorrow].ammounBorrow -= _amount - contractFee;
            borrowersXid[_idContract][indexBorrow].blockStart = block.timestamp;
            borrowersXid[_idContract][indexBorrow].liquidationThreshold = 
                _liquidationThresold(
                      borrowersXid[_idContract][indexBorrow].ammounBorrow * 
                      oraclePrice(borrowersXid[_idContract][indexBorrow].assetBorrow),
                      userLendingContract[_lender][_idContract].rateCollateral,
                      borrowersXid[_idContract][indexBorrow].amountCollateral);
            return true;
    }
    function _penalityLoan ( uint _amount,address _to,uint _idContract) internal returns(bool){
        (,uint indexBorrow) = _serchIndexBorrowerXContract(_idContract, _to);
        require(borrowersXid[_idContract][indexBorrow].expiration < block.timestamp, "This loan not expired");
        //penality 2% of pay
        uint new_amount = ((_amount *98)/100)+1;
        // fee 5%
        uint contractFee = ((new_amount * 5)/100)+1;
        new_amount -= contractFee;
        balanceFee[borrowersXid[_idContract][indexBorrow].assetBorrow] += contractFee;
        userLendingContract[borrowersXid[_idContract][indexBorrow].lender][_idContract].amountAvvalible += _amount - new_amount;// tutto /2
        require(_repay(new_amount, _to, _idContract));
        emit applyPenality(_to, _idContract,new_amount);
        return true;
    }
    // EXTERNAL FUNCTION
    function setAssettAvvalible(address _newAsset) external nonReentrant() onlyOwner() {
        _setAssettAvvalible(_newAsset);
        emit NewAssetAvvalible(_newAsset, block.timestamp);
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
    //deprecate
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
    function lockNewBorrow(address _to,uint _idContract,bool _lock)external nonReentrant(){
        _lockNewBorrow(_to, _idContract,_lock);
    }
    function viewAmountLoan(address  _borrower,uint _idContract) external view returns(uint loanCompouse) {
        loanCompouse = InterestCalculator._getTotalLoan(
            _serchBorrowerPositionXContract(_idContract, _borrower).ammounBorrow,
            _serchBorrowerPositionXContract(_idContract, _borrower).aprLoan,
            _serchBorrowerPositionXContract(_idContract, _borrower).blockStart); 
    }
    function executeRepay(uint _idContract,uint _amount) external nonReentrant(){
        _executeRepay(msg.sender, _idContract, _amount);
    }
    function increaseTimeExpire(uint _idContract, uint _timeIncreas)external nonReentrant(){
          _increaseTimeExpire(msg.sender, _idContract, _timeIncreas);
    }
    function decreaseTimeExpire(uint _idContract, uint _timeIncreas)external nonReentrant(){
          _decreaseTimeExpire(msg.sender, _idContract, _timeIncreas);
    }
    function liquidationCall(uint _idContract,uint _idBorrow) external nonReentrant(){
        _liquidationCall(msg.sender,_idContract,_idBorrow);
    }
    function viewListcontract()external view returns(uint[] memory list){
        list = listContract;
    }
    //// vvvvvv NO TESTED vvvvvvv
    function widrowCreditExpire(uint _idContract)external nonReentrant(){    
        _widrowCreditExpire(msg.sender, _idContract);
    }
    function recoverCreditsExpired(uint _idContract)external nonReentrant(){
        _RecoverCreditsExpired(msg.sender, _idContract);
    }
    function recoverSingleCreditExpired(uint _idContract,uint _idBorrow)external nonReentrant() {
        _RecoverSingleCreditExpired(msg.sender, _idContract, _idBorrow);
    }






    event widrwCollateralLoan(uint _amount,address indexed _asset,uint indexed _idContract);
    function _widrowCollateral(uint _amount,address _to,uint _idContract) internal {
            require(_to  ==  _serchBorrowerPositionXContract(_idContract, _to).owner ,"Not owner this loan");
            (,uint indexBorrow) = _serchIndexBorrowerXContract(_idContract, _to);
            borrowersXid[_idContract][indexBorrow].ammounBorrow = InterestCalculator._getTotalLoan(
                borrowersXid[_idContract][indexBorrow].ammounBorrow,
                borrowersXid[_idContract][indexBorrow].aprLoan,
                borrowersXid[_idContract][indexBorrow].blockStart);
            require(borrowersXid[_idContract][indexBorrow].ammounBorrow >= _amount, "You can only Loan amount");
            address _lender = borrowersXid[_idContract][indexBorrow].lender;
            require(
                _healFactor(
                    oraclePrice(
                        borrowersXid[_idContract][indexBorrow].assetCollaterl)*borrowersXid[_idContract][indexBorrow].amountCollateral -_amount,
                    oraclePrice(
                        borrowersXid[_idContract][indexBorrow].assetBorrow)*borrowersXid[_idContract][indexBorrow].ammounBorrow
                        ) >  userLendingContract[_lender][_idContract].rateCollateral,"This widrow compromises your loan"   
            );

            userLendingContract[_lender][_idContract].amountCollateral -= _amount;
            borrowersXid[_idContract][indexBorrow].blockStart = block.timestamp;
            borrowersXid[_idContract][indexBorrow].liquidationThreshold = 
                _liquidationThresold(
                      borrowersXid[_idContract][indexBorrow].ammounBorrow * 
                      oraclePrice(borrowersXid[_idContract][indexBorrow].assetBorrow),
                      userLendingContract[_lender][_idContract].rateCollateral,
                      userLendingContract[_lender][_idContract].amountCollateral
                      );

            IERC20(borrowersXid[_idContract][indexBorrow].assetCollaterl).transfer(_to, _amount);
            emit widrwCollateralLoan(_amount,borrowersXid[_idContract][indexBorrow].assetCollaterl, _idContract);

    }

 
   
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

     event repay(address indexed _to, uint indexed _idContract,uint _amount);
     event applyPenality(address indexed _to,uint  indexed _idContract,uint _amount);

     event newTimeExpireIncreas(uint indexed _idContract, uint indexed _timeIncreas);
     event newTimeExpireDecreas(uint indexed _idContract, uint indexed _timeIncreas);
     event LiquidationCall (uint indexed _idContract,uint indexed _idBorrow, address assetsLiquidate, uint amount);

     event RecoveryCredit(uint indexed _idContract,address indexed collateral, uint amount);
     event RecoverySingleCredit(uint indexed _idContract,address indexed collateral, uint amount);
     event WidrowCredit(address indexed _to,uint indexed _idContract,address indexed collateral, uint amount);

    
    
    // mock function

    //function _mockOracleBorrow() internal pure returns(uint price){
    //    price = 2;
    //}

    //function _mockOracleCollateral() internal pure returns(uint price){
    //    price = 1;
//
    //}


}





  
        // devo vedere se  il collaterale è abbastanza da coprire il prestito 

        // valore del collaterale in dollari 
        //uint valoreCollaterale = oraclePrice(_assettCollateral)* _amountCollateral;
        ////valore prestito in dollari
        //uint valorePrestito = oraclePrice(userLendingContract[_lender][_idContract].asset)*_amountBorrow;
        //uint rate = userLendingContract[_lender][_idContract].rateCollateral;
        //require(valoreCollaterale/valorePrestito > rate, "mi sono rotto le palle" );

        //require(
        //    oraclePrice(_assettCollateral)*_amountCollateral/
        //    oraclePrice(userLendingContract[_lender][_idContract].asset)*_amountBorrow 
        //     > userLendingContract[_lender][_idContract].rateCollateral,"qui"
        //);
