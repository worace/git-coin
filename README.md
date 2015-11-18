## GitCoin

[http://git-coin.herokuapp.com/gitcoins](http://git-coin.herokuapp.com/gitcoins)

GitCoin is a simplistic bitcoin simulator which uses SHA1 Digests of
user-supplied "commit messages" to calculate a current hash target.

GitCoin aims to simulate the "mining" portion of Bitcoin, but other main
components such as the blockchain, peer-to-peer decentralization, and transaction
creation are not included.

### Mining in Cryptocurrencies

Mining is an interesting, if somewhat misunderstood, component of most
cryptocurrency systems. In Bitcoin (and many other systems which follow
its general model), mining serves 2 purposes:

1. Introduce new currency into circulation
2. Impose a "cost" in computational effort that must be contributed
to interact with the system.

How does mining work? For the system to meet its goals, the mining process
needs to be computationally "expensive" (i.e. it requires the computer lots
of time to process). This ensures that coins can't be generated for free,
and attaches some implicit value to the currency.

In Bitcoin and other cryptocurrencies, this problem is often solved through
the use of 1-way hashing algorithms. A hashing algorithm takes in an arbitrary
input and "digests" it into a fixed-length numeric value.

The digest values, however, are unpredictable given the inputs. The message
"pizza" might digest to 1234, while the very similar message "pizz" digests to 5678.
Additionally, with a good hash function, it's impossible, given the digest (5678)
to reverse the process and derive the input ("pizz").

So what if you needed to find a digest matching a specific value? Well, given
the unpredictable nature of the hash digests, you basically have to search randomly.

This, it turns out is how cryptocurrencies design their mining process. Miners
have to search for an input that produces a digest below a specified target
(remember that the digests are basically numeric "fingerprints" of the input
data, so we can compare them numerically).

Since there's no way to predict what message will produce a given digest,
miners are forced to search for a matching input by randomly trying different
values until they get a hit.

This process has to be done repeatedly by a computer, thus ensuring that
miners who want to generate coins have to devote a sufficient amount of
computational "effort" toward the prize.

### GitCoin procedure

The GitCoin server posts a target hash value that miners are trying to
undercut in order to earn coins. The miners attempt to find inputs which
can be hashed to produce a digest value lower than the target.

Additionally, the server includes a "parent" hash which must be combined
with your input when you generate the digest (otherwise we could simply
re-use the same inputs over and over).

The format of the hash process looks like this:

```
digest(parent_hash + new_input_message)
```

### Code Snippets:

Here are some code samples for working with Digests. These
code samples are in ruby, but most languages will include a Digest
library for working with common hash functions.

To be awarded gitcoins, users must submit new commit messages which
generate SHA digests smaller than the current target hash.

To compare the your Hex digest with the target, convert it to
a number, e.g.:

```ruby
"1f6ccd2be75f1cc94a22a773eea8f8aeb5c68217".hex < "75e2575535d998d7cfb6b627ffc60550c1e23301".hex
=> true
```

To generate a new hash, use `Digest::SHA1.hexdigest`
to evaluate the digest value of a given string, e.g.:

```ruby
require 'digest'
Digest::SHA1.hexdigest("my-string")
```

Remember that the inputs of our digest must be:

1. The parent hash (provided by the server)
2. A random message of our choosing

So to attempt a hash, we could use a process something like this:

```ruby
require "digest"

target = "00000016db5fc64969e96104674f8b620bb08bd3"
parent_hash = "0000001e46f2b8147808753084b791be453d7517"
input_message = "gimme coins"
attempt = Digest::SHA1.hexdigest(parent_hash + input_message)

if attempt.hex < target.hex
  puts "Congrats, you got a coin!"
else
  puts "Bummer, your hash isn't low enough. Keep searching!"
end
```

If we have found an input which, in combination with the parent hash
produces a digest lower than the target, then we can send this message
to the gitcoin server and be awarded a coin!

However the most likely scenario is that our digest is too large.
In that case, we simply pick another input message and try again!

A full-featured miner client would simply loop through this process
repeatedly until it finds an appropriate input and can earn a coin.

### REST API

Unlike real Bitcoin which operates over a de-centralized peer-to-peer network,
GitCoin is built around a single server which manages the awarding
of coins and setting of targets.

To participate in the mining process, your miner will need to communicate with
the server via its HTTP API.

Here are the supported endpoints (listed by verb and path):

**GET /target**

This will return a JSON object containing the information needed to
mine for a coin, which includes the current target and the parent
hash.

The response will look like this:

```json
{
 "target": "00000016db5fc64969e96104674f8b620bb08bd3",
 "parent_hash": "0000001e46f2b8147808753084b791be453d7517"
}
```

Your miner will need to parse this response and use it to generate digests
and check them against the target. Note that these inputs are returned
as hexadecimal strings representing the numeric values.

Example:

```ruby
require "hurley"
=> true
require "json"
=> true
target_payload = JSON.parse(Hurley.get("http://git-coin.herokuapp.com/target").body)
=> {"target"=>"00000016db5fc64969e96104674f8b620bb08bd3", "parent_hash"=>"00000016db5fc64969e96104674f8b620bb08bd3"}
target = target_payload["target"]
=> "00000016db5fc64969e96104674f8b620bb08bd3"
parent_hash = target_payload["parent_hash"]
=> "00000016db5fc64969e96104674f8b620bb08bd3"
```

**POST /hash**

Attempt to generate a gitcoin by supplying a message which will be
Digested and compared against the current hash target. If your message
generates a lower hash, you will get a coin!

It expects 2 parameters:

1. `owner` -- The name of the owner to whom the gitcoin will be
awarded. There's currently no way to spend gitcoins, but you'll definitely
want to include your name for bragging rights!
2. `message` -- The input you discovered which produces a digest smaller than
the current target. Remember that your message will be concatenated with the
parent hash, digested, and compared against the target

Example:

```ruby
require "hurley"
require "json"

resp = Hurley.post("http://git-coin.herokuapp.com/hash", owner: "worace", message: "pizza")
=> #<Hurley::Response POST http://git-coin.herokuapp.com/hash == 200 (98 bytes) 4184ms>
resp.body
=> "{\"success\":false,\"gitcoin_assigned\":false,\"new_target\":\"00000016db5fc64969e96104674f8b620bb08bd3\"}"
JSON.parse(resp.body)

```
example cUrl command:

```
curl -v -X POST "git-coin.herokuapp.com/hash?message=2015-01-21+16%3A27%3A54+-0700&owner=worace"
```

**GET /gitcoins**

See a list of all the previously awarded gitcoins.

#### Todos

GitCoin Todo

- [X] add auto-reset tripper (after X 0's?)
- [X] remove dupes in prod db
- [X] increase scaling factor
- [X] scrape message lists to send to coin owners (use auth'ed coinbase endpoint)
- [ ] shareable miner gem?

__Inspiration for this project came from the Stripe CTF3 challenge,
which included gitcoins as one its levels.__
