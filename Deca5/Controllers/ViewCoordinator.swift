//
//  ViewCoordinator.swift
//  Deca5
//

import SwiftUI
struct ViewCoordinator: View {
    @EnvironmentObject var cScreen: currentScreen
    var body: some View {
        VStack() {
            current()
        }
    }
    func current() -> AnyView {
        switch  cScreen.screen {
        case .home: return AnyView(Home())
        case .restore: return AnyView(Restore())
        case .boot: return AnyView(Boot())
        case .jailbreak: return AnyView(Jailbreak())
        }
    }
}


struct ViewCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        ViewCoordinator()
    }
}

class currentScreen: ObservableObject {
    enum Screens {
        case home
        case restore
        case boot
        case jailbreak
    
    }
    
    @Published var screen: Screens = .home
    
}
