import Dedup "../src/lib";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Vector "mo:vector";
import Map "mo:map/Map";

// Test utilities
func makeBlob(text: Text) : Blob {
    Text.encodeUtf8(text);
};

func makePrincipal(text: Text) : Principal {
    Principal.fromText(text);
};

// Test static methods
do {
    Debug.print("Testing static methods...");
    
    // Test empty()
    let state = Dedup.empty();
    assert(Dedup.getBlob(state, 0) == null);
    
    // Test getOrCreateIndex with new blob
    let blob1 = makeBlob("test1");
    let index1 = Dedup.getOrCreateIndex(state, blob1);
    assert(index1 == 0);
    assert(Dedup.getBlob(state, index1) == ?blob1);
    
    // Test getOrCreateIndex with existing blob
    let index2 = Dedup.getOrCreateIndex(state, blob1);
    assert(index1 == index2);
    
    // Test getIndex
    assert(Dedup.getIndex(state, blob1) == ?index1);
    assert(Dedup.getIndex(state, makeBlob("nonexistent")) == null);
    
    // Test getBlob
    assert(Dedup.getBlob(state, index1) == ?blob1);
    assert(Dedup.getBlob(state, 99) == null);
    
    // Test Principal methods
    let principal1 = makePrincipal("aaaaa-aa");
    let pIndex1 = Dedup.getOrCreateIndexForPrincipal(state, principal1);
    
    assert(Dedup.getIndexForPrincipal(state, principal1) == ?pIndex1);
    assert(Dedup.getPrincipalForIndex(state, pIndex1) == ?principal1);
    
    Debug.print("Static methods tests passed!");
};

// Test class methods
do {
    Debug.print("Testing class methods...");
    
    // Test constructor with null state
    let dedup1 = Dedup.Dedup(null);
    assert(dedup1.getBlob(0) == null);
    
    // Test getOrCreateIndex with new blob
    let blob1 = makeBlob("test1");
    let index1 = dedup1.getOrCreateIndex(blob1);
    assert(index1 == 0);
    assert(dedup1.getBlob(index1) == ?blob1);
    
    // Test getOrCreateIndex with existing blob
    let index2 = dedup1.getOrCreateIndex(blob1);
    assert(index1 == index2);
    
    // Test getIndex
    assert(dedup1.getIndex(blob1) == ?index1);
    assert(dedup1.getIndex(makeBlob("nonexistent")) == null);
    
    // Test getBlob
    assert(dedup1.getBlob(index1) == ?blob1);
    assert(dedup1.getBlob(99) == null);
    
    // Test Principal methods
    let principal1 = makePrincipal("aaaaa-aa");
    let pIndex1 = dedup1.getOrCreateIndexForPrincipal(principal1);
    
    assert(dedup1.getIndexForPrincipal(principal1) == ?pIndex1);
    assert(dedup1.getPrincipalForIndex(pIndex1) == ?principal1);
    
    // Test constructor with existing state
    let blobs = Vector.new<Blob>();
    let blobToIndex = Map.new<Blob, Nat32>();
    
    // Add both the test blob and principal blob to the state
    Vector.add<Blob>(blobs, blob1);
    Map.set(blobToIndex, (Blob.hash, Blob.equal), blob1, index1);
    
    let principalBlob = Principal.toBlob(principal1);
    Vector.add<Blob>(blobs, principalBlob);
    Map.set(blobToIndex, (Blob.hash, Blob.equal), principalBlob, pIndex1);
    
    let dedup2 = Dedup.Dedup(?{ blobs; blobToIndex });
    assert(dedup2.getBlob(index1) == ?blob1);
    assert(dedup2.getIndex(blob1) == ?index1);
    assert(dedup2.getPrincipalForIndex(pIndex1) == ?principal1);
    
    Debug.print("Class methods tests passed!");
};

Debug.print("All tests passed!");