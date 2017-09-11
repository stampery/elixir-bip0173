# BIP-0173

**Elixir implementation of Bitcoin's address format for native SegWit outputs.**

## About BIP-0173 and Bech32

[BIP-0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) proposes a checksummed base32 format, "Bech32", and a standard for native segregated witness output addresses using it.

You can find more information in [the original proposal](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) by [@sipa](https://github.com/sipa) and [@gmaxwell](https://github.com/gmaxwell).

## Installation

  1. Add `bip0173` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bip0173, "~> 0.1.0"}]
    end
    ```

## How to use

You can find the full API reference and examples in the [online documentation at Hexdocs](https://hexdocs.pm/bip0173/api-reference.html).
