enum DecoderError : ErrorType {
  case IntegerEncoding
  case InvalidTableIndex
  case InvalidString
  case Unsupported
}

public class Decoder {
  public let headerTable: HeaderTable

  public init(headerTable: HeaderTable? = nil) {
    self.headerTable = headerTable ?? HeaderTable()
  }

  public func decode(data: [UInt8]) throws -> [Header] {
    var headers: [Header] = []
    var index = data.startIndex

    while index != data.endIndex {
      let byte = data[index]

      if byte & 0b1000_0000 == 0b1000_0000 {
        // Indexed Header Field Representation
        let (header, consumed) = try decodeIndexed(Array(data[index..<data.endIndex]))
        headers.append(header)
        index = index.advancedBy(consumed)
      } else if byte & 0b1100_0000 == 0b0100_0000 {
        // Literal Header Field with Incremental Indexing
        throw DecoderError.Unsupported
      } else if byte & 0b1111_0000 == 0b0000_0000 {
        // Literal Header Field without Indexing
        let (header, consumed) = try decodeLiteral(Array(data[index..<data.endIndex]), prefix: 4)
        headers.append(header)
        index = index.advancedBy(consumed)
      } else if byte & 0b1111_0000 == 0b0001_0000 {
        // Literal Header Field never Indexed
        let (name, nameEndIndex) = try decodeString(Array(data[index + 1 ..< data.endIndex]))
        let (value, valueEndIndex) = try decodeString(Array(data[(index + nameEndIndex + 1) ..< data.endIndex]))
        headers.append((name, value))

        index = index.advancedBy(1).advancedBy(nameEndIndex).advancedBy(valueEndIndex)
      } else if byte & 0b1110_0000 == 0b0010_0000 {
        // Dynamic Table Size Update
        throw DecoderError.Unsupported
      } else {
        throw DecoderError.Unsupported
      }
    }

    return headers
  }

  /// Decodes a header represented using the indexed representation
  func decodeIndexed(bytes: [UInt8]) throws -> (header: Header, consumed: Int) {
    let index = try decodeInt(bytes, prefixBits: 7)

    if let header = headerTable[index.value] {
      return (header, index.consumed)
    }

    throw DecoderError.InvalidTableIndex
  }

  func decodeLiteral(bytes: [UInt8], prefix: Int) throws -> (value: Header, consumed: Int) {
    let (index, consumed) = try decodeInt(bytes, prefixBits: prefix)

    let name: String

    if let header = headerTable[index] {
      name = header.name
    } else {
      throw DecoderError.InvalidTableIndex
    }

    let (value, valueConsumed) = try decodeString(Array(bytes[bytes.startIndex.advancedBy(consumed)..<bytes.endIndex]))
    return ((name, value), consumed + valueConsumed)
  }

  func decodeString(bytes: [UInt8]) throws -> (value: String, consumed: Int) {
    if bytes.isEmpty {
      throw DecoderError.Unsupported
    }

    let length = Int(bytes[0])
    let startIndex = bytes.startIndex.successor()
    let endIndex = startIndex.advancedBy(length)

    let bytes = (bytes[startIndex ..< endIndex] + [0]).map { CChar($0) }
    if let value = String.fromCString(bytes) {
      return (value, endIndex)
    }

    throw DecoderError.InvalidString
  }
}


/// Decodes an integer according to the encoding rules defined in the HPACK spec
func decodeInt(data: [UInt8], prefixBits: Int) throws -> (value: Int, consumed: Int) {
  guard !data.isEmpty else { throw DecoderError.IntegerEncoding }

  let maxNumber = (2 ** prefixBits) - 1
  let mask = UInt8(0xFF >> (8 - prefixBits))
  var index = 0

  func multiple(index: Int) -> Int {
    return 128 ** (index - 1)
  }

  var number = Int(data[index] & mask)

  if number == maxNumber {
    while true {
      index += 1

      if index >= data.count {
        throw DecoderError.IntegerEncoding
      }

      let nextByte = Int(data[index])
      if nextByte >= 128 {
        number += (nextByte - 128) * multiple(index)
      } else {
        number += nextByte * multiple(index)
        break
      }
    }
  }

  return (number, index + 1)
}
