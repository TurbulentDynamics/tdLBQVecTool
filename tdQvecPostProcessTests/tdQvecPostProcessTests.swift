import XCTest
import class Foundation.Bundle

final class TDQVecPostProcessTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("TDQVecPostProcess")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, "Hello, world!\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}



let jsonString = """
{
"Q_data_type" : "float",
"Q_output_length" : 4,
"bin_file_size_in_structs" : 54,
"coords_type" : "uint16_t",
"grid_x" : 44,
"grid_y" : 44,
"grid_z" : 44,
"has_col_row_coords" : true,
"has_grid_coords" : false,
"idi" : 1,
"idj" : 1,
"idk" : 1,
"name" : "QVec_Dims",
"ngx" : 2,
"ngy" : 2,
"ngz" : 2,
"struct_name" : "tDisk_colrow_Q3_V4"
}
"""
let dim = try QVecDim(fromJSON: jsonString)
print(dim)



//let f = FileManager.changeCurrentDirectoryPath(<#T##self: FileManager##FileManager#>)

let home = FileManager.default.homeDirectoryForCurrentUser

let dataPath = "Workspace/xcode/tdQVecPostProcess/TinyTestData/"
let dataUrl = home.appendingPathComponent(dataPath)

let jsonFile = "/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/QVec.F3.node.1.1.1.V4.bin.json"
let jsonUrl = dataUrl.appendingPathComponent(jsonFile)

let dim2 = try QVecDim(fromURL: jsonUrl)
print(dim2)

