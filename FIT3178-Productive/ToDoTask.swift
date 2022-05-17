//
//  ToDoTask.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 25/4/2022.
//

import UIKit
import FirebaseFirestoreSwift
import CoreMedia

class ToDoTask: NSObject, Codable {
    
    @DocumentID var id: String?
    var taskTitle: String?
    var taskDescription: String?
    var longitude: Double?
    var latitude: Double?
    var seconds: Int?
    var minutes: Int?
    var hours: Int?
    
    enum CodingKeys : String, CodingKey {
        case id
        case taskTitle
        case taskDescription
        case longitude
        case latitude
        case seconds
        case minutes
        case hours
    }

}
