package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"log"
)

func MustDecodeHash(s string, bsize int) []byte {
	decoded, err := hex.DecodeString(s)
	if err != nil {
		log.Fatal("MustDecodeHash", err, s)
	}
	if len(decoded) != bsize {
		log.Fatal("MustDecodeHash: Bad length for ", s, " was ", len(s))
	}
	return decoded
}

func PrefixWith(prefix byte, buffer []byte) []byte {
	tmp := []byte{prefix}
	return append(tmp, buffer...)
}

func Catbb(left, right []byte) []byte {
	tmp := left
	return append(tmp, right...)
}

func CatbB(left []byte, right [32]byte) []byte {
	tmp := left
	return append(tmp, right[:]...)
}

func CatBb(left [32]byte, right []byte) []byte {
	tmp := left[:]
	return append(tmp, right...)
}

func CatBB(left, right [32]byte) []byte {
	tmp := left[:]
	return append(tmp, right[:]...)
}

func rfc6962() {
	const hash0 = "cafecebdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2"
	const hash1 = "b0bd11adb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"
	const hash2 = "1337bbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"
	/*
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
	*/
	h0 := MustDecodeHash(hash0, 32)
	h1 := MustDecodeHash(hash1, 32)
	h2 := MustDecodeHash(hash2, 32)
	fmt.Println("RFC 6962")
	fmt.Printf("h0: %x\n", h0)
	fmt.Printf("h1: %x\n", h1)
	fmt.Printf("h2: %x\n\n", h2)

	A := sha256.Sum256(PrefixWith(0x0, h0))
	fmt.Printf("A: %x\n", A)
	B := sha256.Sum256(PrefixWith(0x0, h1))
	fmt.Printf("B: %x\n", B)
	D := sha256.Sum256(PrefixWith(0x0, h2))
	fmt.Printf("D: %x\n\n", D)

	C := sha256.Sum256(PrefixWith(0x1, CatBB(A, B)))
	fmt.Printf("C: %x\n", C)
	root := sha256.Sum256(PrefixWith(0x1, CatBB(C, D)))
	fmt.Printf("root: %x\n", root)
}

func chainpointv2() {
	const targetHash = "bdf8c9bdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2"
	const merkleRoot = "51296468ea48ddbcc546abb85b935c73058fd8acdb0b953da6aa1ae966581a7a"
	const proof0 = "bdf8c9bdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2"
	const proof2 = "cb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"
	const proof4 = "cb0dbbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"
	/*
		          root
		           / \
		          /   \
		         /     \
		        /       \
		       3         4
		      / \       / \
		     /   \     .   .
		    /     \
		   1       2
		  / \     / \
		 .   .   0   t
		left                  right
	*/
	t := MustDecodeHash(targetHash, 32)
	root := MustDecodeHash(merkleRoot, 32)
	p0 := MustDecodeHash(proof0, 32)
	p2 := MustDecodeHash(proof2, 32)
	p4 := MustDecodeHash(proof4, 32)

	fmt.Println("Chainpoint v2")
	fmt.Printf("t: %x\n", t)
	fmt.Printf("root: %x\n", root)
	fmt.Printf("p4: %x\n\n", p4)

	fmt.Printf("p0: %x\n", p0)
	fmt.Printf("p2: %x\n", p2)
	fmt.Printf("p4: %x\n\n", p4)

	p1 := sha256.Sum256(Catbb(p0, t))
	fmt.Printf("p1: %x\n", p1)
	p3 := sha256.Sum256(CatbB(p2, p1))
	fmt.Printf("p3: %x\n", p3)
	_root := sha256.Sum256(CatBb(p3, p4))
	fmt.Printf("_root: %x\n", _root)
}

func main() {
	rfc6962()
	fmt.Println()
	fmt.Println()
	chainpointv2()
}
