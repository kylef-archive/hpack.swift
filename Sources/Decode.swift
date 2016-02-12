enum DecoderError : ErrorType {
  case Unsupported
}

public class Decoder {
  public init() {}

  public func decode(data: [UInt8]) throws -> [Header] {
    var headers: [Header] = []
    var index = data.startIndex

    while index != data.endIndex {
      let byte = data[index]

      if byte & 0b1000_0000 == 0b1000_0000 {
        // Indexed Header Field Representation
        throw DecoderError.Unsupported
      } else if byte & 0b1100_0000 == 0b0100_0000 {
        // Literal Header Field with Incremental Indexing
        throw DecoderError.Unsupported
      } else if byte & 0b1111_0000 == 0b0000_0000 {
        // Literal Header Field without Indexing
        throw DecoderError.Unsupported
      } else if byte & 0b1111_0000 == 0b0001_0000 {
        // Literal Header Field never Indexed
        let nameLengthIndex = index.successor()

        let nameLength = Int(data[nameLengthIndex])
        let nameStartIndex = nameLengthIndex.successor()
        let nameEndIndex = nameStartIndex.advancedBy(nameLength)

        let valueLengthIndex = nameEndIndex

        let valueLength = Int(data[valueLengthIndex])
        let valueStartIndex = valueLengthIndex.successor()
        let valueEndIndex = valueStartIndex.advancedBy(valueLength)

        let nameBytes = (data[nameStartIndex ..< nameEndIndex] + [0]).map { CChar($0) }
        let valueBytes = (data[valueStartIndex ..< valueEndIndex] + [0]).map { CChar($0) }
        let name = String.fromCString(nameBytes)
        let value = String.fromCString(valueBytes)

        if let name = name, value = value {
          headers.append((name, value))
        }

        index = valueEndIndex
      } else if byte & 0b1110_0000 == 0b0010_0000 {
        // Dynamic Table Size Update
        throw DecoderError.Unsupported
      } else {
        throw DecoderError.Unsupported
      }
    }

    return headers
  }
}
