//
//  Task.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import FirebaseFirestoreSwift
import CoreMedia

class Task: NSObject, Codable {
    
    @DocumentID var id: String?
    var taskTitle: String?
    var taskDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskTitle
        case taskDescription
    }
    
    
    
    
}
