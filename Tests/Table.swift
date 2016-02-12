import Spectre
import hpack


func testTable() {
  describe("HeaderTable") {
    let table = HeaderTable()

    $0.describe("subscripting") {
      $0.it("returns nil for invalid entry") {
        try expect(table[0]).to.beNil()
        try expect(table[100]).to.beNil()
      }

      $0.it("can lookup for static entries") {
        let authority = table[1]
        try expect(authority?.name) == ":authority"
        try expect(authority?.value) == ""

        let method = table[2]
        try expect(method?.name) == ":method"
        try expect(method?.value) == "GET"
      }
    }

    $0.describe("searching") {
      $0.it("can search for static entry") {
        let index = table.search(name: ":method", value: "GET")
        try expect(index) == 2
      }
    }
  }
}
