const mockUsdc = artifacts.require('mockUsdc');
const mockWeth = artifacts.require('mockWeth');
const mockWbtc = artifacts.require('mockWbtc');
const LendingPage = artifacts.require('lendingPage');

const truffleAssert = require("truffle-assertions");

contract("LendingContract Borrow Function", accounts =>{
    const account = accounts[0];
    const account2 = accounts[1];
    

    // ok
    it("Take borrow + check asset and contract data ", async ()=>{
      const usdc = await mockUsdc.deployed();
      const weth = await mockWeth.deployed();
      const btc = await mockWbtc.deployed();
      const lendingP = await LendingPage.deployed();

      await lendingP.setAssettAvvalible(usdc.address)
      await lendingP.setAssettAvvalible(weth.address)
      await usdc.approve(lendingP.address,100000)
      await lendingP.deposit(
           usdc.address,// address assett lendinding
           100000,// amount
           5, // apr
           1000,//death line
           8,//penality
           weth.address, // address collateral
           2,//rate
           )
      await weth.transfer(account2,100000)
      await weth.approve(lendingP.address,100000,{from :account2})
      let result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)
      await lendingP.executeBorrow(
        1, //so gia l'id del contratto
        account,
        1454,
        weth.address,
        10000,{from:account2}
        )
      result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)  
          
    })
    it("Take borrow + check asset and contract data USDC ", async ()=>{
    const usdc = await mockUsdc.deployed();
    const weth = await mockWeth.deployed();
    const btc = await mockWbtc.deployed();
    const lendingP = await LendingPage.deployed();

    await weth.approve(lendingP.address,100000)
    await lendingP.deposit(
         weth.address,// address assett lendinding
         100000,// amount
         5, // apr
         1000,//death line
         8,//penality
         usdc.address, // address collateral
         4,//rate
         )
    await usdc.transfer(account2,100000)
    await usdc.approve(lendingP.address,100000,{from :account2})
    //let result  =await lendingP.findContractLending(account,1)
    //console.log("before" + result)
    await lendingP.executeBorrow(
      1, //so gia l'id del contratto
      account,
      1454,
      usdc.address,
      80000,{from:account2}
      )
    //result  =await lendingP.findContractLending(account,1)
    //console.log("before" + result)  
        
})
    it("Serch borrow position ", async ()=>{
    
      const lendingP = await LendingPage.deployed();

      const position = await lendingP.serchBorrowerPositionXContract(1,account2);
      //console.log(position)

    })
    it("Serch borrow index position ", async ()=>{

      const lendingP = await LendingPage.deployed();
  
      const position = await lendingP.serchIndexBorrowerXContract(1,account2);
      //console.log(String(position) )
  
    })
    it("are you already Client? + check befor/after ", async ()=>{
      const usdc = await mockUsdc.deployed();
      const lendingP = await LendingPage.deployed();
      const weth = await mockWeth.deployed();

      let result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)
      let position = await lendingP.serchBorrowerPositionXContract(1,account2);
      //console.log(position)
      await lendingP.executeBorrow(
        1, //so gia l'id del contratto
        account,
        128,
        weth.address,
        0,{from:account2}
        )
      result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result) 
      position = await lendingP.serchBorrowerPositionXContract(1,account2);
      //console.log(position) 
          
    })
    it("Decrease deposit + chek (yes Borrow)", async ()=>{
      const lendingP = await LendingPage.deployed();
      const usdc = await mockUsdc.deployed();
      let balance  = await usdc.balanceOf(account);
      //console.log("balance before " + String(balance))
      let result  =await lendingP.findContractLending(account,1)
      //console.log("before " + result)
      // already know idContract to increas
      await lendingP.decreasDeposit(1, 500)
      balance  = await usdc.balanceOf(account);
      //console.log("balance after " + String(balance))
      result  = await lendingP.findContractLending(account,1)
      //console.log("after" + result)       
    })
    it("Increase deposit + chek (yes borrow)", async ()=>{
      const usdc = await mockUsdc.deployed();
      const lendingP = await LendingPage.deployed();
      let balance  = await usdc.balanceOf(account);
      //console.log("balance before " + String(balance))
      let result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)
      // already know idContract to increas
      await usdc.approve(lendingP.address,5555)
      await lendingP.increasDeposit(1, 5555)
      
      balance  = await usdc.balanceOf(account);
      //console.log("balance before " + String(balance))
      result  = await lendingP.findContractLending(account,1)
      //console.log("after " + result)   
    })
  
    // REVERT
    it("Delete deposit (no borrow)", async ()=>{
      const lendingP = await LendingPage.deployed();
      
      let result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)
      const position = await lendingP.serchBorrowerPositionXContract(1,account2);
      //console.log(position)
      
      await truffleAssert.reverts(
        lendingP.deleteContract(1)
      )    
      result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)
    })
    it("decreas plus of possibility", async ()=>{
    const lendingP = await LendingPage.deployed();
    let result  =await lendingP.findContractLending(account,1)
    //console.log("before " + result)
    await truffleAssert.reverts(
       lendingP.decreasDeposit(1, 198984)
    )
    })
    it("don't borrow unlimited coin", async ()=>{
      const usdc = await mockUsdc.deployed();
      const lendingP = await LendingPage.deployed();
      const weth = await mockWeth.deployed();
      let position = await lendingP.serchBorrowerPositionXContract(1,account2);
      //console.log(position)
      await truffleAssert.reverts(
        lendingP.executeBorrow(
          1, //so gia l'id del contratto
          account,
          9999999999,
          weth.address,
          0,{from:account2}
          )
      ) 
        
    })

})