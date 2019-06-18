//
//  main.swift
//  TDQvecLib
//
//  Created by Nile Ó Broin on 24/01/2019.
//  Copyright © 2019 Nile Ó Broin. All rights reserved.
//

import Foundation


extension Post_Processing_Dims : DefaultValuable {
    static func defaultValue() -> Post_Processing_Dims {
        return Post_Processing_Dims()
    }
}



struct Post_Processing_Dims: Codable {

    var name: String = ""

    var function: String = ""
    var dirname: String = "."
    var cut_at: tNi = 0
    var Q_output_length: Int = 0
    var note: String = ""

    var ngx: t3d = 0
    var ngy: t3d = 0
    var ngz: t3d = 0
    var grid_x: tNi = 0
    var grid_y: tNi = 0
    var grid_z: tNi = 0

    var file_height: tNi = 0
    var file_width: tNi = 0
    var total_height: tNi = 0
    var total_width: tNi = 0

    var step: tStep = 0
    var teta: tGeomShape = 0.0
    var initial_rho: tQvec = 0.0
    var re_m_nondimensional: tQvec = 0.0
    var uav: tQvec = 0.0

    init(){

    }
}




class HandlePPDims: BaseHandler<Post_Processing_Dims>{

    override init()
    {
        super.init()
    }

    override init( _dim: Post_Processing_Dims)
    {
        super.init(_dim: _dim)
        dim = _dim;
    }


    func set_dims(ngx: t3d, ngy: t3d, ngz: t3d, x: tNi, y: tNi, z: tNi){

        dim.ngx = ngx
        dim.ngy = ngy
        dim.ngz = ngz

        dim.grid_x = x
        dim.grid_y = y
        dim.grid_z = z
    }


    func set_height_width(file_height: tNi,  file_width: tNi, total_height: tNi, total_width: tNi){

        dim.file_height = file_height
        dim.file_width = file_width

        dim.total_height = total_height
        dim.total_width = total_width
    }


    func set_running(step: tStep,  teta: tGeomShape){
        dim.teta = teta
        dim.step = step
    }


    func set_flow(initial_rho: tQvec, re_m_nondimensional: tQvec,  uav: tGeomShape){
        dim.initial_rho = initial_rho
        dim.re_m_nondimensional = re_m_nondimensional
        dim.uav = uav
    }


    func set_note(note: String){
        dim.note = note
    }



    func set_plot(function: String, dirname: String, Q_output_length: Int = 4, cut_at: tNi = 0){
        dim.function = function
        dim.dirname = dirname
        dim.cut_at = cut_at
        dim.Q_output_length = Q_output_length
    }







}
