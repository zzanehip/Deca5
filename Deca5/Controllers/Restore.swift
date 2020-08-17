//
//  Restore.swift
//  Deca5
//
//

import SwiftUI

struct Restore: View {
    @EnvironmentObject var cScreen: currentScreen
    @ObservedObject var globalCallback: sendModel = sendModel.sharedInstance
    @State var percentage:CGFloat = 0
    @State var restore_processes: Bool = true
    @State var show_after_restore: Bool = false
    var body: some View {
        ZStack {
            Circle().frame(width:300).foregroundColor(Color.init(hex:"C05746")).offset(x:1920*(2/5)*(-1/2), y: 1080*(2/5)*(-1/2))
            Circle().frame(width:300).foregroundColor(Color.init(hex:"77A0A9")).offset(x:1920*(2/5)*(1/2), y: 1080*(2/5)*(1/2))
            VStack() {
                HStack() {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("DECA5").font(Font.custom("Mazzard M Bold", size: 55)).foregroundColor(Color.init(hex:"707070"))
                        Text("Restore Your Device").font(Font.custom("Mazzard M Bold", size: 40)).foregroundColor(Color.init(hex:"707070"))
                    }.padding(.trailing, 20)
                }.padding(.top, 20)
                HStack() {
                    if restore_processes {
                        Button(action: {
                            if  !self.globalCallback.prep_restore {
                                self.globalCallback.prep_restore = true
                                selectIPSW()
                            }
                        }) {
                            VStack() {
                                ZStack {
                                    Circle().frame(height:60)
                                    Text("1").foregroundColor(Color.white)
                                }
                                Text("Select IPSW").font(Font.custom("Mazzard M Medium", size: 14))
                            }
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, 160)
                        Button(action: {
                            if !self.globalCallback.prep_restore {
                            if self.globalCallback.can_restore {
                            var ret: Int = 1
                            self.restore_processes = false
                            ret = restore_main()
                            } else {
                                self.globalCallback.callback = "Please select an IPSW first"
                            }
                            }
                        }) {
                            VStack() {
                                ZStack {
                                    Circle().frame(height:60)
                                    Text("2").foregroundColor(Color.white)
                                }
                                Text("Restore Device").font(Font.custom("Mazzard M Medium", size: 14))
                            }
                        }.buttonStyle(PlainButtonStyle()).padding(.trailing, 160)
                    } else {
                        ZStack{
                            Pulsation()
                            Track()
                            Label(percentage: CGFloat(self.globalCallback.progress))
                            Outline(percentage: CGFloat(self.globalCallback.progress))
                        }
                    }
                }.padding(.top, 40)
                if !restore_processes || self.globalCallback.prep_restore || self.globalCallback.can_restore || self.globalCallback.callback == "Please select an IPSW first"{
                    Text("\(self.globalCallback.callback)").font(Font.custom("Mazzard M Medium", size: 20)).foregroundColor(Color.init(hex:"707070")).padding(.top, 40)
                }
                Spacer()
                HStack() {
                    if (!self.globalCallback.prep_restore && restore_processes) || self.globalCallback.try_again_show || self.globalCallback.restore_done {
                        Button(action: { self.restore_processes = true; self.cScreen.screen = .home; reset_model()}) {
                            Text("⮐ Back").font(Font.custom("Mazzard M Bold", size: 25)).foregroundColor(Color.init(hex:"707070"))
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, 20)
                    }
                    if self.globalCallback.try_again_show {
                        Spacer()
                        Button(action: {
                            var ret: Int = 1
                            self.globalCallback.restore_done = false
                            self.globalCallback.try_again_show = false
                            ret = restore_main()
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

struct Restore_Previews: PreviewProvider {
    static var previews: some View {
        Restore()
    }
}
