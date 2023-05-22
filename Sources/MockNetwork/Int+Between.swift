import Foundation

extension Int {
  func between(_ from: Int, and end: Int) -> Bool {
    self >= from && self <= end
  }
}
