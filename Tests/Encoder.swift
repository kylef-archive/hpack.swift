import Spectre
@testable import hpack


func testEncoder() {
  describe("HPACK Encoder") {
    let encoder = Encoder()

    $0.it("can encode header field from header table index") {
      let bytes = encoder.encode([(":method", "GET")])
      try expect(bytes.count) == 1
      try expect(bytes[0]) == 130
    }

    $0.it("can encode sensitive literal header field without indexing") {
      let bytes = encoder.encode([("password", "secret", true)])

      let expectedBytes: [UInt8] = [
        16,
        8,  // length of key
        112, 97, 115, 115, 119, 111, 114, 100,  // key: password
        6,  // length of value
        115, 101, 99, 114, 101, 116,  // value: secret
      ]

      try expect(bytes.count) == expectedBytes.count
      for (index, byte) in expectedBytes.enumerate() {
        try expect(bytes[index]) == byte
      }
    }
  }

  // Encoding tests from HPACK Specification
  describe("Encoding Integer") {
    $0.it("can encode 10 with 5-bit prefix") {
      let bytes = encodeInt(10, prefixBits: 5)
      try expect(bytes.count) == 1
      try expect(bytes[0]) == 10
    }

    $0.it("can encode 1337 with 5-bit prefix") {
      let bytes = encodeInt(1337, prefixBits: 5)
      try expect(bytes.count) == 3
      try expect(bytes[0]) == 31
      try expect(bytes[1]) == 154
      try expect(bytes[2]) == 10
    }

    $0.it("can encode 42 with 8-bit prefix") {
      let bytes = encodeInt(42, prefixBits: 8)
      try expect(bytes.count) == 1
      try expect(bytes[0]) == 42
    }
  }
}
