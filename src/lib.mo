// Deduplication Utility
// Written By Snassy
// 2025-05-22

import Blob "mo:base/Blob";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Vector "mo:vector";
import Map "mo:map/Map";
import Iter "mo:base/Iter";

module {
    let blobUtils : (Blob -> Nat32, (Blob, Blob) -> Bool) = (Blob.hash, Blob.equal);

    public type DedupState = {
        blobs: Vector.Vector<Blob>;          // Stable vector for blobs
        blobToIndex: Map.Map<Blob, Nat32>;  // Stable map for blob->index mapping
    };

    // Static module methods
    public func empty() : DedupState {
        {
            blobs = Vector.new<Blob>();
            blobToIndex = Map.new<Blob, Nat32>();
        }
    };

    public func fromBlobs(blobs: Vector.Vector<Blob>) : DedupState {
        let blobToIndex = Map.new<Blob, Nat32>();
        let size = Vector.size(blobs);
        for (i in Iter.range(0, size - 1)) {
            let blob = Vector.get(blobs, i);
            Map.set(blobToIndex, blobUtils, blob, Nat32.fromNat(i));
        };
        {
            blobs;
            blobToIndex;
        }
    };

    public func getOrCreateIndex(state: DedupState, blob: Blob) : Nat32 {
        switch(Map.get(state.blobToIndex, blobUtils, blob)) {
            case (?existingIndex) {
                existingIndex
            };
            case null {
                let newIndex = Nat32.fromNat(Vector.size<Blob>(state.blobs));
                Vector.add<Blob>(state.blobs, blob);
                Map.set(state.blobToIndex, blobUtils, blob, newIndex);
                newIndex
            };
        }
    };

    public func getBlob(state: DedupState, index: Nat32) : ?Blob {
        let size = Vector.size<Blob>(state.blobs);
        if (Nat32.toNat(index) >= size) {
            return null;
        };
        ?Vector.get<Blob>(state.blobs, Nat32.toNat(index))
    };

    public func getIndex(state: DedupState, blob: Blob) : ?Nat32 {
        Map.get(state.blobToIndex, blobUtils, blob)
    };

    public func getOrCreateIndexForPrincipal(state: DedupState, principal: Principal) : Nat32 {
        let principalBlob = Principal.toBlob(principal);
        getOrCreateIndex(state, principalBlob)
    };

    public func getIndexForPrincipal(state: DedupState, principal: Principal) : ?Nat32 {
        let principalBlob = Principal.toBlob(principal);
        getIndex(state, principalBlob)
    };

    public func getPrincipalForIndex(state: DedupState, index: Nat32) : ?Principal {
        switch(getBlob(state, index)) {
            case (?blob) {
                ?Principal.fromBlob(blob)
            };
            case null {
                null
            };
        }
    };

    // Class implementation
    public class Dedup(from: ?DedupState) {
        // Runtime state
        private let blobs : Vector.Vector<Blob> = do {
            switch(from) {
                case (?state) { state.blobs; };
                case null { Vector.new<Blob>() };
            };
        };

        private let blobToIndex = switch(from) {
            case (?state) { state.blobToIndex };
            case null { Map.new<Blob, Nat32>() };
        };
                       
        public func getOrCreateIndex(blob: Blob) : Nat32 {
            switch(Map.get(blobToIndex, blobUtils, blob)) {
                case (?existingIndex) {
                    return existingIndex;
                };
                case null {
                    let newIndex = Nat32.fromNat(Vector.size<Blob>(blobs));
                    Vector.add<Blob>(blobs, blob);
                    Map.set(blobToIndex, blobUtils, blob, newIndex);
                    return newIndex;
                };
            };
        };

        public func getBlob(index: Nat32) : ?Blob {
            let size = Vector.size<Blob>(blobs);
            if (Nat32.toNat(index) >= size) {
                return null;
            };
            ?Vector.get<Blob>(blobs, Nat32.toNat(index));
        };

        public func getIndex(blob: Blob) : ?Nat32 {
            Map.get(blobToIndex, blobUtils, blob)
        };

        public func getOrCreateIndexForPrincipal(principal: Principal) : Nat32 {
            let principalBlob = Principal.toBlob(principal);
            getOrCreateIndex(principalBlob);
        };

        public func getIndexForPrincipal(principal: Principal) : ?Nat32 {
            let principalBlob = Principal.toBlob(principal);
            getIndex(principalBlob);
        };

        public func getPrincipalForIndex(index: Nat32) : ?Principal {
            switch(getBlob(index)) {
                case (?blob) {
                    ?Principal.fromBlob(blob);
                };
                case null {
                    null;
                };
            };
        };
    };
}
