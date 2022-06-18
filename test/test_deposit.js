const mockUsdc = artifacts.require('mockUsdc');
const mockWeth = artifacts.require('mockWeth');
const mockWbtc = artifacts.require('mockWbtc');
const LendingPage = artifacts.require('lendingPage');

const truffleAssert = require("truffle-assertions");

skip.contract("LendingContract", accounts =>{
    const account = accounts[0];
    const account2 = accounts[1];
    
    it("Owner Set NewAsset ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();

        await lendingP.setAssettAvvalible(usdc.address)
        await lendingP.setAssettAvvalible(weth.address)
        await lendingP.setAssettAvvalible(btc.address)
    })
    it("Create a new lending Contract ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const lendingP = await LendingPage.deployed();

       
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

        await weth.approve(lendingP.address,100000)
        await lendingP.deposit(
             weth.address,
             1999,
             12,
             8888,
             10,
             usdc.address,
             2,
            )
                
            
    })

    it("Increase deposit + chek (no borrow)", async ()=>{
      const usdc = await mockUsdc.deployed();
      const lendingP = await LendingPage.deployed();
      
      
      //let balance  = await usdc.balanceOf(account);
      //console.log("balance before " + String(balance))


      //let result  =await lendingP.findContractLending(account,1)
      //console.log("before" + result)
      // already know idContract to increas
      await usdc.approve(lendingP.address,5555)
      await lendingP.increasDeposit(1, 5555)
      
      //balance  = await usdc.balanceOf(account);
      //console.log("balance before " + String(balance))
//
      //result  = await lendingP.findContractLending(account,1)
      //console.log("after " + result)   
    })


    it("Decrease deposit + chek (no Borrow)", async ()=>{
      const lendingP = await LendingPage.deployed();
      const weth = await mockWeth.deployed();


      //let balance  = await weth.balanceOf(account);
      //console.log("balance before " + String(balance))
      //let result  =await lendingP.findContractLending(account,2)
      //console.log("before " + result)
      // already know idContract to increas
      await lendingP.decreasDeposit(2, 500)

      //balance  = await weth.balanceOf(account);
      //console.log("balance after " + String(balance))

      //result  = await lendingP.findContractLending(account,2)
      //console.log("after" + result)       
    })











    // SERCH FUNCTION 
    it("Question function ->find Asset <-", async ()=>{
      const lendingP = await LendingPage.deployed();

      const listAssett = await lendingP.getAssettAvvalible()
     
      //console.log(listAssett) CHECK OK
    })
    it("Question function ->listContractXuser<-", async ()=>{
      const lendingP = await LendingPage.deployed();

      const listContract = await lendingP.listContractXuser(account)
     
      const parseList = listContract.map((data)=>{return String(data)})
      // console.log(parseList) CHECK OK
    })
    it("Question function ->findContractLending<-", async ()=>{
      const lendingP = await LendingPage.deployed();

      const listContract = await lendingP.listContractXuser(account)
     
      const parseList = listContract.map((data)=>{return Number(data)})

      for (let index = 0; index < parseList.length; index++) {
          const result  =await lendingP.findContractLending(account,parseList[index])
          //console.log(result) CHECK
        }
    })



    it("Delete deposit (no borrow)", async ()=>{
      const lendingP = await LendingPage.deployed();
      const weth = await mockWeth.deployed();

  
      //let balance  = await weth.balanceOf(lendingP.address);
      //console.log("balance before" + String(balance))
      //let result  =await lendingP.findContractLending(account,2)
      //console.log("before" + result)
      // already know idContract to increas
      await lendingP.deleteContract(2)
      //balance  = await weth.balanceOf(lendingP.address);
      //console.log("balance after" + String(balance))
      //result  = await lendingP.findContractLending(account,2)
      //console.log("after" + result)       
    })
    









    // CHECK check autorization

    it("Not Autorizate Set NewAsset ", async () => {
      const usdc = await mockUsdc.deployed();
      const lendingP = await LendingPage.deployed();

      await truffleAssert.reverts(
        lendingP.setAssettAvvalible(usdc.address, { from: account2 })
      );
    });
    it("Not set one assett already push", async ()=>{
      const usdc = await mockUsdc.deployed();
      const weth = await mockWeth.deployed();
      const lendingP = await LendingPage.deployed();

      await truffleAssert.reverts(
        lendingP.setAssettAvvalible(usdc.address),
      )
    })




})