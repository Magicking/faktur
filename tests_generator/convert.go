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

func Cat(left, right [32]byte) []byte {
	tmp := left[:]
	return append(tmp, right[:]...)
}

func main() {
	const hash0 = "cafecebdf076d6aff0292a1c9448691d2ae283f2ce41b045355e2c8cb8e85ef2"
	const hash1 = "b0bd11adb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"
	const hash2 = "1337bbedb5ec5363e39be9fc43f56f321e1572cfcf304d26fc67cb6ea2e49faf"
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
	h0 := MustDecodeHash(hash0, 32)
	h1 := MustDecodeHash(hash1, 32)
	h2 := MustDecodeHash(hash2, 32)
	fmt.Printf("h0: %x\n", h0)
	fmt.Printf("h1: %x\n", h1)
	fmt.Printf("h2: %x\n\n", h2)

	A := sha256.Sum256(PrefixWith(0x0, h0))
	fmt.Printf("A: %x\n", A)
	B := sha256.Sum256(PrefixWith(0x0, h1))
	fmt.Printf("B: %x\n", B)
	D := sha256.Sum256(PrefixWith(0x0, h2))
	fmt.Printf("D: %x\n\n", D)

	C := sha256.Sum256(PrefixWith(0x1, Cat(A, B)))
	fmt.Printf("C: %x\n", C)
	root := sha256.Sum256(PrefixWith(0x1, Cat(C, D)))
	fmt.Printf("root: %x\n", root)
}
