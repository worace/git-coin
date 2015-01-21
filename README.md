## GitCoin

[http://git-coin.herokuapp.com/gitcoins](http://git-coin.herokuapp.com/gitcoins)

GitCoin is a simplistic bitcoin simulator which uses SHA1 Digests of
user-supplied "commit messages" to calculate a current hash target.

To be awarded gitcoins, users must submit new commit messages which
generate SHA digests smaller than the current target hash.

To compare the numeric value of your digest with the target (or any
other hash), use String#hex (in Ruby, or the equivalent in your
language) EG:

```
> "1f6ccd2be75f1cc94a22a773eea8f8aeb5c68217".hex < "75e2575535d998d7cfb6b627ffc60550c1e23301".hex
=> true
```

### Generating Digests:

Use `Digest::SHA1.hexdigest` to evaluate the digest value of a given
string, e.g.:

```
require 'digest'
Digest::SHA1.hexdigest("my-string")
```

### Available Endpoints:


GET /target

This will render the current hash target as text. To be awarded a
gitcoin, your commit messages must digest to a value smaller than this
target.

GET /gitcoins

See a list of all the previously awarded gitcoins.

POST /hash

Attempt to generate a gitcoin by supplying a message which will be
Digested and compared against the current hash target. If your message
generates a lower hash, you will get a coin!

param: owner -- the name of the owner to whom the gitcoin will be
awarded (make sure you submit your name here in order to get credit for
your gitcoins)

param: message -- The message from which you are trying to generate a
gitcoin.

example cUrl command:

```
curl -v -X POST "git-coin.herokuapp.com/hash?message=2015-01-21+16%3A27%3A54+-0700&owner=worace"
```




__Inspiration for this project came from the Stripe CTF3 challenge,
which included gitcoins as one its levels.__
