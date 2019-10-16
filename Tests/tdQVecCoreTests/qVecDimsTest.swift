//
//  File.swift
//  
//
//  Created by Nile Ó Broin on 15/10/2019.
//

import XCTest





//func testJsonLoad() {
//    let jsonString = """
//{
//"Q_data_type" : "float",
//"Q_output_length" : 4,
//"bin_file_size_in_structs" : 54,
//"coords_type" : "uint16_t",
//"grid_x" : 44,
//"grid_y" : 44,
//"grid_z" : 44,
//"has_col_row_coords" : true,
//"has_grid_coords" : false,
//"idi" : 1,
//"idj" : 1,
//"idk" : 1,
//"name" : "QVec_Dims",
//"ngx" : 2,
//"ngy" : 2,
//"ngz" : 2,
//"struct_name" : "tDisk_colrow_Q3_V4"
//}
//"""
//    let dim = try QVecDim(fromJSON: jsonString)
//    print(dim)
//
//
//    //let f = FileManager.changeCurrentDirectoryPath(<#T##self: FileManager##FileManager#>)
//    let home = FileManager.default.homeDirectoryForCurrentUser
//
//    let dataPath = "Workspace/xcode/tdQVecTool/TinyTestData/"
//    let dataUrl = home.appendingPathComponent(dataPath)
//
//    let jsonFile = "/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/QVec.F3.node.1.1.1.V4.bin.json"
//    let jsonUrl = dataUrl.appendingPathComponent(jsonFile)
//
//    let dim2 = try QVecDim(fromURL: jsonUrl)
//    print(dim2)
//
//}
