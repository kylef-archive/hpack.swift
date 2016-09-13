import XCTest


class HpackTests: XCTestCase {
  func testRunHpack() {
    testTable()
    testEncoder()
    testDecoder()
  }
}
