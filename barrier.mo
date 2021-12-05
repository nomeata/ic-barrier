import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Stopper "canister:stopper";
actor {
    let a = actor "aaaaa-aa" : actor {
      start_canister : { canister_id : Principal } -> async ();
      stop_canister : { canister_id : Principal } -> async ()
    };
    public func lock() : async () {
	ignore Stopper.stop();
        // NB: No await! The call to `stop` will block until `release()`, but
        // its nicer if this returns. One _could_ now wait for it to go to
        // stopping before replying here.
    };
    public func release() : async () {
	await a.start_canister({canister_id = Principal.fromActor(Stopper);});
    };
    public func enter() : async () {
	try {
	  await a.stop_canister({canister_id = Principal.fromActor(Stopper);});
          Debug.trap("stopper actually stopped; did you not call lock() before?");
        } catch (_) {}
    };
    // some commmon endpoints, if one wants to test these:
    public func transaction_notification() : async () { await enter(); };
    public func wallet_receive() : async () { await enter(); };
};
