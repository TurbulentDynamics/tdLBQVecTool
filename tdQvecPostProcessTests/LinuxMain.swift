import XCTest

import TDQvecPostProcessTests
import TDQvecLibTests

var tests = [XCTestCaseEntry]()
tests += TDQvecPostProcessTests.allTests()
tests += TDQvecLibTests.allTests()

XCTMain(tests)
