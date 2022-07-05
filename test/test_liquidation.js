const mockUsdc = artifacts.require('mockUsdc');
const mockWeth = artifacts.require('mockWeth');
const mockWbtc = artifacts.require('mockWbtc');
const LendingPage = artifacts.require('lendingPage');

const truffleAssert = require("truffle-assertions");

const decimal = "000000000000000000"

contract("ThresoldLiquidation",async accounts =>{
    const account = accounts[0]; // OWNER
    const account1 = accounts[1];
    const account2 = accounts[2];
    const account3 = accounts[3];
 
    it("Owner Set NewAsset ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();

        await lendingP.setAssettAvvalible(usdc.address)
        await lendingP.setAssettAvvalible(weth.address)
        await lendingP.setAssettAvvalible(btc.address)

        await lendingP.setMockPrice(usdc.address,"1"+decimal)// price usd  1$
        await lendingP.setMockPrice(weth.address,"1063"+decimal)// price eth 1063.39$
        await lendingP.setMockPrice(btc.address,"19355"+decimal)//")// price btc 19355.13$
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

        //await usdc.transfer(account3, "1000000000000000000000000");
        //await weth.transfer(account3, "1000000000000000000000000");  
        //await  btc.transfer(account3, "1000000000000000000000000");      

    })
    it("Create  new lending Contract Account 1 ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const weth = await mockWeth.deployed();
        const btc = await mockWbtc.deployed(); 
        const lendingP = await LendingPage.deployed();

        //account1

        // deposit 100k usdc  rate 2 apr 4.5%  penality 8% btc collateral
        await usdc.approve(lendingP.address,"1000000"+decimal,{from:account1})  
        await lendingP.deposit(
             usdc.address,
             "1000000"+decimal,// amount
             4.5*100, // apr
             3600,//death line
             8,//penality
             btc.address, // address collateral
             2,//rate
             {from:account1}
           )   
    })
    it("Take borrow + check asset and contract data account 2 ", async ()=>{
        // single loan position
        const usdc = await mockUsdc.deployed();
        const btc = await mockWbtc.deployed();
        const lendingP = await LendingPage.deployed();
        
  
        await btc.approve(lendingP.address,"50"+decimal,{from :account2})
        await lendingP.executeBorrow(1,account1,'200000'+decimal,btc.address,'44'+decimal,{from:account2})
        let result  =await lendingP.findContractLending(account1,1)
        //console.log(result) 
        let position = await lendingP.serchBorrowerPositionXContract(1,account2)
        //console.log(position)
        await lendingP.executeBorrow(1,account1,'20000'+decimal,btc.address,0,{from:account2})
        position = await lendingP.serchBorrowerPositionXContract(1,account2)
        //console.log(position)
            
    })
    it("Liquidation position", async ()=>{
        const lendingP = await LendingPage.deployed();
        const btc = await mockWbtc.deployed();
    
        await lendingP.setMockPrice(btc.address,"9950"+decimal)
        //console.log("before liquidation")
        let result  = await lendingP.findContractLending(account1,1)
        //console.log(result) 
        let position = await lendingP.serchBorrowerPositionXContract(1,account2)
        //console.log(position)

       
        await lendingP.liquidationCall(1,0,{from:account1})
        //console.log("after liquidation")
        result  = await lendingP.findContractLending(account1,1)
        //console.log(result) 
        position = await lendingP.serchBorrowerPositionXContract(1,account2)
        //console.log(position)
        let balanceFee = await btc.balanceOf(lendingP.address);
        //console.log(String(balanceFee))
        await lendingP.widrowFeeContract(btc.address);
        balanceFee = await btc.balanceOf(lendingP.address);
        //console.log(String(balanceFee))
    })
    it("first amount loan + interest",async()=>{
        const lendingP = await LendingPage.deployed();
        
        let loan = await lendingP.viewAmountLoan(account2,1)
        console.log(String(loan))
        loan = await lendingP.viewAmountLoan(account2,1)
        console.log(String(loan))    
    })


    })