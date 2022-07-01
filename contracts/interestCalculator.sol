// SPDX-License-Identifier: Leluk911

pragma solidity 0.8.7;

library InterestCalculator {

    

    // return loan + interest
    function _getTotalLoan(uint _loan,uint _apr,uint _blockStart) internal  view returns(uint) {
    uint deltaTime = block.timestamp - _blockStart;
    uint loanCompouse = _loan + uint((_loan*_apr*deltaTime) / (100*365*24*60*60))/100 + 1;//VERIFY
    //uint interestLoan = loanCompouse - _loan;
    if(loanCompouse <= 1){
        return 0;
    }else{
    return loanCompouse;

    }
    }

    // return only interest
    function _getinterest(uint _loan,uint _apr,uint _blockStart) internal  view returns(uint interestLoan) {
        interestLoan = _getTotalLoan(_loan, _apr, _blockStart) - _loan;
    }
}

