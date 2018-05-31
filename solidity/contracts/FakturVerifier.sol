pragma solidity ^0.4.23;

contract FakturVerifier {
	address public OracleAddress;

	uint public LastTimestamp;
	uint public ChallengePeriod;
	uint public MinimalAmount;

	// Merkle root
	mapping(bytes32 => uint) public Hashs;
	// Hash of specific file
	mapping(bytes32 => Receipt) public Receipts;

	event NotifyAnchor(bytes32 hash, uint timestamp, address oracle);
	event Challenge(bytes32 hash, uint timestamp);
	event ChallengeCancelled(bytes32 hash, address whom);

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
	constructor(address oracle) public {
		if (oracle == 0x0)
			oracle = msg.sender;
		OracleAddress = oracle;
		ChallengePeriod = 1 days; // SLA
		LastTimestamp = 0;
		MinimalAmount = 0.1 ether;
		
	}

	/*
		@dev Generate a promise the Oracle should signed.
		@param hash is the targetHash
		@param timestamp should be the time limit of the promise
	*/
	function ProofID(bytes32 hash, uint timestamp) pure public returns (bytes32) {
		return keccak256(hash, timestamp);
	}

	/*
		@dev Open a challenge window for the oracle to submit the receipt
			if no proof is submitted thourgh CancelChallenge, the amount sent
			will be refund plus reimbursent (TODO)
		@param targetHash, user generated hash
		@param timestamp, promised timestamping limit
		@param v, v part of the "personalSignature"
		@param r, r part of the "personalSignature"
		@param s, s part of the "personalSignature"
	*/
	function ChallengeReceipt(bytes32 targetHash, uint timestamp, uint8 v , bytes32 r , bytes32 s) public payable {
		// Verify period validity
		require(timestamp < now);
		require(msg.value >= MinimalAmount);
		require(Receipts[targetHash].PayTo == 0x0); // No withdrawl pending or pending deletion
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		bytes32 preProofID = ProofID(targetHash, timestamp);
		bytes32 prefixHash = keccak256(prefix, preProofID);
		require(ecrecover(prefixHash, v, r, s) == OracleAddress);
		// Register challenge
		uint timeout = now + ChallengePeriod;
		Receipts[targetHash].PayTo = msg.sender;
		Receipts[targetHash].Amount = msg.value /* + calculate delta for paid anchor */;
		Receipts[targetHash].Timeout = timeout;
		// Emit event w/ hash and timeout
		emit Challenge(targetHash, timeout);
	}

	/*
		@dev Reimburse non timestamped hash
		@param targetHash, user generated hash
	*/
	function WithdrawChallenge(bytes32 targetHash) public {
		require(Receipts[targetHash].Timeout >= now);
		address payto = Receipts[targetHash].PayTo;
		uint amount = Receipts[targetHash].Amount;
		delete Receipts[targetHash];
		payto.transfer(amount);
	}

	/*
		@dev Cancel challenge by providing proof
		@param leafPos, Proof position on Merkle Tree (true -> right, false -> left)
		@param proofs, hash audit path
		@param targetHash, user generated hash
	*/
	function CancelChallenge(bool[] leafPos, bytes32[] proofs, bytes32 targetHash) onlyOwner public {
		require(Receipts[targetHash].Timeout < now);
		if (VerifyMerkleHash(leafPos, proofs, targetHash)) {
			//Receipt exist at least by the publication of this transaction
			Receipts[targetHash].Timeout = 0;
			emit ChallengeCancelled(targetHash, Receipts[targetHash].PayTo);
			return;
		}
	}

	// To be Chainpoint 2.1 compliant TODO verify others verification system
	function () onlyOwner public {
		require(msg.data.length == 32);
		bytes memory data = msg.data;
		bytes32 merkleRoot;
		// length is at msg.data[0]
		assembly {
				merkleRoot := mload(add(data, 32))
		}
		Anchor(merkleRoot);
	}

	/*
		@dev Timestamp function, register merkleRoots
		@param hash, Register merkleRoot provided by Oracle
	*/
	function Anchor(bytes32 hash) onlyOwner public {
		Hashs[hash] = now;
		LastTimestamp = now;
		emit NotifyAnchor(hash, now, msg.sender);
	}

	/*
		@dev Verify Chainpoint v2 flavor
			Deprecated because provided hash could be part of a deeper receipt
		      root
		      / \
		     /   \
		    /     \
		    C      D
		   / \     |
		   A B     h2
		   | |
		  h0 h1
		 / \
		 X Y
		@param leafPos, Proof position on Merkle Tree (true -> right, false -> left)
		@param proofs, hash audit path
		@param targetHash, user generated hash
	*/
	function VerifyMerkleHash(bool[] leafPos, bytes32[] proofs, bytes32 targetHash) view public returns (bool) {
		require(leafPos.length == proofs.length);
		// Did we anchor this ?
		// targetHash == merkleRoot when tree contain only 1 element
		bytes32 proofHash = targetHash;
		for (uint256 j = 0; j < proofs.length; j++) {
			bytes32 leaf = proofs[j];
			if (leafPos[j]) {
				proofHash = sha256(leaf, proofHash); // proof on the right (true)
			} else {
				proofHash = sha256(proofHash, leaf);  // proof on the left (false)
			}
		}
		return Hashs[proofHash] > 0;
	}

	//TODO optimize with bitfields and bytes
	/*
		@dev Verify rfc6962 Merkle Hash Tree with second preimage resistance
	          root
	          / \
	         /   \
	        /     \
	       C       D
	      / \      |
	     A   B     h2
	     |   |
	    h0   h1
	 left          right
		@param leafPos, Proof position on Merkle Tree (true -> right, false -> left)
		@param proofs, hash audit path
		@param targetHash, user generated hash
	*/
	function VerifyRFC6962(bool[] leafPos, bytes32[] proofs, bytes32 targetHash) view public returns (bool) {
		require(leafPos.length == proofs.length);
		bytes32 proofHash = sha256(byte(0x0), targetHash);
		for (uint256 j = 0; j < proofs.length; j++) {
			bytes32 leaf = proofs[j];
			if (leafPos[j]) {
				proofHash = sha256(byte(0x1), leaf, proofHash); // proof on the right (true)
			} else {
				proofHash = sha256(byte(0x1), proofHash, leaf); // proof on the left (false)
			}
		}
		// Did we anchor this ?
		return Hashs[proofHash] > 0;
	}
}
