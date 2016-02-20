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

print(bytes)
```

#### Secure headers

You may also pass a secure parameter when encoding a header, which allows you
to prevent the header from being added to the header table.

```swift
let bytes = try encoder.encode([
  ("secret", "secret-key", true),
])

print(bytes)
```

### Decoding a set of headers

```swift
let bytes: [UInt8] = [130]

let decoder = hpack.Decoder()
let headers = try decoder.decode(bytes)

for header in headers {
  print(header.name)
  print(header.value)
}
```
