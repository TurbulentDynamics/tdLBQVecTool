//
//  InputFilesV4URLTests.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 15/10/2019.
//

import XCTest
@testable import tdQVecLib

class QVecDimsTest: XCTestCase {

    var testDirURL: URL!

    override func setUp() {
        let fm = FileManager.default
        let testDir = fm.currentDirectoryPath + "/testQVecDim.json"
        testDirURL = URL(fileURLWithPath: testDir, isDirectory: false)

    }

    override func tearDown() {
        super.tearDown()
        let fm = FileManager.default

        do {
            try fm.removeItem(at: URL(fileURLWithPath: testDirURL.path))
        } catch {
            //Some tests failed and Dir was not created
        }

    }

    func readAndWrite() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let dim1 = QVecDim(qDataType: "Float32",
                          qOutputLength: 4,
                          binFileSizeInStructs: 1000,
                          coordsType: "UInt16",
                          gridX: 3, gridY: 3, gridZ: 3,
                          hasColRowtCoords: true, hasGridtCoords: true,
                          idi: 1, idj: 1, idk: 1,
                          name: "testDim",
                          ngx: 10, ngy: 10, ngz: 10,
                          structName: "tDisk_grid_colrow_Q4_V4")

        try! dim1.write(to: testDirURL)

        let dim2 = try! QVecDim(testDirURL)

        XCTAssertEqual(dim1.binFileSizeInStructs, dim2.binFileSizeInStructs)
        XCTAssertEqual(dim1.structName, dim2.structName)

    }

}
