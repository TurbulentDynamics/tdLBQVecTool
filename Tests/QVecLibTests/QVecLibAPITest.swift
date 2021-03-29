//
//  InputFilesV4URLTests.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 15/10/2019.
//

import XCTest
@testable import QVecLib
@testable import tdLBOutput

class ProcessTest: XCTestCase {

    var testRootDir: URL!
    var testDirURLs = [URL]()

    override func setUp() {
        super.setUp()

        let testDirStrings = ["plot_full.volume.V_4.Q_4.step_00000050",
                        "plot_rotational_capture.rotational_capture.V_4.Q_4.step_00000050.angle_15.blade_id_0",
                        "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28",
                        "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_29",
                        "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_30",
                        "plot_vertical_axis.XYplane.V_4.Q_4.step_00001000.cut_20",
                        "plot_vertical_axis.XYplane.V_4.Q_4.step_00001000.cut_21",
                        "plot_vertical_axis.XYplane.V_4.Q_4.step_00001000.cut_22",
                        "plot_vertical_axis.XYplane.V_4.Q_4.step_00000050.cut_20",
                        "plot_vertical_axis.XYplane.V_4.Q_4.step_00000050.cut_21",
                        "plot_vertical_axis.XYplane.V_4.Q_4.step_00000050.cut_22"]

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

    func testInitPlotDirs() {

        let q = QVecLib<Float32>(plotDirs: testDirURLs)

        print(q.plotDirByStep)
        XCTAssertEqual(q.plotDirByStep.map { $0.key }.sorted(), [50, 1000])
        XCTAssertEqual(q.plotDirByStep[50]?.count, 8)
        XCTAssertEqual(q.plotDirByStep[1000]?.count, 3)

    }

    func testInitOutputKind() {

        let o = try! OutputDir(rootDir: testRootDir)
        var q = QVecLib<Float32>(rootDir: o, kind: [.XYplane])

        XCTAssertEqual(q.plotDirByStep.map { $0.key }.sorted(), [50, 1000])
        XCTAssertEqual(q.plotDirByStep[50]?.count, 3)
        XCTAssertEqual(q.plotDirByStep[1000]?.count, 3)

        q = QVecLib<Float32>(rootDir: o, kind: [.rotational])
        XCTAssertEqual(q.plotDirByStep.map { $0.key }.sorted(), [50])
        XCTAssertEqual(q.plotDirByStep[50]?.count, 1)

        q = QVecLib<Float32>(rootDir: o, kind: [.XZplane])
        XCTAssertEqual(q.plotDirByStep.map { $0.key }.sorted(), [50])
        XCTAssertEqual(q.plotDirByStep[50]?.count, 3)

        q = QVecLib<Float32>(rootDir: o, kind: [.YZplane])
        XCTAssertEqual(q.plotDirByStep.map { $0.key }.sorted(), [])
        XCTAssertEqual(q.plotDirByStep[50]?.count, nil)

    }

}
