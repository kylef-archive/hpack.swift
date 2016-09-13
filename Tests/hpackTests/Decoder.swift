import Spectre
@testable import hpack


public func testDecoder() {
  describe("HPACK Decoder") {
    let decoder = Decoder()

    $0.it("table header size default") {
      try expect(decoder.headerTableSize) == 4096
    }

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

    $0.describe("decoding literal header field with indexing") {
      let path = "/sample/path"
      let bytes: [UInt8] = [68, UInt8(path.utf8.count)] + path.utf8

      $0.it("decodes the header") {
        let decoder = Decoder()
        let headers = try decoder.decode(bytes)

        try expect(headers.count) == 1
        try expect(headers[0].name) == ":path"
        try expect(headers[0].value) == path
      }

      $0.it("adds entry to header table") {
        let decoder = Decoder()
        try decoder.decode(bytes)

        try expect(decoder.headerTable.search(name: ":path", value: path)) == 62
      }
    }

    $0.it("can decode request examples without huffman") {
      // Kindly borrowed from https://github.com/python-hyper/hpack/blob/62e595f9d6bf8acb1af7292650228b9fcf94e06e/test/test_hpack.py#L344

      let firstBytes: [UInt8] = [130, 134, 132, 1, 15] + "www.example.com".utf8
      let firstHeaders: [Header] = [
        (":method", "GET"),
        (":scheme", "http"),
        (":path", "/"),
        (":authority", "www.example.com"),
      ]

      let secondBytes: [UInt8] = [130, 134, 132, 1, 15] + "www.example.com".utf8 + [15, 9, 8] + "no-cache".utf8
      let secondHeaders: [Header] = [
        (":method", "GET"),
        (":scheme", "http"),
        (":path", "/"),
        (":authority", "www.example.com"),
        ("cache-control", "no-cache"),
      ]

      let hostname = "www.example.com".utf8
      let customKey: [UInt8] = [10] + "custom-key".utf8
      let customValue: [UInt8] = [12] + "custom-value".utf8

      let thirdBytes: [UInt8] = [130, 135, 133, 1, 15] + hostname + [64] + customKey + customValue
      let thirdHeaders: [Header] = [
        (":method", "GET"),
        (":scheme", "https"),
        (":path", "/index.html"),
        (":authority", "www.example.com"),
        ("custom-key", "custom-value"),
      ]

      let decoder = Decoder()
      let firstDecoded = try decoder.decode(firstBytes)
      let secondDecoded = try decoder.decode(secondBytes)
      let thirdDecoded = try decoder.decode(thirdBytes)

      func compare(_ expected: [Header], _ actual: [Header]) throws {
        try expect(actual.count) == expected.count

        for (index, header) in actual.enumerated() {
          try expect(header.name) == expected[index].name
          try expect(header.value) == expected[index].value
        }
      }

      try compare(firstHeaders, firstDecoded)
      try compare(secondHeaders, secondDecoded)
      try compare(thirdHeaders, thirdDecoded)

      try expect(decoder.headerTable.search(name: "custom-key", value: "custom-value")) == 62
    }

    $0.it("updates the maximum header size while decoding") {
      let bytes: [UInt8] = [62]
      let headers = try decoder.decode(bytes)

      try expect(headers.isEmpty).to.beTrue()
      try expect(decoder.headerTableSize) == 30
    }

    $0.it("does not support decoding huffman") {
      let bytes: [UInt8] = [
        130, 134, 132, 1, 140, 241, 227, 194, 229, 242, 58, 107, 160,
        171, 144, 244, 255
      ]
      try expect(try decoder.decode(bytes)).toThrow()
    }

    $0.xit("can decode request examples without huffman") {
      // Kindly borrowed from https://github.com/python-hyper/hpack/blob/62e595f9d6bf8acb1af7292650228b9fcf94e06e/test/test_hpack.py#L394

      let firstBytes: [UInt8] = [
        130, 134, 132, 1, 140, 241, 227, 194, 229, 242, 58, 107, 160,
        171, 144, 244, 255
      ]
      let firstHeaders: [Header] = [
        (":method", "GET"),
        (":scheme", "http"),
        (":path", "/"),
        (":authority", "www.example.com"),
      ]

      let secondBytes: [UInt8] = [
        130, 134, 132, 1, 140, 241, 227, 194, 229, 242, 58, 107, 160, 171,
        144, 244, 255, 15, 9, 134, 168, 235, 16, 100, 156, 191
      ]
      let secondHeaders: [Header] = [
        (":method", "GET"),
        (":scheme", "http"),
        (":path", "/"),
        (":authority", "www.example.com"),
        ("cache-control", "no-cache"),
      ]

      let hostname = "www.example.com".utf8
      let customKey: [UInt8] = [10] + "custom-key".utf8
      let customValue: [UInt8] = [12] + "custom-value".utf8

      let thirdBytes: [UInt8] = [
        130, 135, 133, 1, 140, 241, 227, 194, 229, 242, 58, 107, 160,
        171, 144, 244, 255, 64, 136, 37, 168, 73, 233, 91, 169, 125,
        127, 137, 37, 168, 73, 233, 91, 184, 232, 180, 191
      ]
      let thirdHeaders: [Header] = [
        (":method", "GET"),
        (":scheme", "https"),
        (":path", "/index.html"),
        (":authority", "www.example.com"),
        ("custom-key", "custom-value"),
      ]

      let decoder = Decoder()
      let firstDecoded = try decoder.decode(firstBytes)
      let secondDecoded = try decoder.decode(secondBytes)
      let thirdDecoded = try decoder.decode(thirdBytes)

      func compare(_ expected: [Header], _ actual: [Header]) throws {
        try expect(actual.count) == expected.count

        for (index, header) in actual.enumerated() {
          try expect(header.name) == expected[index].name
          try expect(header.value) == expected[index].value
        }
      }

      try compare(firstHeaders, firstDecoded)
      try compare(secondHeaders, secondDecoded)
      try compare(thirdHeaders, thirdDecoded)

      try expect(decoder.headerTable.search(name: "custom-key", value: "custom-value")) == 62
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
