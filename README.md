# HTTP/2 Header Encoding in Swift

HPACK ([RFC 7541](https://tools.ietf.org/html/rfc7541)) implementation in Swift.

## Usage

### Encoding a set of headers

```swift
let headers: [Header] = [
  (":method", "GET"),
  (":path", "/"),
  ("Accept", "application/json"),
]

let encoder = hpack.Encoder()
let bytes = try encoder.encode(headers)
```

### Decoding a set of headers

```swift
let bytes: [UInt8] = []

let decoder = hpack.Decoder()
let headers = try decoder.decode(bytes)
```
