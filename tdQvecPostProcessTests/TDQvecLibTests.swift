import XCTest
@testable import TDQvecLib

final class TDQvecLibTests: XCTestCase {

    func testLoadPostProcessingDims() {
        if let object = HandlePPDims().load_json(filepath: "TestData/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/Post_Processing_Dims_dims.0.0.0.V4.json") {
            XCTAssertEqual(object.name, "Post_Processing_Dims")

            XCTAssertEqual(object.function, "plot_XZ_Qvec_buffer")
            XCTAssertEqual(object.dirname, "plot_output_np8_gridx44//plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28")
            XCTAssertEqual(object.Q_output_length, 4)
            XCTAssertEqual(object.note, "")

            XCTAssertEqual(object.ngx, 2)
            XCTAssertEqual(object.ngy, 2)
            XCTAssertEqual(object.ngz, 2)

            XCTAssertEqual(object.grid_x, 44)
            XCTAssertEqual(object.grid_y, 44)
            XCTAssertEqual(object.grid_z, 44)

            XCTAssertEqual(object.file_height, 22)
            XCTAssertEqual(object.file_width, 22)
            XCTAssertEqual(object.total_height, 44)
            XCTAssertEqual(object.total_width, 44)

            XCTAssertEqual(object.step, 50)
            XCTAssertEqual(object.teta, 0.71428615)
            XCTAssertEqual(object.initial_rho, 8.0)
            XCTAssertEqual(object.re_m_nondimensional, 7300.0)
        } else {
            XCTFail()
        }
    }

    func testLoadDims() {
        if let object = HandleQvecDims().load_json(filepath: "TestData/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/Qvec.F3.node.0.1.0.V4.bin.json") {
            XCTAssertEqual(object.grid_x, 44)
            XCTAssertEqual(object.grid_y, 44)
            XCTAssertEqual(object.grid_z, 44)

            XCTAssertEqual(object.ngx, 2)
            XCTAssertEqual(object.ngy, 2)
            XCTAssertEqual(object.ngz, 2)

            XCTAssertEqual(object.idi, 0)
            XCTAssertEqual(object.idj, 1)
            XCTAssertEqual(object.idk, 0)

            XCTAssertEqual(object.struct_name, "tDisk_colrow_Q3_V4")
            XCTAssertEqual(object.bin_file_size_in_structs, 24)

            XCTAssertEqual(object.coords_type, "uint16_t")
            XCTAssertEqual(object.has_grid_coords, false)
            XCTAssertEqual(object.has_col_row_coords, true)

            XCTAssertEqual(object.Q_data_type, "float")
            XCTAssertEqual(object.Q_output_length, 4)
        } else {
            XCTFail()
        }
    }

    static var allTests = [
        ("testLoadPostProcessingDims", testLoadPostProcessingDims),
        ("testLoadDims", testLoadDims)
    ]
}
