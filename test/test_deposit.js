const mockUsdc = artifacts.require('mockUsdc');
const mockWeth = artifacts.require('mockWeth');
const mockWbtc = artifacts.require('mockWbtc');
const LendingPage = artifacts.require('lendingPage');

const truffleAssert = require("truffle-assertions");

contract("LendingContract", accounts =>{
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

        await lendingP.setAssettAvvalible(usdc.address)
        await lendingP.setAssettAvvalible(weth.address)

        await usdc.transfer(account2,100000);
        await usdc.approve(lendingP.address,100000)
        await lendingP.deposit(
             usdc.address,
             100000,
             5,
             1000,
             8,
            weth.address)


    })




    it("Not Autorizate Set NewAsset ", async ()=>{
        const usdc = await mockUsdc.deployed();
        const lendingP = await LendingPage.deployed();

        await truffleAssert.reverts(
            lendingP.setAssettAvvalible(usdc.address,{from:account2})
        )

  
    })




})