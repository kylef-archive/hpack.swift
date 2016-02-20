import Spectre
@testable import hpack


func testEncoder() {
  describe("HPACK Encoder") {
    let encoder = Encoder()

    $0.describe("header table size") {
      $0.it("allows updating table header size") {
        let encoder = Encoder()
        encoder.headerTableSize = 20

        try expect(encoder.headerTableSize) == 20
      }

      $0.it("updates the header when encoding") {
        let encoder = Encoder()
        encoder.headerTableSize = 20
        encoder.headerTableSize = 30
        encoder.headerTableSize = 10

        let bytes = encoder.encode([Header]())
        try expect(bytes.count) == 3
        try expect(bytes[0]) == 52
        try expect(bytes[1]) == 62
        try expect(bytes[2]) == 42
      }
    }

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

    $0.describe("encoding literal header field with indexing") {
      let encoder = Encoder()
      let path = "/sample/path"
      let bytes = encoder.encode([(":path", path)])

      $0.it("returns expected bytes") {
        let expectedBytes: [UInt8] = [68, UInt8(path.utf8.count)] + path.utf8

        try expect(bytes.count) == expectedBytes.count
        for (index, byte) in expectedBytes.enumerate() {
          try expect(bytes[index]) == byte
        }
      }

      $0.it("adds entry to header table") {
        try expect(encoder.headerTable.search(name: ":path", value: path)) == 62
      }
    }

    $0.describe("encoding literal header field without indexing") {
      let path = "/sample/path"
      let bytes = encoder.encode([(":path", path, true)])

      $0.it("returns expected bytes") {
        let expectedBytes: [UInt8] = [20, UInt8(path.utf8.count)] + path.utf8

        try expect(bytes.count) == expectedBytes.count
        for (index, byte) in expectedBytes.enumerate() {
          try expect(bytes[index]) == byte
        }
      }

      $0.it("does not add entry to header table") {
        try expect(encoder.headerTable.search(name: ":path", value: path)).to.beNil()
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
