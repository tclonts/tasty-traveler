//
//  State.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/18/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct StateData: Decodable {
    var state: [State]
}

struct State: Decodable {
    var short: String?
    var name: String
    var country: String
}

func loadJson(filename fileName: String) -> [State]? {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(StateData.self, from: data)
            return jsonData.state
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}
