//
//  InputFilesV4URLTests.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 15/10/2019.
//

import XCTest



class XXformatQVecFileRoot: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let result = XXformatQVecFileRoot("test", 1, 1, 1)
        XCTAssertEqual(result, "test.node.1.1.1.V4")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


