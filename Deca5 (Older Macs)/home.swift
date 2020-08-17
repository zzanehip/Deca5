//
//  ViewController.swift
//  Deca5 (Older Macs)
//

import Cocoa
import Swift
class Home_Old: NSViewController {
    
    
    @IBOutlet weak var circle1: NSView!
    @IBOutlet weak var circle2: NSView!
    @IBOutlet weak var label: NSTextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        update_label = { (result) -> Void in
            
            self.label.stringValue = result
        }
        
 
        circle1.layer?.cornerRadius = 150
        circle1.layer?.backgroundColor = CGColor(red: 192/255, green: 87/255, blue: 70/255, alpha: 1)
        circle2.layer?.cornerRadius = 150
        circle2.layer?.backgroundColor = CGColor(red: 119/255, green: 160/255, blue: 169/255, alpha: 1)
        // Do any additional setup after loading the view.
    }

    @IBAction func restore(_ sender: Any) {
        performSegue(withIdentifier: "restore", sender: nil)
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


  
    
}



