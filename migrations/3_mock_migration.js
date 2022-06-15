const mockUsdc = artifacts.require("mockUsdc");
const mockWeth = artifacts.require("mockWeth");
const mockWbtc = artifacts.require("mockWbtc");


module.exports = async function (deployer) {
  await deployer.deploy(mockUsdc , 100000000000);
  await deployer.deploy(mockWeth , 100000000000);
  await deployer.deploy(mockWbtc , 100000000000);

};
