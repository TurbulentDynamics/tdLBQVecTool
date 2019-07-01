//
//  mQVecPostProcess.swift
//  tdQVecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation



struct velocity {
    var rho:Float32
    var ux:Float32
    var uy:Float32
    var uz:Float32

    init(){
        rho = 0.0
        ux = 0.0
        uy = 0.0
        uz = 0.0
    }
}

enum dirType {
    case XYplane
    case XZplane
    case YZplane
    case rotational
    case volume
}



class QVecPostProcess {


    let defaultPPDimName: String = "Post_Processing_Dims_dims.0.0.0.V4.json"

    let dataDirURL: URL

    init(withDataDirURL: URL) {
        self.dataDirURL = withDataDirURL
    }




    func loadPPDim(atDir dir: String, ppDimJson: String? = nil) throws -> ppDim {
        let ppDimJson = ppDimJson ?? self.defaultPPDimName

        let jsonURL = dataDirURL.appendingPathComponent(dir).appendingPathComponent(ppDimJson)
        logger.info("Loading PPDim \(jsonURL)")
        return try ppDim(jsonURL)
    }


    func loadQVecDim(withDir dir: String, jsonFile: String) throws -> QVecDim {

        //TODO check if not json then try append .json

        let jsonURL = dataDirURL.appendingPathComponent(dir).appendingPathComponent(jsonFile)
        logger.info("Loading QVec \(jsonURL)")
        return try QVecDim(jsonURL)
    }


    func load(fromDir loadDir: String) throws {

        let ppDimDir = dataDirURL.appendingPathComponent(dir).appendingPathComponent(defaultPPDimName)
        let dim = try ppDim(ppDimDir)

        let nColg = dim.gridX + 2
        let nRowg = dim.gridX + 2



        let num_layers = 3;
        //        if (vort && plotname == "rotational_capture") num_layers = 5;
        //        else if (vort) num_layers = 3;

        let buff = loadBuffer(withDataDirURL: dataDirURL)
        let disk = InputFilesV4(withDataDir: dataDirURL)

        var u = Array(repeating: Array(repeating: Array(repeating: velocity(), count: nRowg), count: nColg), count: num_layers)


        //TODO Dispatch to GCD????
        for layer in 0..<num_layers {

            var dir = disk.getDirDeltaURL(delta: 0, fromDir: loadDir)

            if layer == 1 {
                dir = disk.getDirDeltaURL(delta: +1, fromDir: loadDir)
            } else if layer == 2 {
                dir = disk.getDirDeltaURL(delta: -1, fromDir: loadDir)
            }

            let QVec = "^QVec.node.*.bin$"
            let F3 = "^QVec.F3.node.*.bin$"


            //Dir should change for layers
            let Q4diskBuffer =  try buff.loadFiles(fromDir: dir!, regex: QVec)
            let F3diskBuffer =  try buff.loadFiles(fromDir: dir!, regex: F3)


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

        let ignoreBorderCells = 2
        for c in ignoreBorderCells..<dim.totalHeight - ignoreBorderCells {
            for r in ignoreBorderCells..<dim.totalWidth - ignoreBorderCells {


                //let uxx = 0.5 * (u[0][c + 1][r    ].ux - u[0][c - 1][r    ].ux)
                let uxy = 0.5 * (u[0][c    ][r + 1].ux - u[0][c    ][r - 1].ux)
                let uxz = 0.5 * (u[2][c    ][r    ].ux - u[1][c    ][r    ].ux)

                let uyx = 0.5 * (u[0][c + 1][r    ].uy - u[0][c - 1][r    ].uy)
                //let uyy = 0.5 * (u[0][c    ][r + 1].uy - u[0][c    ][r - 1].uy)
                let uyz = 0.5 * (u[2][c    ][r    ].uy - u[1][c    ][r    ].uy)

                let uzx = 0.5 * (u[0][c + 1][r    ].uz - u[0][c - 1][r    ].uz)
                let uzy = 0.5 * (u[0][c    ][r + 1].uz - u[0][c    ][r - 1].uz)
                //let uzz = 0.5 * (u[2][c    ][r    ].uz - u[1][c    ][r    ].uz)


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


        let url = dataDirURL.appendingPathComponent(dir).appendingPathComponent("file.vort.bin")
        let wData = Data(bytes: &writeBuffer, count: writeBuffer.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)


    }



}


