//
//  loader.swift
//  Deca5
//
//  Created by Zane Kleinberg on 8/5/20.
//

import SwiftUI

//** Thank You TJ for making me this — I hate designing loaders. **//

struct Label: View {
    var percentage: CGFloat = 0
    var body: some View{
        ZStack{
            Text("\(String(format: "%.0f", percentage))%").font(Font.custom("Mazzard M Bold", size: 30)).foregroundColor(Color.init(hex:"303030"))
        }
    }
}

struct Outline: View {
    var percentage: CGFloat = 45
    var colors: [Color] = [Color.init(hex:"777DA7")]
    var body: some View{
        ZStack {
            Circle()
                .fill(Color.clear).frame(width: 125 , height: 125)
            .overlay(
                Circle()
                    .trim(from: 0, to: percentage * 0.01)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .fill(AngularGradient(gradient: .init(colors: colors), center: .center, startAngle: .zero, endAngle: .init(degrees: 360)))
            ).animation(.spring(response: 4.0, dampingFraction: 0.825, blendDuration: 0.5))
            
        }
    }
}
struct Track: View {
    var body: some View{
        ZStack{
            Circle()
                .fill(Color.init(hex:"FFF4E4"))
                .frame(width: 125 , height: 125)
            .overlay(
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 10))
                .fill(Color.init(hex:"E4C5AF"))
            )
        }
    }
}

struct Pulsation: View {
    @State private var pulsate = false
    var body: some View{
        ZStack{
            Circle()
                .fill(Color.init(hex:"1F1A38"))
                .frame(width: 122.5, height: 122.5)
                .scaleEffect(pulsate ? 1.35 : 1.2)
                .animation(Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true))
                .onAppear{
                    self.pulsate.toggle()
            }
        }
    }
}

