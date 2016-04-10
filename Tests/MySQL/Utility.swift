import Foundation

extension String {
  public func getUnsafeMutablePointer() -> UnsafeMutablePointer<Int8> {
    #if os(OSX)
      let pointer = UnsafeMutablePointer<Int8>(allocatingCapacity: self.characters.count + 1)
      (self as NSString).getCString(pointer, maxLength: self.characters.count + 1, encoding: NSUTF8StringEncoding)
      return pointer
    #else
      let otherStr = NSString(string: self)
      return UnsafeMutablePointer<Int8>(otherStr.UTF8String)
    #endif
  }
}
