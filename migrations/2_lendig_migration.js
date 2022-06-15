const lendingPage = artifacts.require("lendingPage");

module.exports = async function (deployer) {
  await deployer.deploy(lendingPage,2);
};
