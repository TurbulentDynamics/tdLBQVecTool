//
//  mqVecPostProcess.swift
//  tdQvecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation


struct velocity {
    var rho:Float32
    var ux:Float32
    var uy:Float32
    var uz:Float32
    //    var vort: Float32

    init(){
        rho = 0.0
        ux = 0.0
        uy = 0.0
        uz = 0.0
        //        vort = 0.0
    }
}





class qVecPostProcess {


    let rootDataDir: URL

    init(withDataDir: URL) {
        self.rootDataDir = withDataDir
    }




    func loadPPDim(atDir dir: String, ppDimJson: String = "Post_Processing_Dims_dims.0.0.0.V4.json") throws -> ppDim {

        let jsonURL = rootDataDir.appendingPathComponent(dir).appendingPathComponent(ppDimJson)
        //        print("Loading PPDim \(jsonURL)")
        return try ppDim(jsonURL)
    }


    func loadQvecDim(withDir dir: String, jsonFile: String) throws -> qVecDim {

        //TODO check if not json then try append .json

        let jsonURL = rootDataDir.appendingPathComponent(dir).appendingPathComponent(jsonFile)
        //        print("Loading Qvec \(jsonURL)")
        return try qVecDim(jsonURL)
    }



    func load(fromDir dir: String) throws {

        let ppDimDir = rootDataDir.appendingPathComponent(dir).appendingPathComponent("Post_Processing_Dims_dims.0.0.0.V4.json")
        let dim = try ppDim(ppDimDir)

        let nColg = dim.gridX + 2
        let nRowg = dim.gridX + 2

        let num_layers = 3;
        //        if (vort && plotname == "rotational_capture") num_layers = 5;
        //        else if (vort) num_layers = 3;

        let Qvec = "^Qvec.node.*.bin$"
        let F3 = "^Qvec.F3.node.*.bin$"

        let buff = Buffer(withDataDir: dataDirURL)


        var u = Array(repeating: Array(repeating: Array(repeating: velocity(), count: nRowg), count: nColg), count: num_layers)


        //Dispatch to GCD????
        for layer in 0..<num_layers {



            //Dir should change for layers
            let Q4diskBuffer =  try buff.load(fromDir: dir, regex: Qvec)
            let F3diskBuffer =  try buff.load(fromDir: dir, regex: F3)


            for col in 0..<dim.totalWidth {
                for row in 0..<dim.totalHeight {

                    let rho = Q4diskBuffer[col][row][0]
                    u[layer][col][row].rho = rho
                    u[layer][col][row].ux = (Q4diskBuffer[col][row][1] + 0.5 * F3diskBuffer[col][row][0]) / rho
                    u[layer][col][row].uy = (Q4diskBuffer[col][row][2] + 0.5 * F3diskBuffer[col][row][1]) / rho
                    u[layer][col][row].uz = (Q4diskBuffer[col][row][3] + 0.5 * F3diskBuffer[col][row][2]) / rho

                }
            }
        }

        //----------- After all layers set up

        var vort = Array(repeating: Array(repeating: Float32(), count: nRowg), count: nColg)


        for c in 1..<dim.totalHeight - 1 {
            for r in 1..<dim.totalWidth - 1 {


                //                let uxx = 0.5 * (u[0][c + 1][r    ].ux - u[0][c - 1][r    ].ux)
                let uxy = 0.5 * (u[0][c    ][r + 1].ux - u[0][c    ][r - 1].ux)
                let uxz = 0.5 * (u[2][c    ][r    ].ux - u[1][c    ][r    ].ux)

                let uyx = 0.5 * (u[0][c + 1][r    ].uy - u[0][c - 1][r    ].uy)
                //                let uyy = 0.5 * (u[0][c    ][r + 1].uy - u[0][c    ][r - 1].uy)
                let uyz = 0.5 * (u[2][c    ][r    ].uy - u[1][c    ][r    ].uy)

                let uzx = 0.5 * (u[0][c + 1][r    ].uz - u[0][c - 1][r    ].uz)
                let uzy = 0.5 * (u[0][c    ][r + 1].uz - u[0][c    ][r - 1].uz)
                //                let uzz = 0.5 * (u[2][c    ][r    ].uz - u[1][c    ][r    ].uz)


                let uyz_uzy = uyz - uzy
                let uzx_uxz = uzx - uxz
                let uxy_uyx = uxy - uyx


                vort[c][r] = log(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)
            }
        }




        //------------Write file with border
        let border = 2

        var writeBuffer = Array(repeating: Float32(), count: ((dim.totalWidth - border) * (dim.totalHeight - border)))

        for c in border..<dim.totalHeight - border {
            for r in border..<dim.totalWidth - border {

                writeBuffer[ c * (dim.totalHeight - border) + r ] = vort[c][r]
            }
        }


        let url = rootDataDir.appendingPathComponent(dir).appendingPathComponent("file.vort.bin")
        let wData = Data(bytes: &writeBuffer, count: writeBuffer.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)





    }



}


