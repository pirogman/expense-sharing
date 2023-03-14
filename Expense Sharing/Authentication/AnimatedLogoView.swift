//
//  AnimatedLogoView.swift
//  Expense Sharing
//

import SwiftUI

struct AnimatedLogoView: View {
    let sizeLimit: CGFloat
    let logoPartSize: CGFloat
    let logoPartPadding: CGFloat
    let isAnimating: Bool
    
    init(sizeLimit: CGFloat, isAnimating: Bool) {
        self.sizeLimit = sizeLimit
        let step = sizeLimit / 16
        self.logoPartSize = step * 6
        self.logoPartPadding = step
        self.isAnimating = isAnimating
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                Image(logoPartIcons[i])
                    .resizable().scaledToFit()
                    .squareFrame(side: logoPartSize(at: i))
                    .offset(logoPartOffset(at: i))
            }
        }
        .squareFrame(side: sizeLimit)
        .onAppear {
            guard isAnimating else { return }
            
            //print("start animating logo on appear")
            animateNextLogoPart()
        }
        .onDisappear {
            //print("stop animating logo on disappear")
            timer?.invalidate()
        }
    }
    
    // MARK: - Animation
    
    @State private var timer: Timer?
    @State private var logoPartIndex = 0
    @State private var logoAnimation = [false, false, false, false]
    
    private let logoPartIcons = ["iconPlus", "iconDivide", "iconSmile", "iconEquals"]
    private let logoAnimationTime: TimeInterval = 0.9
    private let logoAnimationDelay: TimeInterval = 0.8
    private let logoPartScale: CGFloat = 0.75
    
    private func animateNextLogoPart() {
        let i = logoPartIndex
        
        if logoAnimation[i] {
            logoPartIndex = logoPartIndex < (logoAnimation.count - 1) ? (logoPartIndex + 1) : 0
        } else {
            // Stay on same part 2 times
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: logoAnimationDelay, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: logoAnimationTime)) {
                logoAnimation[i].toggle()
                //print("animating \(logoPartIcons[i]) to scale \(logoAnimation[i] ? "UP" : "DOWN")")
            }
            animateNextLogoPart()
        }
        timer!.tolerance = logoAnimationDelay / 10
    }
    
    private func logoPartOffset(at index: Int) -> CGSize {
        // In circular manner, clockwise:
        // [0, 1]
        // [3, 2]
        let leading = index == 0 || index == 3
        let top = index == 0 || index == 1
        
        let offset = logoPartSize(at: index) / 2 + logoPartOffset(at: index)
        return CGSize(width: leading ? -offset : offset,
                      height: top ? -offset : offset)
    }
    
    private func logoPartSize(at index: Int) -> CGFloat {
        logoPartSize * (logoAnimation[index] ? 1 : logoPartScale)
    }
    
    private func logoPartOffset(at index: Int) -> CGFloat {
        logoPartPadding * (logoAnimation[index] ? 1 : logoPartScale)
    }
}
