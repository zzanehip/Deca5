//
//  Restore.swift
//  Deca5 (Older Macs)
//

import Foundation



import Cocoa
import Swift
class Restore_Old: NSViewController {
    
    
    @IBOutlet weak var circle1: NSView!
    @IBOutlet weak var circle2: NSView!
    @IBOutlet weak var callback: NSTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var step1: NSButton!
    @IBOutlet weak var step2: NSButton!
    @IBOutlet weak var tryagain: NSButton!
    @IBOutlet weak var back: NSButton!
    @IBOutlet weak var sl: NSTextField!
    @IBOutlet weak var rl: NSTextField!
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
        
        sendModel.prep_restore = { (result) -> Void in
            DispatchQueue.main.async {
                if self.callback.stringValue == "Done. You can now restore." {
                    self.callback.isHidden = false
                } else {
                    self.callback.isHidden = !result
                }
                self.back.isHidden = result
                self.step1.isEnabled = !result
            }
          
        }
        
        sendModel.can_restore = { (result) -> Void in
            DispatchQueue.main.async {
                self.step2.isEnabled = result
            }
        }
        
        sendModel.try_again_show = { (result) -> Void in
            DispatchQueue.main.async {
                self.tryagain.isHidden = !result
                self.back.isHidden = !result
            }
        }
        
        sendModel.restore_done = { (result) -> Void in
            DispatchQueue.main.async {
                self.back.isHidden = !result
                self.progress.isIndeterminate = false
                self.progress.doubleValue = 100.0
            }
        }
        
        sendModel.try_again = false
        sendModel.ipsw_path = URL(string:"file://")
        sendModel.try_again_show?(false)
        sendModel.prep_restore?(false)
        sendModel.can_restore?(false)

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
    @IBAction func select_ipsw(_ sender: Any) {
       // if  !sendModel.prep_restore {
          //sendModel.prep_restore = true
        sendModel.prep_restore?(true)
        selectIPSW()
        //}
        
    }
    @IBAction func restore(_ sender: Any) {
        var ret: Int
        self.back.isHidden = true
        self.step1.isHidden = true
        self.step2.isHidden = true
        self.sl.isHidden = true
        self.rl.isHidden = true
        self.progress.isHidden = false
        ret = restore_main()
    }
    @IBAction func try_again(_ sender: Any) {
        sendModel.try_again_show?(false)
        self.back.isHidden = true
        var ret: Int
        ret = restore_main()
    }
    
    override var representedObject: Any? {
        didSet {
         //   self.callback.isHidden = sendModel.prep_restore
        // Update the view, if already loaded.
        }
    }


  
    
}


