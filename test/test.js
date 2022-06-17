const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const tokenAFactory = await ethers.getContractFactory("TokenA");
    const tokenBFactory = await ethers.getContractFactory("TokenA");
    const tokenA = await tokenAFactory.deploy();
    const tokenB = await tokenAFactory.deploy();
    await tokenA.deployed();
    await tokenB.deployed();

    const swapFactory = await ethers.getContractFactory("TokenSwap");
    const swapContract = await swapFactory.deploy(tokenA, tokenB);
    await swapContract.deployed();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
