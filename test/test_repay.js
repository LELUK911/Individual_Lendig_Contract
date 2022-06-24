const mockUsdc = artifacts.require('mockUsdc');
const mockWeth = artifacts.require('mockWeth');
const mockWbtc = artifacts.require('mockWbtc');
const LendingPage = artifacts.require('lendingPage');

const truffleAssert = require("truffle-assertions");

contract("Repay Function and aftermath", accounts =>{
  const account = accounts[0];
  const account2 = accounts[1];
  
  it("repay partial loan ", async ()=>{
    const usdc = await mockUsdc.deployed();
    const weth = await mockWeth.deployed();
    const lendingP = await LendingPage.deployed();

    await lendingP.setAssettAvvalible(usdc.address)
    await lendingP.setAssettAvvalible(weth.address)
    await usdc.approve(lendingP.address,100000)
    await lendingP.deposit(
         usdc.address,// address assett lendinding
         100000,// amount
         5, // apr
         10000000,//death line
         8,//penality
         weth.address, // address collateral
         2,//rate
         )
    await weth.transfer(account2,100000)
    await weth.approve(lendingP.address,100000,{from :account2})
    let result  =await lendingP.findContractLending(account,1)
    //console.log("before loan " + result)
    await lendingP.executeBorrow(
      1, //so gia l'id del contratto
      account,
      1454,
      weth.address,
      10000,{from:account2}
      )
    result  =await lendingP.findContractLending(account,1)
    //console.log("after give a loan " + result)  
    
    await usdc.approve(lendingP.address,100000,{from:account2})

    let position = await lendingP.serchBorrowerPositionXContract(1,account2);
    //console.log(position)
    await lendingP.executeRepay(1,500,{from:account2})
    position = await lendingP.serchBorrowerPositionXContract(1,account2);
    //console.log(position)

    result  =await lendingP.findContractLending(account,1)
    //console.log("after  partial loan repay " + result)

        
  })
  it("check interest loan",async ()=>{
    const lendingP = await LendingPage.deployed();

    const loanStatus  = await lendingP.viewAmountLoan(account2,1);
    //console.log(Number(loanStatus))
  })
  // in pause
  it("repay total loan ", async ()=>{
    const usdc = await mockUsdc.deployed();
    const lendingP = await LendingPage.deployed();

    await usdc.approve(lendingP.address,100000,{from:account2})

    
    let position = await lendingP.serchBorrowerPositionXContract(1,account2);
    //console.log(position)
    result  =await lendingP.findContractLending(account,1)
    //console.log("after give a loan " + result)
    // await lendingP.executeRepay(1,954,{from:account2})
    position = await lendingP.serchBorrowerPositionXContract(1,account2);
    //console.log(position)

    result  =await lendingP.findContractLending(account,1)
    //console.log("after  partial loan repay " + result)

        
  })
  it("Liquidation Call (ThresoldPrice)",async()=>{
    const lendingP = await LendingPage.deployed();



    let position = await lendingP.serchBorrowerPositionXContract(1,account2);
    console.log(position)
    result  = await lendingP.findContractLending(account,1)
    console.log("after give a loan " + result)
    await lendingP._liquidationCall(1,0);
    position = await lendingP.serchBorrowerPositionXContract(1,account2);
    console.log(position)

    result  =await lendingP.findContractLending(account,1)
    console.log("after  partial loan repay " + result)

    })

  })





    
    

     