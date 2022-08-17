import { ethers } from "hardhat";

async function main() {

  const DonkeyKing = await ethers.getContractFactory("DonkeyKingTrade");
  const donkey = await DonkeyKing.deploy();

  await donkey.deployed();

  console.log("DonkeyKing Casino game contract deployed to:", donkey.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
