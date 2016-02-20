import Spectre
@testable import hpack


func testDecoder() {
  describe("HPACK Decoder") {
    let decoder = Decoder()

    $0.it("can decode indexed header field") {
      let data: [UInt8] = [130]

      let headers = try decoder.decode(data)
      try expect(headers.count) == 1
      try expect(headers[0].name) == ":method"
      try expect(headers[0].value) == "GET"
    }

    $0.it("can decode literal header field without indexing") {
      let path = "/sample/path"
      let data: [UInt8] = [4, UInt8(path.utf8.count)] + path.utf8

      let headers = try decoder.decode(data)
      try expect(headers.count) == 1
      try expect(headers[0].name) == ":path"
      try expect(headers[0].value) == path
    }

    $0.it("can decode un-indexed literal header field without indexing") {
      let data: [UInt8] = [
        16,
        8,  // length of key
        112, 97, 115, 115, 119, 111, 114, 100,  // key: password
        6,  // length of value
        115, 101, 99, 114, 101, 116,  // value: secret
      ]

      let headers = try decoder.decode(data)
      try expect(headers.count) == 1
      try expect(headers[0].name) == "password"
      try expect(headers[0].value) == "secret"
    }
  }

  // Decoding tests from HPACK Specification
  describe("Decoding Integer") {
    $0.it("can decode 10 with 5-bit prefix") {
      let value = try decodeInt([10], prefixBits: 5)
      try expect(value.value) == 10
      try expect(value.consumed) == 1
    }

    $0.it("can decode 1337 with 5-bit prefix") {
      let value = try decodeInt([31, 154, 10], prefixBits: 5)
      try expect(value.value) == 1337
      try expect(value.consumed) == 3
    }

    $0.it("can decode 42 with 8-bit prefix") {
      let value = try decodeInt([42], prefixBits: 8)
      try expect(value.value) == 42
      try expect(value.consumed) == 1
    }

    $0.it("fails to decode empty bytes") {
      try expect(try decodeInt([], prefixBits: 8)).toThrow()
    }

    $0.it("fails with insufficient data") {
      try expect(try decodeInt([31], prefixBits: 5)).toThrow()
    }
  }
}
