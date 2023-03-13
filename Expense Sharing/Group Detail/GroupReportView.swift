//
//  GroupReportView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct GroupReportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var vm: GroupDetailViewModel
    
    @State var reportImage: UIImage?
    @State var showingReportShare = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            navigationBar
            reportView
            CapsuleDivider()
            if let safeImage = reportImage {
                Image(uiImage: safeImage)
            }
        }
        .appBackgroundGradient()
        .sheet(isPresented: $showingReportShare) {
            ActivityViewController(activityItems: getReportShareActivities()) { _ in
                showingReportShare = false
                clearReportSharedImage()
            }
        }
    }
    
    private var navigationBar: some View {
        AddOptionNavigationBar(
            title: "Report",
            cancelAction: {
                presentationMode.wrappedValue.dismiss()
            },
            confirmAction: {
                // Render image from reportView
                reportImage = reportView
                    .padding(16)
                    .frame(width: 300)
                    .appBackgroundGradient()
                    .snapshot()
                
                if reportImage != nil {
                    showingReportShare = true
                } else {
                    alertTitle = "Error"
                    alertMessage = "Failed to generate report image."
                    showingAlert = true
                }
            }
        )
    }
    
    private var reportView: some View {
        VStack(spacing: 12) {
            // Logo
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image("iconPlus")
                        .resizable().scaledToFit()
                        .squareFrame(side: 24)
                    Image("iconDivide")
                        .resizable().scaledToFit()
                        .squareFrame(side: 24)
                        .padding(6)
                }
                HStack(spacing: 6) {
                    Image("iconEquals")
                        .resizable().scaledToFit()
                        .squareFrame(side: 24)
                    Image("iconSmile")
                        .resizable().scaledToFit()
                        .squareFrame(side: 24)
                        .padding(6)
                }
            }

            Text(vm.groupTitle)
                .font(.title)
                .multilineTextAlignment(.center)

            let moneyText = CurrencyManager.getText(for: 10_000.10, currencyCode: vm.groupCurrencyCode)
            Text("Group of \(vm.groupUsers.count) users spent \(moneyText) over \(vm.groupTransactions.count) transactions.")
                .multilineTextAlignment(.leading)

            let dateText = dateFormatter.string(from: Date())
            Text(dateText)
                .font(.caption)
        }
    }
    
    // MARK: - Share
    
    private func getReportFileName() -> String {
        vm.groupTitle.replacingOccurrences(of: " ", with: "_") + "_report"
    }
    
    private func getReportShareActivities() -> [AnyObject] {
        guard let image = reportImage else { return [] }
        return ShareManager.getShareActivities(image, fileName: getReportFileName())
    }
    
    private func clearReportSharedImage() {
        ShareManager.clearSharedFile(named: getReportFileName() + ".png")
    }
}

extension View {
    func snapshot() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        guard let view = controller.view else { return nil }
        
        controller.disableSafeArea()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let targetSize = controller.view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .blue
        
        var success = false
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            success = view.drawHierarchy(in: controller.view.bounds,
                                         afterScreenUpdates: true)
        }
        
        return success ? image : nil
    }
}

// https://stackoverflow.com/questions/70156299/cannot-place-swiftui-view-outside-the-safearea-when-embedded-in-uihostingcontrol
extension UIHostingController {
    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        
        if ignoreSafeArea {
            disableSafeArea()
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
