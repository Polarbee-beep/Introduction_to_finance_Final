const { ethers } = require("hardhat");
async function main() {
  const [admin] = await ethers.getSigners();
  const Factory = await ethers.getContractFactory("TicketTrust");
  const instance = await Factory.deploy(admin.address);
  await instance.waitForDeployment();
  console.log("TicketTrust deployed to:", await instance.getAddress());
  console.log("Admin test account:", admin.address);
}
main().catch((error) => { console.error(error); process.exitCode = 1; });
