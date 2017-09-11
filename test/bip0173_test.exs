defmodule BIP0173Test do
  use ExUnit.Case
  doctest Bech32
  doctest SegwitAddr

  @valid_checksum [
    "A12UEL5L",
    "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
    "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
    "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
    "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
  ]

  @valid_address [
    ["BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4", "0014751e76e8199196d454941c45d1b3a323f1433bd6"],
    ["tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
    "00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"],
    ["bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
    "5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6"],
    ["BC1SW50QA3JX3S", "6002751e"],
    ["bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj", "5210751e76e8199196d454941c45d1b3a323"],
    ["tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
    "0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"],
  ]

  @invalid_address [
    "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
    "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
    "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
    "bc1rw5uspcuh",
    "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
    "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
    "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
    "tb1pw508d6qejxtdg4y5r3zarqfsj6c3",
    "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
  ]

  test "verify_checksum" do
    for bech <- @valid_checksum do
      assert {:ok, {hrp, _program}} = Bech32.decode(bech)
      assert hrp != nil
    end
  end

  test "valid address" do
    for [addr, hex] <- @valid_address do
      assert {:ok, {hrp, version, program}} = SegwitAddr.decode(addr)
      assert version != nil
      assert SegwitAddr.encode(hrp, version, program) == String.downcase(addr)
      assert SegwitAddr.to_script_pub_key(version, program) == hex
    end
  end

  test "invalid address" do
    for [addr, _hex] <- @invalid_address do
      assert {:error, _} = SegwitAddr.decode(addr)
    end
  end
end
