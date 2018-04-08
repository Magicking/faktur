pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FakturVerifier.sol";

contract TestFakturVerifier {

  function testInitialBalanceUsingDeployedContract() {
    Assert.isTrue(true, "TODO"); // TODO
    /*
    FakturVerifier fktr = FakturVerifier(DeployedAddresses.FakturVerifier());

    uint expected = 10000;

    Assert.equal(fktr.getBalance(tx.origin), expected, "Owner should have 10000 FakturVerifier initially");
  }

  function testInitialBalanceWithNewFakturVerifier() {
    FakturVerifier fktr = new FakturVerifier();

    uint expected = 10000;

    Assert.equal(fktr.getBalance(tx.origin), expected, "Owner should have 10000 FakturVerifier initially");
    */
  }

}
