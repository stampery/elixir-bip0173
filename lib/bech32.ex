# Copyright (c) 2017 Adán Sánchez de Pedro Crespo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

defmodule Bech32 do
  use Bitwise

  @moduledoc ~S"""
  Encode and decode the Bech32 format, with checksums.
  """

  # Encoding character set. Maps data value -> char
  @charset 'qpzry9x8gf2tvdw0s3jn54khce6mua7l'

  # Human-readable part and data part separator
  @separator 0x31

  # Generator coefficients
  @generator [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]

  @doc ~S"""
  Encode a Bech32 string.

  ## Examples

      iex> Bech32.encode("bech32", [0, 1, 2])
      "bech321qpz4nc4pe"

      iex> Bech32.encode("bc", [0, 14, 20, 15, 7, 13, 26, 0, 25, 18, 6, 11, 13,
        8, 21, 4, 20, 3, 17, 2, 29, 3, 12, 29, 3, 4, 15, 24,20, 6, 14, 30, 22])
      "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4"
  """
  @spec encode(String.t, list(integer)) :: String.t
  def encode(hrp, data) when is_list(data) do
    checksummed = data ++ create_checksum(hrp, data)
    dp = for (i <- checksummed), into: "", do: <<Enum.at(@charset, i)>>
    <<hrp::binary, @separator, dp::binary>>
  end

  @spec encode(String.t, String.t) :: String.t
  def encode(hrp, data) when is_binary(data) do
    encode(hrp, String.to_charlist(data))
  end

  @doc ~S"""
  Decode a Bech32 string.

  ## Examples

      iex> Bech32.decode("bech321qpz4nc4pe")
      {:ok, {"bech32", [0, 1, 2]}}

      iex> Bech32.decode("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4")
      {:ok, {"bc", [0, 14, 20, 15, 7, 13, 26, 0, 25, 18, 6, 11, 13, 8, 21,
        4, 20, 3, 17, 2, 29, 3, 12, 29, 3, 4, 15, 24, 20, 6, 14, 30, 22]}}
  """
  @spec decode(String.t) :: {:ok, {String.t, list}} | {:error, String.t}
  def decode(bech) do
    if (String.downcase(bech) != bech && String.upcase(bech) != bech) do
      {:error, "Bech string uses mixed case."}
    else
      bech_charlist = String.to_charlist(bech)
      if (Enum.find(bech_charlist, fn (c) -> c < 33 || c > 126 end)) do
        {:error, "Bech string contains illegal characters."}
      else
        bech = String.downcase(bech)
        len = Enum.count(bech_charlist)
        pos = len - 1 - Enum.find_index(Enum.reverse(bech_charlist), fn (c) ->
          c == @separator
        end)
        if (pos < 1 || pos + 7  > len || len > 90) do
          {:error, "Bech string is not properly formatted."}
        else
          <<hrp::binary-size(pos), @separator, data::binary>> = bech
          data_charlist = for c <- String.to_charlist(data) do
            Enum.find_index(@charset, fn (d) -> c == d end)
          end
          if (verify_checksum(hrp, data_charlist)) do
            data_len = Enum.count(data_charlist)
            {:ok, {hrp, Enum.slice(data_charlist, 0, data_len - 6)}}
          else
            {:error, "Wrong checksum."}
          end
        end
      end
    end
  end

  # Create a checksum.
  defp create_checksum(hrp, data) do
    values = expand_hrp(hrp) ++ data ++ [0, 0, 0, 0, 0, 0]
    mod = polymod(values) ^^^ 1
    for p <- 0..5, do: (mod >>> 5 * (5 - p)) &&& 31
  end

  # Verify a checksum.
  defp verify_checksum(hrp, data) do
    polymod(expand_hrp(hrp) ++ data) == 1
  end

  # Expand a HRP for use in checksum computation.
  defp expand_hrp(hrp) do
    hrp_charlist = String.to_charlist(hrp)
    a_values = for c <- hrp_charlist, do: c >>> 5
    b_values = for c <- hrp_charlist, do: c &&& 31
    a_values ++ [0] ++ b_values
  end

  # Find the polynomial with value coefficients mod the generator as 30-bit.
  defp polymod(values) do
    Enum.reduce(values, 1, fn (v, chk) ->
      top = chk >>> 25
      chk = ((chk &&& 0x1ffffff) <<< 5) ^^^ v
      Enum.reduce((for i <- 0..4, do: i), chk, fn(i, chk) ->
        chk ^^^ if ((top >>> i) &&& 1) != 0 do
          Enum.at(@generator, i)
        else
          0
        end
      end)
    end)
  end

end
