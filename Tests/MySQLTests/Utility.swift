import Foundation

extension String {
  public func getUnsafeMutablePointer() -> UnsafeMutablePointer<Int8> {
    #if os(OSX)
      let pointer = UnsafeMutablePointer<Int8>.allocate(capacity: self.characters.count + 1)
        (self as NSString).getCString(pointer, maxLength: self.characters.count + 1, encoding: String.Encoding.utf8.rawValue)
      return pointer
    #else
      let otherStr = NSString(string: self)
      return UnsafeMutablePointer<Int8>(mutating: otherStr.utf8String!)
    #endif
  }
}
