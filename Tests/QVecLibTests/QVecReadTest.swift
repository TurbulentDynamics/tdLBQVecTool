import XCTest
@testable import QVecLib
@testable import tdLB
@testable import tdLBOutput

final class tdQVecToolTests: XCTestCase {

    var fileURL: URL!
    var outputTree = try! DiskOutputTree(diskDir: ".", rootDir: "tdLBQVecToolTestOutputDir")

    override func setUp() {
        super.setUp()
        
    }

    func testQinit() {

        let t = QVec<Float32>(with: [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(t.q[1], 1)
        XCTAssert((t.q[1] as Any) is Float32)

        let u = QVec<Float32>(qLen: .q27)
        XCTAssertEqual(u.q[1], 0)
        XCTAssert((u.q[1] as Any) is Float32)
        XCTAssertEqual(u.q.count, 27)

    }

    func testLBsetup() {

        
        var lb0 = ComputeUnit<Float32>(outputTree: outputTree, with: 0.0, x: 3, y: 3, z: 3, qLen: .q27)
        lb0.setPositionalDataForTesting()

        XCTAssertEqual(lb0.Q[0][0][0].q[0], 0.0)
        XCTAssertEqual(lb0.Q[0][0][0].q.count, 27)
        XCTAssert((lb0.Q[0][0][0].q[1] as Any) is Float32)

        var lb1 = ComputeUnit<Double>(outputTree: outputTree, with: 0.0, x: 3, y: 3, z: 3, qLen: .q19)
        lb1.setPositionalDataForTesting()

        XCTAssertEqual(lb1.Q[0][0][0].q[1], 0.1)
        XCTAssertEqual(lb1.Q[0][0][0].q.count, 19)
        XCTAssert((lb1.Q[0][0][0].q[1] as Any) is Double)
    }

    func testGetSparseFromDisk() {

        var lb = ComputeUnit<Float32>(outputTree: outputTree, with: 0.0, x: 3, y: 3, z: 3, qLen: .q19)
        lb.setPositionalDataForTesting()

        lb.writeSparse2DPlaneXY(to: fileURL, at: 2, qOutputLength: 19, tCoordType: UInt16.self, QVecType: Float32.self)

        let qv = try! QVecRead<Float32>(binURL: fileURL)

        let sparse = qv.readSparseFromDisk()

        print("TheSparse", sparse)

    }

    func testLoadAndSave<
        LBType: BinaryFloatingPoint,
        SaveCoordType: BinaryInteger,
        SaveQType: BinaryFloatingPoint,
        QVecLibType: BinaryFloatingPoint>(
        LBType: LBType.Type,
        SaveCoordType: SaveCoordType.Type,
        SaveQType: SaveQType.Type,
        QVecLibType: QVecLibType.Type
    ) {

        let lb = ComputeUnit<LBType>(outputTree: outputTree, with: 0.0, x: 3, y: 3, z: 3, qLen: .q27)

        lb.writeSparse2DPlaneXY(to: fileURL, at: 2, qOutputLength: 4, tCoordType: SaveCoordType.self, QVecType: SaveQType.self)

        let qv = try! QVecRead<QVecLibType>(binURL: fileURL)

        var plane = Array(repeating: Array(repeating: Array<QVecLibType>(repeating: 0, count: qv.dim.qOutputLength), count: qv.dim.gridY), count: qv.dim.gridX)

        qv.getPlaneFromDisk(plane: &plane)
    }

    func testGetPlaneFromDisk() {

        //TODO read QLen, (might have written 27). precondition QLen Read < QLenWrite
        testLoadAndSave(LBType: Double.self, SaveCoordType: Int16.self, SaveQType: Float32.self, QVecLibType: Float32.self)
        testLoadAndSave(LBType: Double.self, SaveCoordType: UInt16.self, SaveQType: Float32.self, QVecLibType: Float32.self)

        testLoadAndSave(LBType: Double.self, SaveCoordType: Int16.self, SaveQType: Float32.self, QVecLibType: Double.self)
        testLoadAndSave(LBType: Double.self, SaveCoordType: UInt16.self, SaveQType: Double.self, QVecLibType: Double.self)

        testLoadAndSave(LBType: Double.self, SaveCoordType: Int32.self, SaveQType: Float32.self, QVecLibType: Double.self)
        testLoadAndSave(LBType: Double.self, SaveCoordType: UInt32.self, SaveQType: Double.self, QVecLibType: Double.self)

    }

    func testGetVelocityFromDisk() {

        let lb = ComputeUnit<Float32>(outputTree: outputTree, with: 0.0, x: 3, y: 3, z: 3, qLen: .q7)

        lb.writeSparse2DPlaneXY(to: fileURL, at: 2, qOutputLength: 4, tCoordType: UInt16.self, QVecType: Float32.self)

        let qv = try! QVecRead<Float32>(binURL: fileURL)

        var plane = Velocity2DPlaneOrtho<Float32>(cols: qv.dim.gridX, rows: qv.dim.gridY)

        qv.getVelocityFromDisk(addIntoPlane: &plane)

    }

    func testAddForcingToPartialVelocity() {

        let lb = ComputeUnit<Float32>(outputTree: outputTree, with: 0.0, x: 3, y: 3, z: 3, qLen: .q7)

        lb.writeSparse2DPlaneXY(to: fileURL, at: 2, qOutputLength: 4, tCoordType: UInt16.self, QVecType: Float32.self)

        let qv = try! QVecRead<Float32>(binURL: fileURL)

        var plane = Velocity2DPlaneOrtho<Float32>(cols: qv.dim.gridX, rows: qv.dim.gridY)

        qv.getVelocityFromDisk(addIntoPlane: &plane)

    }

    func testLoadCData() {

        //Copy tests to temp directory
        let TinyTestDataFromC = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("TinyTestDataFromC")

        let urlLOAD = TinyTestDataFromC.appendingPathComponent("plot_slice.XZplane.V5.step_00000050.cut_29/Qvec.node.0.1.1.V4.bin")

        let qv = try! QVecRead<Float32>(binURL: urlLOAD)

        //All the C++ Test data was written as C floats
        if qv.dim.qDataType == "float" {
            var plane = Array(repeating: Array(repeating: [Float32](repeating: 0, count: qv.dim.qOutputLength), count: qv.dim.gridX), count: qv.dim.gridZ)
            qv.getPlaneFromDisk(plane: &plane)
        } else {
            XCTFail()
        }

    }

    func testtDisks() {

        let t = DiskSparse3D<Int8, Float32>(i: 1, j: 2, k: 5, q: [0, 1, 2, 3, 4, 5])

        XCTAssertEqual(t.i, 1)
        XCTAssert((t.j as Any) is Int8)

        XCTAssertEqual(t.q[1], 1)
        XCTAssert((t.q[1] as Any) is Float32)

    }

    static var allTests = [
        ("testQinit", testQinit),
        ("testLBsetup", testLBsetup),
        //        ("testGetSparseFromDisk", testGetSparseFromDisk),
        ("testGetPlaneFromDisk", testGetPlaneFromDisk)
        //        ("testLoadCData", testLoadCData),
        //        ("testtDisks", testtDisks),
    ]
}
