import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(tdQVecCoreTests.allTests),
    ]
}
#endif
