/* FINAL TEST
    Test include all before test whit all function implementation
    
    N.B. : 
        -> Oracle function are mock
        -> some variable and situation are set with arbitrari function.



        verfy CALCUL APR  in library
        Come trovare tutti i dati per metterli nel front end e cercare i prestiti 
*/
const mockUsdc = artifacts.require('mockUsdc');
const mockWeth = artifacts.require('mockWeth');
const mockWbtc = artifacts.require('mockWbtc');
const LendingPage = artifacts.require('lendingPage');

const truffleAssert = require("truffle-assertions");

const decimal = "000000000000000000"

contract("FINAL TEST",async accounts =>{
    const account = accounts[0]; // OWNER
    const account1 = accounts[1];// start => 1kk all asset. => deposit
    const account2 = accounts[2];// start => 1kk all asset. => deposit
    const account3 = accounts[3];// start => 1kk all asset. => deposit
    const account4 = accounts[4];// start => 1kk all asset. => loan
    const account5 = accounts[5];// start => 1kk all asset. => loan
    const account6 = accounts[6];// start => 1kk all asset. => 
    const account7 = accounts[7];// start => 1kk all asset. =>

    it("Owner Set NewAsset ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();

        await lendingP.setAssettAvvalible(usdc.address)
        await lendingP.setAssettAvvalible(weth.address)
        await lendingP.setAssettAvvalible(btc.address)

        // SET MOCK PRICE Moralis.Units.Token("0.5", "18")
        await lendingP.setMockPrice(usdc.address,"1000000000000000000")// price usd  1$
        await lendingP.setMockPrice(weth.address,"1063390000000000000000")// price eth 1063.39$
        await lendingP.setMockPrice(btc.address,"19355130000000000000000")// price btc 19355.13$
  
    })
    it("transfer asset for test", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();

        await usdc.transfer(account1, "1000000000000000000000000");
        await weth.transfer(account1, "1000000000000000000000000");  
        await  btc.transfer(account1, "1000000000000000000000000");      

        await usdc.transfer(account2, "1000000000000000000000000");
        await weth.transfer(account2, "1000000000000000000000000");  
        await  btc.transfer(account2, "1000000000000000000000000");      

        await usdc.transfer(account3, "1000000000000000000000000");
        await weth.transfer(account3, "1000000000000000000000000");  
        await  btc.transfer(account3, "1000000000000000000000000");      

        await usdc.transfer(account4, "1000000000000000000000000");
        await weth.transfer(account4, "1000000000000000000000000");  
        await  btc.transfer(account4, "1000000000000000000000000");      

        await usdc.transfer(account5, "1000000000000000000000000");
        await weth.transfer(account5, "1000000000000000000000000");  
        await  btc.transfer(account5, "1000000000000000000000000");      

        await usdc.transfer(account6, "1000000000000000000000000");
        await weth.transfer(account6, "1000000000000000000000000");  
        await  btc.transfer(account6, "1000000000000000000000000");      
        
        await usdc.transfer(account7, "1000000000000000000000000");
        await weth.transfer(account7, "1000000000000000000000000");  
        await  btc.transfer(account7, "1000000000000000000000000");      

    })
    it("Create  new lending Contract Account 1 ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed(); 
        const lendingP = await LendingPage.deployed();

        //account1

        // deposit 100k usdc  rate 2 apr 4.5%  penality 8% btc collateral
        // deposit 10 btc  rate 5 apr 10%  penality 10%  weth collateral
        
        await usdc.approve(lendingP.address,"100000000000000000000000",{from:account1})
        
        await lendingP.deposit(
             usdc.address,
             "100000000000000000000000",// amount
             4.5*100, // apr
             3600,//death line
             8,//penality
             btc.address, // address collateral
             2,//rate
             {from:account1}
           )

        await btc.approve(lendingP.address,"10000000000000000000",{from:account1})
        await lendingP.deposit(
             btc.address,
             "10000000000000000000",
             5*100,
             5184000,
             10,
             usdc.address,
             4,
             {from:account1}
            )

        //
                
            
    })
    it("Create  new lending Contract Account 2 ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed(); 
        const lendingP = await LendingPage.deployed();

        //account2

        // deposit 1.000.000 weth  rate 3 apr 0.25%  penality 5%  usdc collateral
        // deposit 240.000 usdc  rate 4 apr 1.25%  penality 7%  weth collateral
        
        await weth.approve(lendingP.address,"1000000000000000000000000",{from:account2})
        
        await lendingP.deposit(weth.address,"1000000000000000000000000",0.25*100, 155163541,5,usdc.address, 3,{from:account2})

        await btc.approve(lendingP.address,"240000"+decimal,{from:account2})
        await lendingP.deposit(btc.address,"240000"+decimal,1.25*100,5183200,5,weth.address,7,{from:account2})

        //
                
            
    })
    it("Create  new lending Contract Account 3 ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed(); 
        const lendingP = await LendingPage.deployed();

        //account3

        // deposit 100 weth  rate 3 apr 0.25%  penality 5%  usdc collateral
        
        await weth.approve(lendingP.address,"100" + decimal,{from:account3})
        
        await lendingP.deposit(weth.address,"100"+decimal,6.25*100,1334541,10,usdc.address,4,{from:account3})       
    })
    it("Increase  one deposit + chek (no borrow)", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed(); 
      
        const lendingP = await LendingPage.deployed();

        let result  = await lendingP.findContractLending(account2,4)
        //console.log("before" + result)
        
        await usdc.approve(lendingP.address,"124560"+decimal,{from:account2})
        await weth.approve(lendingP.address,"124560"+decimal,{from:account2})
        await btc.approve(lendingP.address,"124560"+decimal,{from:account2})

        await lendingP.increasDeposit(4,"12456"+decimal,{from:account2})
          
        result  = await lendingP.findContractLending(account2,4)
        //console.log("after " + result)   
    })
    it("Decrease deposit + chek (no Borrow)", async ()=>{
        const lendingP = await LendingPage.deployed();
  
        let result  = await lendingP.findContractLending(account1,2)
        //console.log("before " + result)
        
        await lendingP.decreasDeposit(2, "2"+decimal,{from:account1})
  
        result  = await lendingP.findContractLending(account1,2)
        //console.log("after" + result)       
    })
    it("Lock contract + chek (no Borrow)", async ()=>{
        const lendingP = await LendingPage.deployed();
        
        let result  =await lendingP.findContractLending(account1,1)
        //console.log("before " + result)
  
        await lendingP.lockNewBorrow(account1,1,true,{from:account1})   
  
        result  = await lendingP.findContractLending(account1,1)
        //console.log("after lock" + result)       
    })
    it("Delete deposit (no borrow)", async ()=>{
        const lendingP = await LendingPage.deployed();
        //account3

        let list = await lendingP.viewListcontract();
        //console.log(JSON.stringify(list))
        await lendingP.deleteContract(1,{from:account1})
        let result  = await lendingP.findContractLending(account1,1)
        //console.log("after" + result)
        list = await lendingP.viewListcontract();
        //console.log(JSON.stringify(list))       
    })
    it("Incread time expire + chek (no Borrow)", async ()=>{
        const lendingP = await LendingPage.deployed();
        let result  =await lendingP.findContractLending(account3,5)
        //console.log("before " + result)
  
        await lendingP.increaseTimeExpire(5,154487,{from:account3})   
  
        result  = await lendingP.findContractLending(account3,5)
        //console.log("after" + result)       
    })
    it("Decreas time expire + chek (no Borrow)", async ()=>{
        const lendingP = await LendingPage.deployed();
        let result  = await lendingP.findContractLending(account2,4)
        //console.log("before " + result)
  
        await lendingP.decreaseTimeExpire(4,999,{from:account2})   
  
        result  = await lendingP.findContractLending(account2,4)
        //console.log("after" + result)       
    })
    
    //SEARCH FUNCTION
    it("Question function ->find Asset <-", async ()=>{
        const lendingP = await LendingPage.deployed();
  
        const listAssett = await lendingP.getAssettAvvalible()
       
        //console.log(listAssett) CHECK OK
    })
    it("Question function ->listContractXuser<-", async ()=>{
        const lendingP = await LendingPage.deployed();
  
        const listContract = await lendingP.listContractXuser(account1)
       
        const parseList = listContract.map((data)=>{return String(data)})
        //console.log(parseList) //CHECK OK
    })
    it("Question function ->findContractLending<-", async ()=>{
        const lendingP = await LendingPage.deployed();
  
        const listContract = await lendingP.listContractXuser(account3)
       
        const parseList = listContract.map((data)=>{return Number(data)})
  
        for (let index = 0; index < parseList.length; index++) {
            const result  =await lendingP.findContractLending(account3,parseList[index])
            //console.log(result) //CHECK
          }
    })
    // REVERT
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

     //BORROW FUNCTION
    it("Take borrow + check asset and contract data accounta 4 ", async ()=>{
        // single loan position
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();
        
        // per i valori minimi di collaterale / max prestito ce ne occupiamo nel front-end
        await weth.approve(lendingP.address,"200"+decimal,{from :account4})
        await lendingP.executeBorrow(2,account1,'2'+decimal,weth.address,'200'+decimal,{from:account4})
        let result  =await lendingP.findContractLending(account1,2)
        //console.log("Take loan contract Id 2 " + result) 
        let position = await lendingP.serchBorrowerPositionXContract(2,account4)
        console.log(position)
            
    })
    it("Take borrow + check asset and contract data accounta 5 ", async ()=>{
        // take usdc from contract 4 
        // dep usdc in contract 3 and loan weth 
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();
        
        const result  =await lendingP.findContractLending(account2,4)
        //console.log(result) //CHECK
        await weth.approve(lendingP.address,'2000'+decimal,{from:account5})
        await lendingP.executeBorrow(4,account2,'1000'+decimal,weth.address,"17"+decimal,{from:account5})
        result  = await lendingP.findContractLending(account2,4)
        console.log(result)

        await weth.approve(lendingP.address,'200'+decimal,{from:account5})
        await lendingP.executeBorrow(3,account2,'2'+decimal,weth.address,"200"+decimal,{from:account5})

        //result  = await lendingP.findContractLending(account2,3)
        console.log(result)
      
    
    
    
    
    })
    //SEARCH

})
