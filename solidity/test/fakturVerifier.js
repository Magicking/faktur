var FakturVerifier = artifacts.require("./FakturVerifier.sol");

var hash =   "0x51296468ea48ddbcc546abb85b935c73058fd8acdb0b953da6aa1ae966581a7a";
var leafPositions = [true, true, false];
var targetHash = "0xbdf8c9bdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2";
var hashs = ["0xbdf8c9bdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2",
             "0xcb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf",
             "0xcb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"];

/*
         root
         / \
        /   \
       /     \
       C      D
      / \     |
      A B     h2
      | |
     h0 h1
*/

var h0 =   "0xcafecebdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2";
var h1 =   "0xb0bd11adb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf";
var h2 =   "0x1337bbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf";

var A =    "0x7afb9bb17fd60a9994683764b64879b954d7029c535b948f4adfe27c1624fa9e";
var B =    "0x141ffb977cb75ffca6a64f756ace29b1f63a3b6fcbcb6ce1e2005ab174c59c67";
var D =    "0x8e3fd36fcf6b1eca9a22376b086b50bd92662202282a0cd211caf11d70ab0918";

var C =    "0x3b78c5cfc9ae4252dacc90e31cf6b6bd89cef1bfe77f330897ab289c6ba1b8a6";
var root = "0x21f757d71f5f666ed66ea5fa593fd59467c0178301dac19a7aac4f2e4cf8fc39";


contract('FakturVerifier', function(accounts) {
  it("Check rfc6962 example", function() {
    var fktr;

    // Get initial balances of first and second account.

    return FakturVerifier.deployed().then(function(instance) {
      fktr = instance;
      return fktr.Anchor(root, {from: accounts[0]});
    }).then(function() {
      return fktr.VerifyRFC6962.call([false, false], [B, D], h0);
    }).then(function(ok) {
      assert.ok(ok, "VerifyRFC6962 is ko");
    });
  });
  it("Check ChainPoint example", function() {
    var fktr;

    // Get initial balances of first and second account.

    return FakturVerifier.deployed().then(function(instance) {
      fktr = instance;
      return fktr.Anchor(hash, {from: accounts[0]});
    }).then(function() {
      return fktr.VerifyMerkleHash.call(leafPositions, hashs, targetHash);
    }).then(function(ok) {
      assert.ok(ok, "Verify is ko");
    });
  });
  it("check default function contract", function() {
    var fktr;

    // Get initial balances of first and second account.

    return FakturVerifier.deployed().then(function(instance) {
      fktr = instance;
      return fktr.Anchor(hash, {from: accounts[0]});
    }).then(function() {
      return fktr.VerifyMerkleHash.call(leafPositions, hashs, targetHash);
    }).then(function(ok) {
      assert.ok(ok, "Verify is ko");
    });
  });
});
