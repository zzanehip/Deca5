//
//  Home.swift
//  Deca5
//
//

import SwiftUI
import Foundation
import Combine

fileprivate var buffer = ""

struct Home: View {
    @EnvironmentObject var cScreen: currentScreen
    @State private var message = ""
    var body: some View {
        ZStack {
            Circle().frame(width:300).foregroundColor(Color.init(hex:"C05746")).offset(x:1920*(2/5)*(-1/2), y: 1080*(2/5)*(-1/2))
            Circle().frame(width:300).foregroundColor(Color.init(hex:"77A0A9")).offset(x:1920*(2/5)*(1/2), y: 1080*(2/5)*(1/2))
            VStack() {
                HStack() {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("DECA5").font(Font.custom("Mazzard M Bold", size: 55)).foregroundColor(Color.init(hex:"707070"))
                        Text("The A5 Tool").font(Font.custom("Mazzard M Bold", size: 55)).foregroundColor(Color.init(hex:"707070"))
                    }.padding(.trailing, 20)
                }.padding(.top, 20)
                HStack() {
                    Button(action: { self.cScreen.screen = .restore} ) {
                           Text("Restore").font(Font.custom("Mazzard M Medium", size: 14)).frame(width:80)
                    
                    }.padding(.leading, 260)

                    Spacer()
                    Button(action: { self.cScreen.screen = .boot  } ) {
                           Text("Boot").font(Font.custom("Mazzard M Medium", size: 14)).frame(width:80)
                    
                    }.padding(.trailing, 260)

                }.padding(.top, 40)
            Spacer()
                HStack() {
                    VStack(alignment: .leading) {
                        Text("By @zzanehip").font(Font.custom("Mazzard M Bold", size: 30)).foregroundColor(Color.init(hex:"707070"))
                    Spacer().frame(height:2)
                    Text("Made possible because of: @synackuk, @a1exdandy, @axi0mx, and @iH8sn0w.").font(Font.custom("Mazzard M Bold", size: 15)).foregroundColor(Color.init(hex:"707070"))
                    }.padding(.leading, 20)
                    Spacer()
                }.padding(.bottom, 20)
            }.frame(width: 1920*(2/5), height: 1080*(2/5))
        }.frame(width: 1920*(2/5), height: 1080*(2/5))
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
        
    }
}
