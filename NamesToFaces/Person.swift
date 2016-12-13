//
//  Person.swift
//  NamesToFaces
//
//  Created by Noah Patterson on 12/13/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String

    init(name: String, image: String) {
        self.name  = name
        self.image = image
    }
}
