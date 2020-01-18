//
//  InputFilesV4URLTests.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 15/10/2019.
//

import XCTest
@testable import tdQVecCore



class tryingTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let testURL = URL.init(fileURLWithPath: "testDirectory", isDirectory: true)


        var testResult = testURL.formatXYPlane(QLength:4, step:1000, atK:5)
        XCTAssertEqual(testResult, "plot_vertical_axis.XYplane.V_4.Q_4.step_00001000.cut_5")

        testResult = testURL.formatQVecBin(name: "test", idi: 1, idj: 1, idk: 1)
        XCTAssertEqual(testResult, "test.node.1.1.1.V4.bin")


    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


