import Spectre
import hpack


func testEncoder() {
  describe("HPACK Encoder") {
    let encoder = Encoder()

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
}
