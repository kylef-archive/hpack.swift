public class Encoder {
  public let headerTable: HeaderTable

  public init(headerTable: HeaderTable? = nil) {
    self.headerTable = headerTable ?? HeaderTable()
  }

  public typealias HeaderTuple = (name: String, value: String, sensitive: Bool)

  public func encode(headers: [Header]) -> [UInt8] {
    return encode(headers.map { name, value in (name, value, false) })
  }

  public func encode(headers: [HeaderTuple]) -> [UInt8] {
    return headers.map(encode).reduce([], combine: +)
  }

  func encode(name: String, value: String, sensitive: Bool) -> [UInt8] {
    if let index = headerTable.search(name: name, value: value) {
      return encodeIndexed(index)
    }

    return encodeLiteral(name, value: value)
  }

  func encodeLiteral(name: String, value: String) -> [UInt8] {
    var bytes: [UInt8] = [16]
    bytes.append(UInt8(name.utf8.count))
    bytes += name.utf8
    bytes.append(UInt8(value.utf8.count))
    bytes += value.utf8
    return bytes
  }

  func encodeIndexed(index: Int) -> [UInt8] {
    var bytes = encodeInt(index, prefixBits: 7)
    bytes[0] |= 0x80
    return bytes
  }
}


/// Encodes an integer according to the encoding rules defined in the HPACK spec
func encodeInt(value: Int, prefixBits: Int) -> [UInt8] {
  let maxNumber = (2 ** prefixBits) - 1

  if value < maxNumber {
    return [UInt8(value)]
  }

  var elements: [UInt8] = [UInt8(maxNumber)]
  var value = value - maxNumber

  while value >= 128 {
    elements.append(UInt8(value % 128) + 128)
    value = value / 128
  }

  elements.append(UInt8(value))
  return elements
}
