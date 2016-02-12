public class Encoder {
  public init() {}

  public typealias HeaderTuple = (name: String, value: String, sensitive: Bool)

  public func encode(headers: [Header]) -> [UInt8] {
    return encode(headers.map { name, value in (name, value, false) })
  }

  public func encode(headers: [HeaderTuple]) -> [UInt8] {
    return headers.map(encode).reduce([], combine: +)
  }

  func encode(name: String, value: String, sensitive: Bool) -> [UInt8] {
    var bytes: [UInt8] = [16]
    bytes.append(UInt8(name.utf8.count))
    bytes += name.utf8
    bytes.append(UInt8(value.utf8.count))
    bytes += value.utf8
    return bytes
  }
}
