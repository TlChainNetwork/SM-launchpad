require("@nomiclabs/hardhat-waffle");
const fs =require('fs');
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

var privateKey = fs.readFileSync('./.secret').toString();
privateKey = privateKey.replace('\n', '');

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.4",
      },
      {
        version: "0.7.0",
        settings: {},
      },
    ],
  },
 
  // defaultNetwork: "rinkeby",
  networks: {
    hardhat:{
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/3c8e7f53bc6442a1876c4dc03e0a1f32",
      accounts: [privateKey],
    },
    
  }
};