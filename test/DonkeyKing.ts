import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("DonkeyKing", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deployDonkeyKingTradeFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, casinoWallet, devWallet1, devWallet2] = await ethers.getSigners();
    
    const DST = await ethers.getContractFactory("DST");
    const dst = await DST.deploy();

    await dst.mint(owner.address, '1000000000000');
    await dst.mint(casinoWallet.address, '1000000000000000');
    
    const DonkeyKing = await ethers.getContractFactory("DonkeyKingTrade");
    const donkey = await DonkeyKing.deploy(dst.address, casinoWallet.address, devWallet1.address, devWallet2.address);

    dst.approve(donkey.address, '1000000000000000');
    dst.approve(casinoWallet.address, '1000000000000000');

    const UniswapMock = await ethers.getContractFactory("MockRouterPair");
    const uniswapMock = await UniswapMock.deploy();

    await donkey.setUniswapPair(uniswapMock.address);
    await donkey.setUniswapRouter(uniswapMock.address);
    
    return { donkey, dst, owner, casinoWallet, devWallet1, devWallet2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { donkey, owner } = await loadFixture(deployDonkeyKingTradeFixture);

      expect(await donkey.owner()).to.equal(owner.address);
    });

    it("Should set taking fee enabled", async function() {
      const { donkey } = await loadFixture(deployDonkeyKingTradeFixture);

      expect(await donkey.txFeeEnabled()).to.equal(true);
    });

    // it("Should receive and store the funds to lock", async function () {
    //   const { lock, lockedAmount } = await loadFixture(
    //     deployOneYearLockFixture
    //   );

    //   expect(await ethers.provider.getBalance(lock.address)).to.equal(
    //     lockedAmount
    //   );
    // });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = await time.latest();
    //   const Lock = await ethers.getContractFactory("Lock");
    //   await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
    //     "Unlock time should be in the future"
    //   );
    // });
  });

  describe("Trade", function () {
    describe("BUY/CELL chips", function () {
      it("Should revert if the wallet has blocked when buy chips", async function() {
        const { donkey, owner } = await loadFixture(deployDonkeyKingTradeFixture);
        await donkey.blockWallet(owner.address);

        await expect(donkey.buyChips(100)).to.be.revertedWith(
          "Transaction blocked"
        );
      });

      it("Should not take fee if it's not enabled", async function() {
        const { donkey, casinoWallet, owner, dst } = await loadFixture(deployDonkeyKingTradeFixture);
        await donkey.disableTxFee();
        await expect(donkey.buyChips(10)).to.changeTokenBalances(
          dst,
          [owner, casinoWallet],
          ['-10000000000', '10000000000']);
      });

      it("Should not take fee if it's excluded from fee", async function() {
        const { donkey, casinoWallet, owner, dst } = await loadFixture(deployDonkeyKingTradeFixture);
        await donkey.excludeFromFee(owner.address);
        await expect(donkey.buyChips(10)).to.changeTokenBalances(
          dst,
          [owner, casinoWallet],
          ['-10000000000', '10000000000']);
      });

      it("Should revert if the wallet doesn't pay fee.", async function() {
        const { donkey, owner } = await loadFixture(deployDonkeyKingTradeFixture);
        await donkey.excludeFromFee(owner.address);
        await donkey.includeInFee(owner.address);
        await expect(donkey.buyChips(10)).to.revertedWith(
          "Insufficient Tx Fee"
        );
      });

      it("Should revert if the fee is insufficient", async function() {
        const { donkey } = await loadFixture(deployDonkeyKingTradeFixture);
        await expect(donkey.buyChips(10, { value: '10' })).to.revertedWith(
          "Insufficient Tx Fee"
        );
      });

      it("Should transfer dst when enough fee is paid", async function() {
        const { donkey, casinoWallet, owner, dst } = await loadFixture(deployDonkeyKingTradeFixture);
        // await donkey.disableTxFee();
        await expect(donkey.buyChips(10, { value: '300000000' })).to.changeTokenBalances(
          dst,
          [owner, casinoWallet],
          ['-10000000000', '10000000000']);
      });
    });
  });

  // describe("Withdrawals", function () {
  //   describe("Validations", function () {
  //     it("Should revert with the right error if called too soon", async function () {
  //       const { lock } = await loadFixture(deployOneYearLockFixture);

  //       await expect(lock.withdraw()).to.be.revertedWith(
  //         "You can't withdraw yet"
  //       );
  //     });

  //     it("Should revert with the right error if called from another account", async function () {
  //       const { lock, unlockTime, otherAccount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // We can increase the time in Hardhat Network
  //       await time.increaseTo(unlockTime);

  //       // We use lock.connect() to send a transaction from another account
  //       await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
  //         "You aren't the owner"
  //       );
  //     });

  //     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  //       const { lock, unlockTime } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // Transactions are sent using the first signer by default
  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).not.to.be.reverted;
  //     });
  //   });

  //   describe("Events", function () {
  //     it("Should emit an event on withdrawals", async function () {
  //       const { lock, unlockTime, lockedAmount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw())
  //         .to.emit(lock, "Withdrawal")
  //         .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
  //     });
  //   });

  //   describe("Transfers", function () {
  //     it("Should transfer the funds to the owner", async function () {
  //       const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).to.changeEtherBalances(
  //         [owner, lock],
  //         [lockedAmount, -lockedAmount]
  //       );
  //     });
  //   });
  // });
});
