import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TDQvecLibTests.allTests),
    ]
}
#endif



