//
//  ViewController.swift
//  CodableDemo
//
//  Created by MacMini on 10/11/17.
//  Copyright © 2017 Thành Lã. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let csv = """
name,age,isMan
ほげ,25,true
ふが,100,false
"""
        let decoder = parseJSON(from: csv)
        dump(decoder)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Test
    func parseJSON(from csv: String) -> [Row] {
        let decoder = CSVDecoder()
        
        do {
            return try decoder.decode(Row.self, from: csv)
        } catch {
            print("error: \(error)")
        }
        
        return []
    }

}

