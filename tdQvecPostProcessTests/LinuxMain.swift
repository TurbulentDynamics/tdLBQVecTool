import XCTest

import TDQVecPostProcessTests
import TDQVecLibTests

var tests = [XCTestCaseEntry]()
tests += TDQVecPostProcessTests.allTests()
tests += TDQVecLibTests.allTests()

XCTMain(tests)
