////
////  File.swift
////  tdQvecPostProcess
////
////  Created by Nile Ó Broin on 08/07/2019.
////  Copyright © 2019 Turbulent Dynamics. All rights reserved.
////
//
//
//let plotname: String = get_plot_type_from_directory(&load_dir)
//
//
//var dir: [String] = ["", "", "", "", ""]
//var root: [String] =  ["", "", "", "", ""], root_F: [String] = ["", "", "", "", ""]
//
//
//if (plotname == "rotational_capture") {
//    dir[0] = load_dir; root[0] = "Qvec"; root_F[0] = "Qvec.F3";
//
//    dir[1] = load_dir; root[1] = "Qvec.im1"; root_F[1] = "Qvec.F3.im1";
//    dir[2] = load_dir; root[2] = "Qvec.ip1"; root_F[2] = "Qvec.F3.ip1";
//
//    dir[3] = load_dir; root[3] = "Qvec.km1"; root_F[3] = "Qvec.F3.km1";
//    dir[4] = load_dir; root[4] = "Qvec.kp1"; root_F[4] = "Qvec.F3.kp1";
//
//} else {
//
//    dir[0] = load_dir;                    root[0] = "Qvec"; root_F[0] = "Qvec.F3";
//    dir[1] = get_dir_delta(-1, &load_dir); root[1] = "Qvec"; root_F[1] = "Qvec.F3";
//    dir[2] = get_dir_delta(+1, &load_dir); root[2] = "Qvec"; root_F[2] = "Qvec.F3";
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//@inline(__always) func cmpf( _ A: Float, _ B: Float, _ epsilon: Float = 0.05) -> Bool
//{
//    return (abs(A - B) < epsilon);
//}
//
//@inline(__always) func grid_ijk_on_node( _ gi: tNi, _ gj: tNi, _ gk: tNi, _ f: Node_Bounds) -> Bool {
//
//    if (gi >= f.i0 && gi <= f.i1 && gj >= f.j0 && gj <= f.j1 && gk >= f.k0 && gk <= f.k1) {
//        return true;
//    }
//
//    return false;
//
//}
//
//@inline(__always) func get_node_bounds( _ node: Node_Dims, _ grid: Grid_Dims) -> Node_Bounds{
//
//    var ret: Node_Bounds = Node_Bounds();
//
//    ret.i0 = (node.x * tNi(node.idi))
//    if (node.idi>0) {
//        ret.i0 += 1;
//    }
//
//    ret.i1 = (node.x * (tNi(node.idi) + node.x))
//    if (node.idi == grid.ngx-1) {
//        ret.i1 += 1;
//    }
//
//    ret.j0 = (node.y * tNi(node.idj))
//    if (node.idj>0) {
//        ret.j0 += 1;
//    }
//
//    ret.j1 = (node.y * (tNi(node.idj) + node.y))
//    if (node.idj == grid.ngy-1) {
//        ret.j1 += 1;
//    }
//
//    ret.k0 = (node.z * tNi(node.idk))
//    if (node.idk > 0) {
//        ret.k0 += 1;
//    }
//
//    ret.k1 = (node.z * (tNi(node.idk) + node.z))
//    if (node.idk == grid.ngz - 1) {
//        ret.k1 += 1;
//    }
//
//    return ret;
//}
