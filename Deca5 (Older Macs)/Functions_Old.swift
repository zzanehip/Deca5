//
//  Functions_Old.swift
//  Deca5 (Older Macs)
//
//

import Foundation
import Cocoa
import ZIPFoundation

var update_label:((String)->())?
func updatetest() {
    update_label?("Test")
    
}

func selectIPSW() {
    let dialog = NSOpenPanel();
    dialog.title                   = "Select IPSW for restore";
    dialog.showsResizeIndicator    = true;
    dialog.showsHiddenFiles        = false;
    dialog.allowsMultipleSelection = false;
    dialog.canChooseDirectories = false;
    dialog.allowedFileTypes        = ["ipsw"];
    
    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
        let result = dialog.url // Pathname of the file
        
        if (result != nil) {
            let path: String = result!.path
            print(path)
            restore_processing_main(ipsw_path: result!)
            sendModel.ipsw_path = result!
        }
        
    } else {
        sendModel.prep_restore?(false)
        return
    }
}

func restore_processing_main(ipsw_path: URL) {
    //Begin Process Of Building Components
    let group = DispatchGroup()
    group.enter()
    let dispatchQueue = DispatchQueue(label: "Deca5-Process", qos: .background)
    dispatchQueue.async(group: group,  execute: {
        let path = directory_controler()
        print("Got Path")
        sendModel.callback?("Starting up...")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                if directoryExistsAtPath(fileURL.path) {
                    continue
                } else {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print(error)
        }
        print("Entering extract_components")
        sendModel.callback?("Entering extract_components")
        print("Extracting BuildManifest.plist")
        sendModel.callback?("Extracting BuildManifest.plist")
        extract_components(ipsw_path: ipsw_path, as_path: path, file_path: "BuildManifest.plist", type: "BuildManifest.plist")
        print("Getting Info")
        let info = read_manifest_ipsw_info(as_path: path)
        let device = info.0
        let version = info.1
        print(device, version)
        sendModel.callback?("Identified as \(device) \(version)")
        get_decrypted_components(component: "iBSS", as_path: path, ipsw_path: ipsw_path, device: device, version: version, should_decrypt: "FALSE")
        iBootPatcher(convert_to_mutable_pointer(value: "\(path.path)/iBSS.decrypted"), convert_to_mutable_pointer(value: "\(path.path)/iBSS.patched"), UnsafeMutablePointer<Int8>(mutating: nil), convert_to_mutable_pointer(value: "TRUE"), convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "FALSE"))
        decrypt(convert_to_mutable_pointer(value: "\(path.path)/iBSS.patched"), convert_to_mutable_pointer(value: "\(path.path)/iBSS"), UnsafeMutablePointer<Int8>(mutating: nil), UnsafeMutablePointer<Int8>(mutating: nil), convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "\(path.path)/iBSS.extracted"))
        get_decrypted_components(component: "iBEC", as_path: path, ipsw_path: ipsw_path, device: device, version: version, should_decrypt: "FALSE")
        if version == "8F191" || version == "8G4" || version == "8H7" || version == "8J2" || version == "8K2" || version == "8L1" {
            iBootPatcher(convert_to_mutable_pointer(value: "\(path.path)/iBEC.decrypted"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.patched"), convert_to_mutable_pointer(value:"-v rd=md0 amfi=0xff cs_enforcement_disable=1 pio-error=0"), convert_to_mutable_pointer(value: "TRUE"), convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "FALSE"))
            //No ticket on iOS 4
        } else {
        iBootPatcher(convert_to_mutable_pointer(value: "\(path.path)/iBEC.decrypted"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.patched"),convert_to_mutable_pointer(value:"-v rd=md0 amfi=0xff cs_enforcement_disable=1 pio-error=0"), convert_to_mutable_pointer(value: "TRUE"), convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "TRUE"))
        }
        decrypt(convert_to_mutable_pointer(value: "\(path.path)/iBEC.patched"), convert_to_mutable_pointer(value: "\(path.path)/iBEC"), UnsafeMutablePointer<Int8>(mutating: nil), UnsafeMutablePointer<Int8>(mutating: nil),  convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.extracted"))
        if version == "8F191" || version == "8G4" || version == "8H7" || version == "8J2" || version == "8K2" || version == "8L1" {
            iBootPatcher(convert_to_mutable_pointer(value: "\(path.path)/iBEC.decrypted"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.preboot"), UnsafeMutablePointer<Int8>(mutating: nil), convert_to_mutable_pointer(value: "TRUE"), convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "FALSE"))
            //No ticket on iOS 4
        } else {
        iBootPatcher(convert_to_mutable_pointer(value: "\(path.path)/iBEC.decrypted"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.preboot"),convert_to_mutable_pointer(value:"-v amfi=0xff cs_enforcement_disable=1 pio-error=0"), convert_to_mutable_pointer(value: "TRUE"), convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "TRUE"))
        }
        decrypt(convert_to_mutable_pointer(value: "\(path.path)/iBEC.preboot"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.boot"), UnsafeMutablePointer<Int8>(mutating: nil), UnsafeMutablePointer<Int8>(mutating: nil),  convert_to_mutable_pointer(value: "FALSE"), convert_to_mutable_pointer(value: "\(path.path)/iBEC.extracted"))
        get_decrypted_components(component: "DeviceTree", as_path: path, ipsw_path: ipsw_path, device: device, version: version, should_decrypt: "FALSE")
        get_decrypted_components(component: "KernelCache", as_path: path, ipsw_path: ipsw_path, device: device, version: version, should_decrypt: "FALSE")
        get_decrypted_components(component: "RestoreRamDisk", as_path: path, ipsw_path: ipsw_path, device: device, version: version, should_decrypt: "FALSE")
        get_decrypted_components(component: "AppleLogo", as_path: path, ipsw_path: ipsw_path, device: device, version: version, should_decrypt: "FALSE")
        print("Cleaning Up")
        for component in ["iBSS.extracted", "iBSS.decrypted", "iBSS.patched", "iBEC.extracted", "iBEC.decrypted", "iBEC.patched", "iBEC.preboot"] {
            delete_component(as_path: path, component: component)
        }
        print("Done")
        sendModel.callback?("Done. You can now restore.")
        sendModel.can_restore?(true)
        sendModel.prep_restore?(false)
    })
    group.leave()
    group.notify(queue: DispatchQueue.main, execute: {
        print("Finished")
    })
}

func restore_main() -> Int {
    var callbacks = swift_callbacks(
        send_output_to_swift: { (modifier) in
            send_output_to_swift(modifier: modifier)
        }
    )
    callback_setup(&callbacks)
    var progress = swift_progress(
        send_output_progress_to_swift: { (modifier) in
            send_output_progress_to_swift(modifier: modifier)
        }
    )
    progress_setup(&progress)
    let group = DispatchGroup()
    group.enter()
    let dispatchQueue = DispatchQueue(label: "Deca5-Restore", qos: .background)
    dispatchQueue.async(group: group,  execute: {
        var ret: Int32
        var ecid: String = ""
        var ecid_path: URL
        let path = directory_controler()
        sendModel.callback?("")
        sendModel.callback?("Finding device...")
        sendModel.progress?(100.0)
        ret = get_dev()
        if ret != 0 {
            sendModel.callback?("Error finding device")
            sendModel.try_again = true
            sendModel.try_again_show?(true)
            sendModel.progress?(0.0)
            return
        }
        sendModel.callback?("Retrieving ECID...")
        ecid = String(cString:send_ecid())
        if ecid == "" {
            sendModel.callback?("Error retrieving ECID")
            sendModel.try_again = true
            sendModel.try_again_show?(true)
            sendModel.progress?(0.0)
            return
        }
        do {
            sleep(2)
        }
        if !sendModel.try_again {
            sendModel.callback?("Shuffling files...")
            ecid_path = create_device_directory(ecid: ecid, as_path: path)
            for component in ["iBSS", "iBEC", "iBEC.boot", "DeviceTree", "RestoreRamDisk", "KernelCache", "BuildManifest.plist", "AppleLogo"] {
                move_component(as_path: path, ecid_path: ecid_path, component: component)
            }
            do {
                sleep(2)
            }
        } else {
            if component_exists(as_path: path, component: "iBSS") {
                sendModel.callback?("Shuffling files...")
                ecid_path = create_device_directory(ecid: ecid, as_path: path)
                for component in ["iBSS", "iBEC", "iBEC.boot", "DeviceTree", "RestoreRamDisk", "KernelCache", "BuildManifest.plist", "AppleLogo"] {
                    move_component(as_path: path, ecid_path: ecid_path, component: component)
                }
                do {
                    sleep(2)
                }
            } else {
                ecid_path = path.appendingPathComponent(ecid, isDirectory: true)
            }
        }
            
        sendModel.callback?("Sending iBSS...")
        ret = sendiBSS(convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBSS")))
        if ret != 0 {
            sendModel.progress?(0.0)
            sendModel.callback?("Error sending iBSS")
            sendModel.try_again = true
            sendModel.try_again_show?(true)
            sendModel.progress?(0.0)
            return
        } else {
            sendModel.callback?("Done Sending iBSS")
            do {
                sleep(2)
            }
        }
        sendModel.callback?("Sending iBEC...")
        ret = sendiBEC(convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBEC")))
        if ret != 0 {
            sendModel.progress?(0.0)
            sendModel.callback?("Error sending iBEC")
            sendModel.try_again = true
            sendModel.try_again_show?(true)
            return
        } else {
            sendModel.callback?("Done Sending iBEC")
            do {
                sleep(2)
            }
        }
        sendModel.callback?("Preparing to restore device...")
        ret = deca5restore(convert_to_mutable_pointer(value: sendModel.ipsw_path?.path ?? ""), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBSS")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBEC")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "DeviceTree")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "RestoreRamDisk")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "KernelCache")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "AppleLogo")))
        if ret != 0 {
            sendModel.progress?(0.0)
            print("Error Restoring...")
            sendModel.try_again = true
            sendModel.try_again_show?(true)
            sendModel.callback?("Error Restoring")
            return
        }
        sendModel.callback?("Successfully restored device")
        sendModel.restore_done?(true)
    })
    group.leave()
    group.notify(queue: DispatchQueue.main, execute: {
        print("Finished")
    })
    return 0
}

func boot_main() -> Int {
    var callbacks = swift_callbacks(
        send_output_to_swift: { (modifier) in
            send_output_to_swift(modifier: modifier)
        }
    )
    callback_setup(&callbacks)
    var progress = swift_progress(
        send_output_progress_to_swift: { (modifier) in
            send_output_progress_to_swift(modifier: modifier)
        }
    )
    progress_setup(&progress)
    let group = DispatchGroup()
    group.enter()
    let dispatchQueue = DispatchQueue(label: "Deca5-Boot", qos: .background)
    dispatchQueue.async(group: group,  execute: {
        var ret: Int32 = 0
        var ecid: String = ""
        var mode: String = ""
        var ecid_path: URL
        let path = directory_controler()
        sendModel.callback?("Finding device...")
        sendModel.progress?(100.0)
        ret = get_dev()
        if ret != 0 {
           sendModel.callback?("Error finding device")
            sendModel.try_again_show?(true)
            return
        }
       sendModel.callback?("Retrieving ECID...")
        ecid = String(cString:send_ecid())
        if ecid == "" {
           sendModel.callback?("Error retrieving ECID")
        sendModel.try_again_show?(true)
            return
        }
        do {
            sleep(2)
        }
        ecid_path = path.appendingPathComponent(ecid, isDirectory: true)
        if !component_exists(as_path: ecid_path, component: "iBSS") {
           sendModel.callback?("No boot components for device")
        sendModel.try_again_show?(true)
            return
        }
       sendModel.callback?("Sending preboot iBSS...")
       ret = sendiBSS(convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBSS")))
        if ret != 0 {
            sendModel.progress?(0.0)
           sendModel.callback?("Error sending preboot iBSS")
        sendModel.try_again_show?(true)
            return
        } else {
           sendModel.callback?("Done sending preboot iBSS")
            do {
                sleep(2)
            }
        }
       sendModel.callback?("Sending preboot iBEC...")
       ret = sendiBEC(convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBEC.boot")))
        if ret != 0 {
            sendModel.progress?(0.0)
           sendModel.callback?("Error sending preboot iBEC")
        sendModel.try_again_show?(true)
            return
        } else {
           sendModel.callback?("Done sending preboot iBEC")
            do {
                sleep(6)
            }
        }
       sendModel.callback?("Booting..")
        //This is soooo hacky but it works...
        ret = deca5boot(convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBSS")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "iBEC.boot")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "DeviceTree")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "RestoreRamDisk")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "KernelCache")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "BuildManifest.plist")), convert_to_mutable_pointer(value: convert_component_path(ecid_path: ecid_path, component: "AppleLogo")))
        if ret != 0 {
            sendModel.progress?(0.0)
           sendModel.callback?("Error Booting")
        sendModel.try_again_show?(true)
            return
        }
       sendModel.callback?("Successfully booted device")
       sendModel.boot_done?(true)
        
    })
    group.leave()
    group.notify(queue: DispatchQueue.main, execute: {
        print("Finished")
    })
    return 0
}
    


func directory_controler() -> URL {
    var as_path: URL!
    do {
        let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        as_path = applicationSupportFolderURL.appendingPathComponent("deca5/", isDirectory: true)
        if !FileManager.default.fileExists(atPath: as_path.path) {
            try FileManager.default.createDirectory(at: as_path, withIntermediateDirectories: true, attributes: nil)
        }
    } catch { print(error) }
    return as_path
}

func create_device_directory(ecid: String, as_path: URL) -> URL{
    var ecid_directory: URL!
    do {
        ecid_directory = as_path.appendingPathComponent(ecid, isDirectory: true)
        if !FileManager.default.fileExists(atPath: ecid_directory.path) {
            try FileManager.default.createDirectory(at: ecid_directory, withIntermediateDirectories: true, attributes: nil)
        } else {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: ecid_directory,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                for fileURL in fileURLs {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch  { print(error) }
        }
    } catch { print(error) }
    return ecid_directory
}

func clear_files(as_path: URL) {
    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: as_path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        for fileURL in fileURLs {
            if directoryExistsAtPath(fileURL.path) {
                continue
            } else {
                try FileManager.default.removeItem(at: fileURL)
            }
        }
    } catch {
        print(error)
    }
}

fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
    var isDirectory = ObjCBool(true)
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}

func delete_component(as_path: URL, component: String) {
    let component_path = as_path.appendingPathComponent(component, isDirectory: false)
    do {
        try FileManager.default.removeItem(atPath: component_path.path)
    }
    catch {
        print(error)
    }
}

func move_component(as_path: URL, ecid_path: URL, component: String) {
    let component_path = as_path.appendingPathComponent(component, isDirectory: false)
    let ecid_path = ecid_path.appendingPathComponent(component, isDirectory: false)
    do {
        try FileManager.default.moveItem(atPath: component_path.path, toPath: ecid_path.path)
    }
    catch {
        print(error)
    }
}

func component_exists(as_path: URL, component: String) -> Bool{
    let component_path = as_path.appendingPathComponent(component, isDirectory: false)
    if FileManager.default.fileExists(atPath: component_path.path) {
        return true
    } else {
        return false
    }
    
}

func convert_component_path(ecid_path: URL, component: String) -> String {
    let component_path = ecid_path.appendingPathComponent(component, isDirectory: false).path
    return component_path
}

func extract_components(ipsw_path: URL, as_path: URL, file_path: String, type: String) {
    // ty Zip Foundation
    guard let archive = Archive(url: ipsw_path, accessMode: .read) else  {
        return
    }
    guard let entry = archive[file_path] else {
        return
    }
    do {
        if type == "BuildManifest.plist" || type == "RestoreRamDisk" || type == "AppleLogo" || type == "KernelCache" || type == "DeviceTree" {
            try archive.extract(entry, to: as_path.appendingPathComponent("\(type)"))
        } else {
            try archive.extract(entry, to: as_path.appendingPathComponent("\(type).extracted"))
        }
    } catch {
        print("Extracting entry from archive failed with error:\(error)")
    }
    
}

func read_manifest_value(as_path: URL, component: String) -> String {
    var result: String? = ""
    let url = as_path.appendingPathComponent("BuildManifest.plist")
    do {
        //Enter the lazy mans approach to a codeable
        let data = try Data(contentsOf:url)
        let constructed_dictionary = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as! [String : AnyObject]
        let build_identities = constructed_dictionary["BuildIdentities"] as! [[String : AnyObject]]
        let item_zero = build_identities[0] as! [String : AnyObject]
        let manifest = item_zero["Manifest"] as! [String : AnyObject]
        let component = manifest[component]  as! [String : AnyObject]
        let info = component["Info"]  as! [String : AnyObject]
        result = info["Path"] as? String
    } catch {
        print(error)
    }
    return result ?? ""
}
func read_manifest_ipsw_info(as_path:URL) -> (String, String) {
    var d: String? = ""
    var v: String? = ""
    let url = as_path.appendingPathComponent("BuildManifest.plist")
    do {
        let data = try Data(contentsOf:url)
        let constructed_dictionary = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as! [String : AnyObject]
        let supported_product_types = constructed_dictionary["SupportedProductTypes"] as! Array<String>
        let device = supported_product_types[0] as! String
        let product_build_version = constructed_dictionary["ProductBuildVersion"] as? String
        d = device
        v = product_build_version
    } catch {
        print(error)
    }
    return (d ?? "", v ?? "")
    
}

func ipsw_json_fetch(device: String, version: String, image: String, completion: @escaping (String?, String?) -> Void) {
    if let url = URL(string: "https://firmware-keys.ipsw.me/firmware/\(device)/\(version)") {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    let keys = array["keys"] as? [[String:Any]]
                    let index = keys?.firstIndex(where: { $0["image"] as! String == image})
                    let image_struct = keys?[index ?? 0]
                    let key = image_struct?["key"] as? String
                    let iv = image_struct?["iv"] as? String
                    completion(key ?? "", iv ?? "")
                }
            } catch {
                print(error)
                completion(nil, nil)
            }
        }
        task.resume()
    }
}


func convert_to_mutable_pointer(value: String) -> UnsafeMutablePointer<Int8> {
    let input = (value as NSString).utf8String
    guard  let computed_buffer =  UnsafeMutablePointer<Int8>(mutating: input) else {
        return UnsafeMutablePointer<Int8>(mutating: "")
    }
    return computed_buffer
}

func get_decrypted_components(component: String, as_path: URL, ipsw_path: URL, device: String, version: String, should_decrypt: String) {
    var key:String = ""
    var iv:String = ""
    let group = DispatchGroup()
    print("Entering \(component)")
    print("Getting  \(component) Path")
    let path = read_manifest_value(as_path: as_path, component: component)
    if  path == "" {
        print("error")
        return
    }
    print("Extracting \(component)...")
    sendModel.callback?("Extracting \(component)...")
    extract_components(ipsw_path: ipsw_path, as_path: as_path, file_path: path, type: component)
    print("Fetching Key/IV Pair")
    sendModel.callback?("Fetching Key/IV Pair...")
    key = ""
    iv = ""
    group.enter()
    DispatchQueue.global(priority: .default).async {
        if component == "RestoreRamDisk" {
            ipsw_json_fetch(device: device, version: version, image: "RestoreRamdisk") { (key_f, iv_f) in
                key = key_f ?? ""
                iv = iv_f ?? ""
                group.leave()
            }
        }
        else if component == "KernelCache" {
            ipsw_json_fetch(device: device, version: version, image: "Kernelcache") { (key_f, iv_f) in
                key = key_f ?? ""
                iv = iv_f ?? ""
                group.leave()
            }
        }
        else {
            ipsw_json_fetch(device: device, version: version, image: component) { (key_f, iv_f) in
                key = key_f ?? ""
                iv = iv_f ?? ""
                group.leave()
            }
        }
    }
    group.wait()
    if component != "RestoreRamDisk" || component != "AppleLogo" || component != "KernelCache" || component != "DeviceTree" {
        print("Decrypting \(component)")
        sendModel.callback?("Decrypting \(component)")
        if component == "iBSS" || component == "iBEC" {
            decrypt(convert_to_mutable_pointer(value: "\(as_path.path)/\(component).extracted"), convert_to_mutable_pointer(value: "\(as_path.path)/\(component).decrypted"), convert_to_mutable_pointer(value: key), convert_to_mutable_pointer(value: iv), convert_to_mutable_pointer(value: should_decrypt), UnsafeMutablePointer<Int8>(mutating: nil))
        }
    }
}

struct sendModel {
    static var ipsw_path = URL(string:"file://")
    static var callback:((String)->())?
    static var progress:((Double)->())?
    static var restore_processes:((Bool)->())?
    static var try_again: Bool = false
    static var try_again_show:((Bool)->())?
    static var restore_done:((Bool)->())?
    static var prep_restore:((Bool)->())?
    static var can_restore:((Bool)->())?
    static var boot_done:((Bool)->())?

}

func send_output_to_swift(modifier: UnsafePointer<CChar>) {
    print(String(cString: modifier))
    DispatchQueue.main.async {
        sendModel.callback?(String(cString: modifier))
    }
}

func send_output_progress_to_swift(modifier: Double) {
    DispatchQueue.main.async {
        sendModel.progress?(modifier)
    }
}
