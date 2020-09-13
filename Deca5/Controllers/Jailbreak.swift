//
//  Jailbreak.swift
//  Deca5
//
//

import SwiftUI

struct Jailbreak: View {
    @EnvironmentObject var cScreen: currentScreen
    @ObservedObject var globalCallback: sendModel = sendModel.sharedInstance
    @State var percentage:CGFloat = 0
    var body: some View {
        ZStack {
            Circle().frame(width:300).foregroundColor(Color.init(hex:"C05746")).offset(x:1920*(2/5)*(-1/2), y: 1080*(2/5)*(-1/2))
            Circle().frame(width:300).foregroundColor(Color.init(hex:"77A0A9")).offset(x:1920*(2/5)*(1/2), y: 1080*(2/5)*(1/2))
            VStack() {
                HStack() {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("DECA5").font(Font.custom("Mazzard M Bold", size: 55)).foregroundColor(Color.init(hex:"707070"))
                        Text("Jailbreak Your Device").font(Font.custom("Mazzard M Bold", size: 40)).foregroundColor(Color.init(hex:"707070"))
                    }.padding(.trailing, 20)
                }.padding(.top, 20)
                HStack() {
                    if !self.globalCallback.boot_device && !self.globalCallback.try_again_show && self.globalCallback.callback != "Successfully booted device...installing Jailbreak" {
                        Spacer()
                        Button(action: {
                                var ret: Int
                                self.globalCallback.boot_device = true
                                ret = jailbreak_main()
                        }) {
                            VStack() {
                                ZStack {
                                    Circle().frame(height:60)
                                    Text("J").foregroundColor(Color.white)
                                }
                                Text("Jailbreak Device").font(Font.custom("Mazzard M Medium", size: 14))
                            }
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    } else {
                        ZStack{
                            Pulsation()
                            Track()
                            Label(percentage: CGFloat(self.globalCallback.progress))
                            Outline(percentage: CGFloat(self.globalCallback.progress))
                        }
                    }
                }.padding(.top, 40)
                if  self.globalCallback.boot_device || self.globalCallback.try_again_show || self.globalCallback.callback == "Successfully booted device...installing Jailbreak" {
                    Text("\(self.globalCallback.callback)").font(Font.custom("Mazzard M Medium", size: 20)).foregroundColor(Color.init(hex:"707070")).padding(.top, 40)
                }
                Spacer()
                HStack() {
                    if !self.globalCallback.boot_device || self.globalCallback.try_again_show {
                        Button(action: { self.cScreen.screen = .home; reset_model()}) {
                            Text("⮐ Back").font(Font.custom("Mazzard M Bold", size: 25)).foregroundColor(Color.init(hex:"707070"))
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, 20)
                    }
                    if self.globalCallback.try_again_show {
                        Spacer()
                        Button(action: {
                            var ret: Int = 1
                            self.globalCallback.try_again_show = false
                            self.globalCallback.boot_device = true
                            ret = jailbreak_main()
                        }) {
                            Text("Try Again?").font(Font.custom("Mazzard M Bold", size: 25)).foregroundColor(Color.init(hex:"707070")).padding(.leading, 0)
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, 0).padding(.trailing, 108)
                    }
                    Spacer()
                }.padding(.bottom, 20)
            }.frame(width: 1920*(2/5), height: 1080*(2/5))
        }.frame(width: 1920*(2/5), height: 1080*(2/5))
    }
}
