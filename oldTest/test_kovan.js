
const LendingPage = artifacts.require('lendingPage');
const { passes } = require("truffle-assertions");
//const IERC20 = artifact.require('IERC20');

const truffleAssert = require("truffle-assertions");

passes.contract("LendingContract tesnet", accounts =>{
    //const account = accounts[0];
    const dai = '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa';
    const weth = '0xd0A1E359811322d97991E03f863a0C30C2cF029C';
    // ok
    it("Take borrow + check asset and contract data ", async ()=>{
    console.log(dai);

    //  const lendingP = await LendingPage.deployed();
//
    //  await lendingP.setAssettAvvalible(dai)
    //  await lendingP.setAssettAvvalible(weth)
//
    //  await lendingP.addAddressPriceeFeed(dai,'0x777A68032a88E5A84678A77Af2CD65A7b3c0775a')
    //  await lendingP.addAddressPriceeFeed(weth,'0x9326BFA02ADD2366b30bacB125260Af641031331')
    //  
//
//
    //  await IERC20(dai).approve(lendingP.address,String(10000 *10**18))
    //  await IERC20(weth).approve(lendingP.address,String(10000 *10**18))
    //  
    //  await lendingP.deposit(
    //       dai,// address assett lendinding
    //       String(100 *10**18),// amount
    //       5, // apr
    //       8000,//death line
    //       8,//penality
    //       weth, // address collateral
    //       2,//rate
    //       )
    //  let result  =await lendingP.findContractLending(account,1)
    //  console.log("before" + result)          
    })
   //
})