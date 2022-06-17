const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

let tokenA;
let tokenB;
let swapContract;
let addr1;
let addr2;

describe("Swap Token", function () {
  beforeEach(async function() {
    const tokenAFactory = await ethers.getContractFactory("TokenA");
    const tokenBFactory = await ethers.getContractFactory("TokenB");
    tokenA = await tokenAFactory.deploy();
    tokenB = await tokenBFactory.deploy();
    await tokenA.deployed();
    await tokenB.deployed();

    const swapFactory = await ethers.getContractFactory("TokenSwap");
    swapContract = await swapFactory.deploy(tokenA.address, tokenB.address);
    await swapContract.deployed();

    [addr1, addr2] = await ethers.getSigners();
    await tokenA.mint(addr1.address, 100);
    await tokenB.mint(addr2.address, 100);
    console.log("Address - ", addr1.address, addr2.address);
  });

  it("Create Sell Order Test", async function () {
    swapContract.CreateSellOrder(0, 50, 2, addr1.address);
    expect(await swapContract.totalOrder()).to.deep.equal(BigNumber.from("1"));
    expect(await tokenA.balanceOf(addr1.address)).to.deep.equal(BigNumber.from("50"));
    expect(await tokenA.balanceOf(swapContract.address)).to.deep.equal(BigNumber.from("50"));
    expect(await swapContract.orderOf(BigNumber.from("0"))).to.deep.equal(addr1.address);
    expect(await swapContract.amountOf(BigNumber.from("0"))).to.deep.equal(50);
    expect(await swapContract.priceOf(BigNumber.from("0"))).to.deep.equal(2);
  });

  it("Cancel Sell Order Test", async function () {
    swapContract.CreateSellOrder(0, 50, 2, addr1.address);
    swapContract.CancelSellOrder(0, addr1.address);
    expect(await swapContract.totalOrder()).to.deep.equal(BigNumber.from("0"));
    expect(await tokenA.balanceOf(addr1.address)).to.deep.equal(BigNumber.from("100"));
    expect(await tokenA.balanceOf(swapContract.address)).to.deep.equal(BigNumber.from("0"));
  });

  it("Buy Order Test", async function() {
    swapContract.CreateSellOrder(0, 50, 2, addr1.address);
    swapContract.BuyOrder(0, 20, addr2.address);
    
    expect(await swapContract.totalOrder()).to.deep.equal(BigNumber.from("1"));
    expect(await tokenA.balanceOf(addr1.address)).to.deep.equal(BigNumber.from("50"));
    expect(await tokenA.balanceOf(swapContract.address)).to.deep.equal(BigNumber.from("30"));
    expect(await tokenA.balanceOf(addr2.address)).to.deep.equal(BigNumber.from("20"));
    expect(await tokenB.balanceOf(addr1.address)).to.deep.equal(BigNumber.from("40"));
    expect(await tokenB.balanceOf(addr2.address)).to.deep.equal(BigNumber.from("60"));
  });
});
