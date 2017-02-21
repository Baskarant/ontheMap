
import Foundation

extension NSRange {

    static func make(from range: Range<String.Index>, for string: String) -> NSRange {
        return NSMakeRange(string.distance(from: string.startIndex, to: range.lowerBound),
                                  string.distance(from: range.lowerBound, to: range.upperBound))
    }
 
    func swiftRange() {
    
    }
    
}
