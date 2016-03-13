//
//  DataServices.swift
//  CommunitySpirit
//
//  Created by Robert McBryde on 13/03/2016.
//  Copyright © 2016 Robert McBryde. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    private(set) var refBase = Firebase(url: "https://rob-showcase.firebaseio.com")
    
}