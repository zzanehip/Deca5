//
//  Jailbreak_Old.swift
//  Deca5
//

import Foundation

import Cocoa
import Swift
class Jailbreak_Old: NSViewController {
    
    
    @IBOutlet weak var circle1: NSView!
    @IBOutlet weak var circle2: NSView!
    @IBOutlet weak var callback: NSTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var boot: NSButton!
    @IBOutlet weak var tryagain: NSButton!
    @IBOutlet weak var back: NSButton!
    @IBOutlet weak var bl: NSTextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sendModel.callback = { (result) -> Void in
            DispatchQueue.main.async {
            self.callback.stringValue = result
            }
        }
        
        
        sendModel.progress = { (result) -> Void in
            DispatchQueue.main.async {
            self.progress.isIndeterminate = result == 100.0 ? true : false
            self.progress.doubleValue = result
            self.progress.startAnimation(nil)
            }
        }
        
        sendModel.try_again_show = { (result) -> Void in
            DispatchQueue.main.async {
                self.tryagain.isHidden = !result
                self.back.isHidden = !result
            }
        }
        
        sendModel.boot_done = { (result) -> Void in
            DispatchQueue.main.async {
                self.back.isHidden = !result
                self.progress.isIndeterminate = false
                self.progress.doubleValue = 100.0
            }
        }
        
        sendModel.try_again_show?(false)
        sendModel.boot_done?(true)

        circle1.layer?.cornerRadius = 150
        circle1.layer?.backgroundColor = CGColor(red: 192/255, green: 87/255, blue: 70/255, alpha: 1)
        circle2.layer?.cornerRadius = 150
        circle2.layer?.backgroundColor = CGColor(red: 119/255, green: 160/255, blue: 169/255, alpha: 1)
    
    }
    

    @IBAction func back(_ sender: Any) {
        if let controller = self.storyboard?.instantiateController(withIdentifier: "homeview") as? NSViewController {
        self.view.window?.contentViewController = controller
        }
        
    }
    @IBAction func jailbreak(_ sender: Any) {
        var ret: Int
        self.back.isHidden = true
        self.boot.isHidden = true
        self.bl.isHidden = true
        self.callback.isHidden = false
        self.progress.isHidden = false
        ret = jailbreak_main()
    }
    @IBAction func try_again(_ sender: Any) {
        sendModel.try_again_show?(false)
        self.back.isHidden = true
        var ret: Int
        ret = jailbreak_main()
    }
    
    override var representedObject: Any? {
        didSet {
         //   self.callback.isHidden = sendModel.prep_restore
        // Update the view, if already loaded.
        }
    }

    
}


