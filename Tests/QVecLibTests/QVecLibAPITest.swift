//
//  InputFilesV4URLTests.swift
//  tdLBQVecTool
//
//  Created by Niall Ó Broin on 15/10/2019.
//

import XCTest
@testable import QVecLib
@testable import tdLB

class ProcessTest: XCTestCase {

    var testRootDir: URL!
    var testDirURLs = [URL]()

    override func setUp() {
        super.setUp()

        let testDirStrings = ["plot_full.volume.V5.step_00000050",
                        "plot_rotational_capture.rotational_capture.V5.step_00000050.angle_15.blade_id_0",
                        "plot_slice.XZplane.V5.step_00000050.cut_28",
                        "plot_slice.XZplane.V5.step_00000050.cut_29",
                        "plot_slice.XZplane.V5.step_00000050.cut_30",
                        "plot_vertical_axis.XYplane.V5.step_00001000.cut_20",
                        "plot_vertical_axis.XYplane.V5.step_00001000.cut_21",
                        "plot_vertical_axis.XYplane.V5.step_00001000.cut_22",
                        "plot_vertical_axis.XYplane.V5.step_00000050.cut_20",
                        "plot_vertical_axis.XYplane.V5.step_00000050.cut_21",
                        "plot_vertical_axis.XYplane.V5.step_00000050.cut_22"]

        let fm = FileManager.default
        testRootDir = fm.temporaryDirectory.appendingPathComponent("testRootDirProcessTest", isDirectory: true)

        testDirURLs = testDirStrings.map { testRootDir.appendingPathComponent($0, isDirectory: true) }

        for testDir in testDirURLs {
            try! fm.createDirectory(at: testDir, withIntermediateDirectories: true)
        }

    }

    override func tearDown() {
        super.tearDown()

        let fm = FileManager.default
        try! fm.removeItem(at: testRootDir)

    }

    func testInitOutputKind() {

//        let o = try! OutputDir(rootDir: testRootDir)
//        var q = QVecLib<Float32>(rootDir: o, kind: [.XYplane])
//
//        XCTAssertEqual(q.plotDirByStep.map { $0.key }.sorted(), [50, 1000])
//        XCTAssertEqual(q.plotDirByStep[50]?.count, 3)
//        XCTAssertEqual(q.plotDirByStep[1000]?.count, 3)

    }

}
