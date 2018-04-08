pragma solidity ^0.4.21;

contract FakturVerifier {
	address OracleAddress;

	uint LastTimestamp;
	uint ChallengePeriod;
	uint MinimalAmount;

	// Merkle root
	mapping(bytes32 => uint) Hashs;
	// Hash of specific file
	mapping(bytes32 => Receipt) Receipts;

	event NotifyAnchor(bytes32 hash, uint timestamp, address oracle);
	event Challenge(bytes32 hash, uint timestamp);

	struct Receipt {
		address		PayTo;
		uint		Amount;
		uint		Timeout;
	}

	modifier onlyOwner () {
		require(OracleAddress == msg.sender);
		_;
	}

	/*
	  TODO:
	   - documentation
	   - tests
	*/
	function FakturVerifier() public {
		OracleAddress = msg.sender;
		ChallengePeriod = 1 days; // SLA
		LastTimestamp = 0;
		MinimalAmount = 0.1 ether;
	}

	function ProofID(bytes32 hash, uint timestamp) pure public returns (bytes32) {
		return keccak256(hash, timestamp);
	}

	function ChallengeReceipt(bytes32 targetHash, uint timestamp, uint8 v , bytes32 r , bytes32 s) public payable {
		// Verify period validity
		require(timestamp < now);
		require(msg.value >= MinimalAmount);
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		bytes32 preProofID = ProofID(targetHash, timestamp);
		require(ecrecover(preProofID, v, r, s) == OracleAddress);
		// Register challenge
		uint timeout = now + ChallengePeriod;
		Receipts[targetHash].PayTo = msg.sender;
		Receipts[targetHash].Amount = msg.value /* + calculate delta */;
		Receipts[targetHash].Timeout = timeout;
		// Emit event w/ hash and timeout
		emit Challenge(targetHash, timeout);
	}

	function CancelChallenge(bool[] leafPos, bytes32[] proofs, bytes32 targetHash) onlyOwner public {
		require(Receipts[targetHash].Timeout < now);
		if (Verify(leafPos, proofs, targetHash)) {
			//Receipt exist at least by the publication of this transaction
			delete Receipts[targetHash];
			return;
		}
	}

	function WithdrawChallenge(bytes32 targetHash) public {
		require(Receipts[targetHash].Timeout >= now);
		address payto = Receipts[targetHash].PayTo;
		uint amount = Receipts[targetHash].Amount;
		delete Receipts[targetHash];
		payto.transfer(amount);
	}

	// To be Chainpoint 2.1 compliant
	function () onlyOwner public {
		require(msg.data.length == 32);
		bytes memory data = msg.data;
		bytes32 targetHash;
		// length is at msg.data[0]
		assembly {
				targetHash := mload(add(data, 32))
		}
		Anchor(targetHash);
	}

	function Anchor(bytes32 hash) onlyOwner public {
		Hashs[hash] = now;
		LastTimestamp = now;
		emit NotifyAnchor(hash, now, msg.sender);
	}

	//TODO optimize with bitfields and bytes
	function Verify(bool[] leafPos, bytes32[] proofs, bytes32 targetHash) view public returns (bool) {
		// Did we anchor this ?
		require(Hashs[targetHash] > 0);
		require(leafPos.length == proofs.length);
		bytes32 proofHash = proofs[0];
		for (uint256 j = 0; j < proofs.length; j++) {
			bytes32 leaf = proofs[j];
			if(leafPos[j]) {
				proofHash = sha256(leaf, proofHash); // left
			} else {
				proofHash = sha256(proofHash, leaf); // right
			}
		}
		return proofHash == targetHash; //TODO
	}
}
