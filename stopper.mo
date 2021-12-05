import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
actor this {
    let a = actor "aaaaa-aa" : actor { stop_canister : { canister_id : Principal } -> async () };

    public func stop() : async () {
	try {
	  await a.stop_canister({canister_id = Principal.fromActor(this);});
          Debug.trap("I stopped myself? How can that be?");
        } catch (_) {}
    };
};
