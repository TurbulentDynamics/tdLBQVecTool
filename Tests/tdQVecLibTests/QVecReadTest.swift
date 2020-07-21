import XCTest
@testable import tdQVecLib

final class tdQVecToolTests: XCTestCase {

    var fileURL: URL!

    override func setUp() {
        super.setUp()

        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
        fileURL = directory.appendingPathComponent("testLBwrite.bin")

    }

    func testQinit() {

        let t = Q<Float32>(q: [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(t.q[1], 1)
        XCTAssert((t.q[1] as Any) is Float32)

        let u = Q<Float32>(qLen: 27)
        XCTAssertEqual(u.q[1], 0)
        XCTAssert((u.q[1] as Any) is Float32)
        XCTAssertEqual(u.q.count, 27)

    }

    func testLBsetup() {

        let lb0 = LB<Float32>(qLen: 2)
        XCTAssertEqual(lb0.grid[0][0][0].q[0], 0)
        XCTAssertEqual(lb0.grid[0][0][0].q.count, 2)
        XCTAssert((lb0.grid[0][0][0].q[1] as Any) is Float32)

        let lb1 = LB<Double>(qLen: 27)
        XCTAssertEqual(lb1.grid[0][0][0].q[1], 1)
        XCTAssertEqual(lb1.grid[0][0][0].q.count, 27)
        XCTAssert((lb1.grid[0][0][0].q[1] as Any) is Double)
    }

    func testGetSparseFromDisk() {

        let lb = LB<Float32>(qLen: 27)
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

        let lb = LB<LBType>(qLen: 27)

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

        let lb = LB<Float32>(qLen: 4)

        lb.writeSparse2DPlaneXY(to: fileURL, at: 2, qOutputLength: 4, tCoordType: UInt16.self, QVecType: Float32.self)

        let qv = try! QVecRead<Float32>(binURL: fileURL)

        var plane = Velocity2DPlaneOrtho<Float32>(cols: qv.dim.gridX, rows: qv.dim.gridY)

        qv.getVelocityFromDisk(addIntoPlane: &plane)

    }

    func testAddForcingToPartialVelocity() {

        let lb = LB<Float32>(qLen: 4)

        lb.writeSparse2DPlaneXY(to: fileURL, at: 2, qOutputLength: 4, tCoordType: UInt16.self, QVecType: Float32.self)

        let qv = try! QVecRead<Float32>(binURL: fileURL)

        var plane = Velocity2DPlaneOrtho<Float32>(cols: qv.dim.gridX, rows: qv.dim.gridY)

        qv.getVelocityFromDisk(addIntoPlane: &plane)

    }

    func testLoadCData() {

        //Copy tests to temp directory
        let TinyTestDataFromC = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("TinyTestDataFromC")

        let urlLOAD = TinyTestDataFromC.appendingPathComponent("plot_slice.XZplane.V_4.Q_4.step_00000050.cut_29/Qvec.node.0.1.1.V4.bin")

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
