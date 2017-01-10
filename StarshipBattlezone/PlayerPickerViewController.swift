//
//  PlayerPickerViewController.swift
//  StarshipBattlezone
//
//  Created by Mason Black on 2015-03-10.
//  Copyright (c) 2015 Mason Black. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

// Create the global 'Game' variables we'll be using throughout the game (in different classes).
struct Game {
    // These are the Starship variables which are instances of the Starship class and
    //      contain all of the properties (including sprites).
    static var 🚀1 = Starship(playerNum: 1) 
    static var 🚀2 = Starship(playerNum: 2)
    
    // Array of student names.
    static var students = ["Mr Black", "Brynne Allan", "Matthew Bennett", "Jacob Bland", "Kaylee Bogora", "Eric Duberville", "Daniel Gordon", "David Hogan", "Oksana Johnston", "Jason Little", "Jordan Maloney", "Greg Mitchell", "Owen Nichols", "Ben Seward", "Joey Tripp", "Dexter van Zyll de Jong", "Sherry Wang", "Spencer Wright", "Justin Yanosik"]
    
    // These are the categories that are used to detect collision/contact. (We are using an enumeration instead)
//    static let starship1Category : UInt32 = 0x00
//    static let missile1Category : UInt32 = 0x01
//    static let starship2Category : UInt32 = 0x02
//    static let missile2Category : UInt32 = 0x04
//    static let worldCategory : UInt32 = 0x08
}

// An enumeration for the collision/contact detections for the different types of categories.
enum ColliderType: UInt32 {
    case starship1 = 1
    case missile1 = 2
    case starship2 = 4
    case missile2 = 8
    case space = 16
}

class PlayerPickerViewController: UIViewController, UIPickerViewDelegate {

    
    // Connect the UIPickerView from the Storyboard - make the IBOutlet connection
    // Make sure to also connect the UIPickerView with the ViewController in the 
    //      Storyboard as both a Delegate and Datasource.
    @IBOutlet weak var Player1PickerView: UIPickerView!
    @IBOutlet weak var Player2PickerView: UIPickerView!
    
    // Declare students in an array to use as Player1 and Player2
    var imageNames: [String] = []
   
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map all of the names from the 'students' array into an 'imageNames' array
        imageNames = Game.students.map {("Starship-\($0)")}
        
        // Start assigning properties of the Starships
        Game.🚀1.name = Game.students[0]
        Game.🚀1.imageName = imageNames[0]
        Game.🚀2.name = Game.students[0]
        Game.🚀2.imageName = imageNames[0]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // returns the number of 'columns' to display in the PickerView.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each PickerView.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Game.students.count
    }
    
    // assign the names of the students into the PickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Game.students[row]
    }
    
    // This function is called when a row is picked from the PickerView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // var studentSelected = Game.students[row]
        
        // Map the image names to the textures array. Each of these is an individual file stored in the playground package
        //let textures: [SKTexture] = Game.students.map { SKTexture(imageNamed: "Starship-\($0)") }

        // If the first PickerView was selected, assign that student's name/image to the Player1 Starship
        if Player1PickerView == pickerView
        {
            Game.🚀1.name = Game.students[row]
            Game.🚀1.imageName = imageNames[row]
        }
        else // If the second PickerView was selected, assign that student's name/image to the Player2 Starship
        {
            Game.🚀2.name = Game.students[row]
            Game.🚀2.imageName = imageNames[row]
        }
        
                
    }
    

}
