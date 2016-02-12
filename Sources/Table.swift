/// Implements the combined static and dynamic header table
/// See RFC7541 Section 2.3
public struct HeaderTable {
  /// Constant list of static headers. See RFC7541 Section 2.3.1 A
  let staticEntries: [Header] = [
    (":authority", ""),
    (":method", "GET"),
    (":method", "POST"),
    (":path", "/"),
    (":path", "/index.html"),
    (":scheme", "http"),
    (":scheme", "https"),
    (":status", "200"),
    (":status", "204"),
    (":status", "206"),
    (":status", "304"),
    (":status", "400"),
    (":status", "404"),
    (":status", "500"),
    ("accept-charset", ""),
    ("accept-encoding", "gzip, deflate"),
    ("accept-language", ""),
    ("accept-ranges", ""),
    ("accept", ""),
    ("access-control-allow-origin", ""),
    ("age", ""),
    ("allow", ""),
    ("authorization", ""),
    ("cache-control", ""),
    ("content-disposition", ""),
    ("content-encoding", ""),
    ("content-language", ""),
    ("content-length", ""),
    ("content-location", ""),
    ("content-range", ""),
    ("content-type", ""),
    ("cookie", ""),
    ("date", ""),
    ("etag", ""),
    ("expect", ""),
    ("expires", ""),
    ("from", ""),
    ("host", ""),
    ("if-match", ""),
    ("if-modified-since", ""),
    ("if-none-match", ""),
    ("if-range", ""),
    ("if-unmodified-since", ""),
    ("last-modified", ""),
    ("link", ""),
    ("location", ""),
    ("max-forwards", ""),
    ("proxy-authenticate", ""),
    ("proxy-authorization", ""),
    ("range", ""),
    ("referer", ""),
    ("refresh", ""),
    ("retry-after", ""),
    ("server", ""),
    ("set-cookie", ""),
    ("strict-transport-security", ""),
    ("transfer-encoding", ""),
    ("user-agent", ""),
    ("vary", ""),
    ("via", ""),
    ("www-authenticate", ""),
  ]

  public init() {}

  public subscript(index: Int) -> Header? {
    /// Returns the entry specified by index
    get {
      guard index > 0 else { return nil }

      if index <= staticEntries.count {
        return staticEntries[index - 1]
      }

      return nil
    }
  }

  /// Searches the table for the entry specified by name and value
  public func search(name name: String, value: String) -> Int? {
    let entry = staticEntries.enumerate().filter { index, header in
      header.name == name && header.value == value
    }.first

    if let entry = entry {
      return entry.0 + 1
    }

    return nil
  }
}
