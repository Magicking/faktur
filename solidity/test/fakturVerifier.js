var FakturVerifier = artifacts.require("./FakturVerifier.sol");

contract('FakturVerifier', function(accounts) {
  it("Check ChainPoint example", function() {
    var fktr;

    // Get initial balances of first and second account.
    var hash =   "0x51296468ea48ddbcc546abb85b935c73058fd8acdb0b953da6aa1ae966581a7a";
    var hashs = ["0xbdf8c9bdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2",
                 "0xcb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf",
                 "0xcb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"];

    return FakturVerifier.deployed().then(function(instance) {
      fktr = instance;
      return fktr.Anchor(hash, {from: accounts[0]});
    }).then(function() {
      return fktr.Verify.call([true, true, false], hashs, hash);
    }).then(function(ok) {
      assert.ok(ok, "Verify is ko");
    });
  });
  it("check default function contract", function() {
    var fktr;

    // Get initial balances of first and second account.
    var hash =   "0x51296468ea48ddbcc546abb85b935c73058fd8acdb0b953da6aa1ae966581a7a";
    var hashs = ["0xbdf8c9bdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2",
                 "0xcb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf",
                 "0xcb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"];

    return FakturVerifier.deployed().then(function(instance) {
      fktr = instance;
      return fktr.Anchor(hash, {from: accounts[0]});
    }).then(function() {
      return fktr.Verify.call([true, true, false], hashs, hash);
    }).then(function(ok) {
      assert.ok(ok, "Verify is ko");
    });
  });
});
