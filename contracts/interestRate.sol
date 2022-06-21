// SPDX-License-Identifier: Leluk911
pragma solidity 0.8.7;

library Interest {

  function getTotalLoan(uint _loan,uint _apr,uint _blockStart) internal  view returns(uint) {
    uint deltaTime = block.timestamp - _blockStart;
    uint loanCompouse = _loan + uint((_loan*_apr*deltaTime) / (100*365*24*60*60)) + 1;
    //uint interestLoan = loanCompouse - _loan;
    return loanCompouse;
  
  }

}