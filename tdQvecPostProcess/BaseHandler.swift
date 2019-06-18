////
////  BaseHandler
////  TDQvecLib
////
////  Created by Niall Ó Broin on 08/01/2019.
////  Copyright © 2019 Niall Ó Broin. All rights reserved.
////
//import Foundation
//
//
//
//
//class BaseHandler<T: Codable & DefaultValuable> {
//
//    var dim: T;
//
//
//    init()
//    {
//        dim = T.defaultValue()
//    }
//
//    init(dim: T)
//    {
//        self.dim = dim;
//    }
//
//    func set_dim(dim: T) {
//        self.dim = dim
//    }
//
//    func get_dim() -> T {
//        return dim
//    }
//
//
//    func get_name() -> String {
//        return String(describing: T.self)
//    }
//
//
//    func get_base_filepath(dir: String, idi: t3d, idj: t3d, idk: t3d) -> String {
//        return "\(dir)/\(get_name())_dims.\(idi).\(idj).\(idk)"
//    }
//
//
//    func get_filepath(dir: String, idi: t3d, idj: t3d, idk: t3d) -> String {
//        return get_base_filepath(dir:dir, idi:idi, idj:idj, idk:idk) + ".V4.json";
//    }
//
//
//    func get_bin_filepath_v3(dir: String, idi: t3d, idj: t3d, idk: t3d) -> String {
//        return get_base_filepath(dir:dir, idi:idi, idj:idj, idk:idk) + ".V3.bin";
//    }
//
//
//
//
//    func path_exists(_ filepath: String) -> Bool {
//        let fileManager = FileManager.default
//        return fileManager.fileExists(atPath: filepath)
//    }
//
//
//    func file_exists(_ filepath: String) -> Bool {
//        return path_exists(filepath);
//    }
//
//
//
//
//
//
//    //Loading
//    func get_dim(dir: String, idi: t3d, idj: t3d, idk: t3d) -> T? {
//
//        let filepath: String = get_filepath(dir:dir, idi:idi, idj:idj, idk:idk)
//        if (file_exists(filepath)) {
//            return load_json(filepath: filepath)
//        }
//
//        //Try V3
//        //        filepath = get_bin_filepath_v3(idi, idj, idk, dir);
//        //        if (file_exists(filepath)) {
//        //            return get_from_bin_filepath(filepath);
//        //        }
//
//        printError("File does not exist for " + filepath)
//        return nil
//    }
//
//
//    func get_dim(filepath: String) -> T? {
//        return load_json(filepath: filepath)
//    }
//
//
//
//    func get_dim_from_node000(dir: String) -> T? {
//        return get_dim(dir:dir, idi:0, idj:0, idk:0)
//    }
//
//
//
//
//    //    func set_dim<T: Decodable>(dir: String, idi: t3d, idj: t3d, idk: t3d) {
//    //        if let d = get_dim(dir:dir, idi:idi, idj:idj, idk:idk){
//    //            dim = d
//    //        }
//    //    }
//    //
//    //    func set_dim_from_node000(dir: String) {
//    //        set_dim(dir:dir, idi:0, idj:0, idk:0)
//    //    }
//
//
//
//    func load_json(filepath: String) -> T? {
//
//        let fileURL = URL(fileURLWithPath: filepath)
//
//        if let jsonFile:String = try? String(contentsOf: fileURL) {
//
//
//            if let json = jsonFile.data(using: .utf8) {
//
//                do {
//
//                    dim = try JSONDecoder().decode(T.self, from: json)
//
//                    return dim
//
//                }
//                catch
//                {
//                    printError(error.localizedDescription)
//                    print(error)
//                }
//
//            } else {
//                printError("Cannot convert to json text to json Data")
//            }
//
//        } else {
//            printError("Cannot read json file at " + filepath)
//
//        }
//        return nil
//    }
//
//
//
//
//
//
//
//
//
//    //Save
//    func save_dim(dir: String, idi: t3d, idj: t3d, idk: t3d) {
//
//        let filepath: String = get_filepath(dir:dir, idi:idi, idj:idj, idk:idk)
//
//        save_json(filepath: filepath)
//    }
//
//
//    func save_dim_as_node000(dir: String) {
//        return save_dim(dir:dir, idi:0, idj:0, idk:0)
//    }
//
//
//    func save_dim(filepath: String) {
//
//        save_json(filepath: filepath)
//    }
//
//
//
//    func save_json(filepath: String) {
//
//        let fileURL = URL(fileURLWithPath: filepath)
//        do {
//            let data = try JSONEncoder().encode(dim)
//            try data.write(to: fileURL, options: .atomic)
//        } catch {
//            printError("Cannot save to file at " + filepath)
//        }
//    }
//
//
//
//
//
//
//
//
//    func print_dim(){
//
//        let mirror = Mirror(reflecting: dim)
//
//        for child in mirror.children  {
//            print("key: \(child.label ?? ""), value: \(child.value)")
//        }
//    }
//
//
//
//
//}
