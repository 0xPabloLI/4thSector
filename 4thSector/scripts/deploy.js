/*const { expect } = require("chai");

describe("WeightedRaffle contract", function () {
  it("Deployment without initialization", async function () {
    const [owner] = await ethers.getSigners();

    const WeightedRaffle = await ethers.getContractFactory("WeightedRaffle");

    const WeightedRaffle1 = await WeightedRaffle.deploy();

    //const ownerBalance = await hardhatToken.balanceOf(owner.address);
    //expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const WisherIssuerContract = await ethers.getContractFactory("WisherIssuer");
    const wisherIssuerInstance = await WisherIssuerContract.deploy();
    await wisherIssuerInstance.deployed();
  
    console.log("WisherIssuer address:", wisherIssuerInstance.address);

    console.log(`Verifying contract on Etherscan...`);

    await run(`verify:verify`, {
      address: wisherIssuerInstance.address,
    });
  }

  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
*/

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const FourthSectorFactory = await ethers.getContractFactory("fourthSector");

  // Replace 'multiSigAdminAddress' with the actual address of your MultiSigAdmin contract
  const admin = "0x1cF8f226DaC2D74fb087346A21cf3C7373785B44"; // Provide the actual address here
  const fourthSector = await FourthSectorFactory.deploy(admin);

  console.log("fourthSector contract deployed to:", fourthSector.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
