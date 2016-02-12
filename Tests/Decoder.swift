import Spectre
import hpack


func testDecoder() {
  describe("HPACK Decoder") {
    let decoder = Decoder()

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
}
