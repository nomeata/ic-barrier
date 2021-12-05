A barrier canister for the Internet Computer
============================================

When writing canisters (services, smart contracts) on the Internet Computer,
and these services are meant to call other canisters, or if you create external
services or agents that interact with the Internet Computer, it is probably
important to test the behaviour of your code when some of these calls are
still pending, or if they come back in particular order.

The Internet Computer of course does not give you control over its scheduling.
But there is an interesting aspect of the IC's behavior that allows us to send
an inter-canister or ingress call, and externally control when it returns
(without resorting to even more horrible hacks like looping self-calls): If a
canister tries to stop itself, then the call to `stop_canister` will prevent
this stopping from happening, and the canister will be stuck in state
`stopping`.  This situation can then be externally resolved using
`canister_start`.

This repository contains the code for two canisters that can be used to
demonstrate this, and can be used in tests.

Installation
------------

To install the canisters, use `dfx deploy` as usual. Then you have to manually
make sure that the controllers of the `stopper` canister contains both the
`stopper` canister itself, and the `barrier` canister, for example using

    dfx canister --wallet $(dfx identity --network ic get-wallet) call aaaaa-aa update_settings "(record {canister_id = principal \"$(dfx canister --network ic id stopper)\"; settings = record { controllers = opt vec {principal \"$(dfx identity --network ic get-wallet)\"; principal \"$(dfx canister --network ic id stopper)\"; principal \"$(dfx canister --network ic id barrier)\"; principal \"e3mmv-5qaaa-aaaah-aadma-cai\"}}})"

(this also makes your wallet and the [blackhole
canister](https://github.com/ninegua/ic-blackhole) controllers of the
canister).

Now you can use the barrier canister from your tests, using this interface:

    service : {
      enter: () -> ();
      lock: () -> ();
      release: () -> ();
      transaction_notification: () -> ();
      wallet_receive: () -> ();
    }

First you invoke `lock` to close the barrier. Then you can call `enter` as
often as you want, all these calls with not respond. Once you call `release`,
all of these calls will return.

The barrier canister is installed at
[cuptx-eaaaa-aaaai-aa67q-cai](https://ic.rocks/principal/cuptx-eaaaa-aaaai-aa67q-cai),
you can play around with it there.  

The endpoints `transaction_notification` and `wallet_receive` will behave like
`enter` and can be used to test the behaviour of the ICP-ledger (or compatible
ledger) respectively the cycle wallet.

## CAUTION

Most canisters with outstanding calls cannot be upgraded safely.  This means
this canister _could_ be used to stage attacks against any service that you can
trick to call you (e.g. by asking someone to transfer some cycles to your
canister). But of course we woudn't do that. Still, if this worries you, read
[how to protect your canisters from such
attacks](https://www.joachim-breitner.de/blog/789-Zero-downtime_upgrades_of_Internet_Computer_canisters).

## More features

This is meant to be just a proof of concept, and for your own testing needs,
you might need additional features (e.g. multiple independent barriers; better
insight into what is going on). Feel free to clone and extend for your needs.
