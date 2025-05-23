# Sneed Dedup Library

## Overview

The Dedup library provides bi-directional mapping between Nat32 indices and arbitrary blobs (Nat8 arrays). It is designed to be used in Internet Computer canisters to efficiently store and reference large data like Principals, subaccounts, and neuron IDs by mapping them to smaller Nat32 indices, effectively deduplicating repeated blob values.

## Use Cases

- Mapping Principals to compact indices for efficient message storage
- Storing subaccounts (32-byte blobs) with numeric references
- Managing neuron IDs (32-byte blobs) with compact indices
- Any scenario requiring bi-directional mapping between blobs and numeric indices

## Architecture

### State Management

The library uses a DedupState record type to maintain stable storage across canister upgrades:

```motoko
public type DedupState = {
    blobs: Vector.Vector<Blob>;          // Stable vector for blobs
    blobToIndex: Map.Map<Blob, Nat32>;  // Stable map for blob->index mapping
};
```

### Module Structure

The library provides two ways to use the deduplication functionality:

1. Static module methods that take DedupState as a parameter (functional style)
2. A class-based implementation that maintains internal state (object-oriented style)

## API Reference

### Static Module Methods

#### empty
```motoko
public func empty() : DedupState
```
- Creates and returns a new empty DedupState with:
  - Empty blobs Vector
  - Empty blobToIndex Map

#### getOrCreateIndex
```motoko
public func getOrCreateIndex(state: DedupState, blob: Blob) : Nat32
```
- Returns existing index if blob exists in blobToIndex Map
- If blob not found:
  - Appends blob to blobs Vector
  - Creates new blob->index mapping in blobToIndex Map
  - Returns new index

#### getBlob
```motoko
public func getBlob(state: DedupState, index: Nat32) : ?Blob
```
- Returns blob at given index in blobs Vector if index is valid
- Returns null if index is out of bounds

#### getIndex
```motoko
public func getIndex(state: DedupState, blob: Blob) : ?Nat32
```
- Returns the index if the blob exists in blobToIndex Map
- Returns null if the blob has not been indexed yet

#### getOrCreateIndexForPrincipal
```motoko
public func getOrCreateIndexForPrincipal(state: DedupState, principal: Principal) : Nat32
```
- Converts Principal to Blob and calls getOrCreateIndex
- Returns index from getOrCreateIndex

#### getIndexForPrincipal
```motoko
public func getIndexForPrincipal(state: DedupState, principal: Principal) : ?Nat32
```
- Converts Principal to Blob and calls getIndex
- Returns result from getIndex

#### getPrincipalForIndex
```motoko
public func getPrincipalForIndex(state: DedupState, index: Nat32) : ?Principal
```
- Calls getBlob to retrieve blob at index
- If blob found, attempts to convert it to Principal
- Returns null if:
  - Index not found
  - Blob cannot be converted to Principal

### Class Implementation

#### Constructor

```motoko
public class Dedup(from: ?DedupState)
```
- Initializes the Dedup with optional DedupState
- If state is provided:
  - Uses provided blobs Vector directly
  - Uses provided blobToIndex Map directly
- If no state provided:
  - Creates empty blobs Vector
  - Creates empty blobToIndex Map

#### Instance Methods

##### getOrCreateIndex
```motoko
public func getOrCreateIndex(blob: Blob) : Nat32
```
- Returns existing index if blob found in blobToIndex Map
- If blob not found:
  - Appends blob to blobs Vector
  - Creates new blob->index mapping in blobToIndex Map
  - Returns new index

##### getBlob
```motoko
public func getBlob(index: Nat32) : ?Blob
```
- Returns blob at given index in blobs Vector if index is valid
- Returns null if index is out of bounds

##### getIndex
```motoko
public func getIndex(blob: Blob) : ?Nat32
```
- Returns the index if the blob exists in blobToIndex Map
- Returns null if the blob has not been indexed yet

##### getOrCreateIndexForPrincipal
```motoko
public func getOrCreateIndexForPrincipal(principal: Principal) : Nat32
```
- Converts Principal to Blob and calls getOrCreateIndex
- Returns index from getOrCreateIndex

##### getIndexForPrincipal
```motoko
public func getIndexForPrincipal(principal: Principal) : ?Nat32
```
- Converts Principal to Blob and calls getIndex
- Returns result from getIndex

##### getPrincipalForIndex
```motoko
public func getPrincipalForIndex(index: Nat32) : ?Principal
```
- Calls getBlob to retrieve blob at index
- If blob found, attempts to convert it to Principal
- Returns null if:
  - Index not found
  - Blob cannot be converted to Principal

## Usage Patterns

### Functional Style

```motoko
let state = Dedup.empty();
let index1 = Dedup.getOrCreateIndex(state, blob1);
let index2 = Dedup.getOrCreateIndex(state, blob2);
```

### Object-Oriented Style

```motoko
let dedup = Dedup.Dedup(null);
let index1 = dedup.getOrCreateIndex(blob1);
let index2 = dedup.getOrCreateIndex(blob2);
```

### Canister Implementation

```motoko
actor {
    stable var dedupState: ?Dedup.DedupState = ?Dedup.empty();

    // use as class
    var dedup = Dedup.Dedup(dedupState);
    let index1 = dedup.getOrCreateIndex(blob1);

    // use as module
    let index2 = Dedup.getOrCreateIndex(state, blob2);

    // No need for pre/postupgrade - the Vector and Map are already stable
}
```

## Implementation Notes

1. The library maintains bi-directional integrity - each index maps to exactly one blob and vice versa
2. Indices are assigned sequentially starting from 0
3. The stable storage pattern ensures data persistence across upgrades
4. The stable Map provides efficient lookups and upgrade safety
5. The stable Vector ensures efficient sequential storage and upgrade safety
6. The implementation is generic, supporting any blob type, not just Principals
7. Both functional and object-oriented styles provide identical functionality with different state management approaches

