//
//  QvecDims.swift
//  TDQvecLib
//
//  Created by Nile Ó Broin on 08/01/2019.
//  Copyright © 2019 Nile Ó Broin. All rights reserved.
//

extension Qvec_Dims : DefaultValuable {
    static func defaultValue() -> Qvec_Dims {
        return Qvec_Dims()
    }
}

struct Qvec_Dims: Codable {


    var grid_x: tNi = 0
    var grid_y: tNi = 0
    var grid_z: tNi = 0


    var ngx = 0
    var ngy = 0
    var ngz = 0

    var idi = 0
    var idj = 0
    var idk = 0


    var struct_name: String = ""
    var bin_file_size_in_structs: UInt64 = 0



    var coords_type: String = ""
    var has_grid_coords: Bool = false
    var has_col_row_coords: Bool = false



    var Q_data_type: String = ""
    var Q_output_length: Int = 0

    init() {

    }
};



class HandleQvecDims: BaseHandler<Qvec_Dims>{



    func set_dims(ngx: t3d, ngy: t3d, ngz: t3d, snx: tNi, sny: tNi, snz: tNi){

        dim.ngx = ngx
        dim.ngy = ngy
        dim.ngz = ngz

        dim.grid_x = snx
        dim.grid_y = sny
        dim.grid_z = snz
    }

    func set_ids( _ idi: t3d, _ idj: t3d, _ idk: t3d){

        dim.idi = idi
        dim.idj = idj
        dim.idk = idk

    }

    func set_file_content(struct_name: String, bin_file_size_in_structs: UInt64,
                          coords_type: String, has_grid_coords: Bool, has_col_row_coords: Bool,
                          Q_data_type: String, Q_output_length: Int)
    {

        dim.struct_name = struct_name
        dim.bin_file_size_in_structs = bin_file_size_in_structs

        dim.coords_type = coords_type
        dim.has_grid_coords = has_grid_coords
        dim.has_col_row_coords = has_col_row_coords

        dim.Q_data_type = Q_data_type
        dim.Q_output_length = Q_output_length


    }












    func get_json_filepath_from_Qvec_bin_filepath(filepath: String) -> String {
        return filepath + ".json"
    }

    func Qvec_json_file_exists(filepath: String) -> Bool {
        let json_filepath: String = get_json_filepath_from_Qvec_bin_filepath(filepath: filepath)
        return file_exists(json_filepath)
    }






    func get_from_Qvec_filepath(filepath: String) -> Qvec_Dims? {

        let json_filepath: String = get_json_filepath_from_Qvec_bin_filepath(filepath: filepath)

        return get_dim(filepath: json_filepath)
    }







}
