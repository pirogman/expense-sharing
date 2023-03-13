//
//  Expense_SharingApp.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Expense_SharingApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject var appManager = AppManager()
        
    init() {
        // Provide global setup if needed
    }
    
    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                switch appManager.appState {
                case .unauthorised:
                    AuthView()
                        .transition(.move(edge: .leading))
                case .authorised(let user):
                    UserProfileView(vm: UserProfileViewModel(user))
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut, value: appManager.appState)
            .environmentObject(appManager)
        }
    }
}

// MARK: -

extension String: Identifiable {
    public var id: String { self }
}

extension String {
    var hasText: Bool { !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

extension Color {
    static let gradientLight = Color("gradientLight")
    static let gradientDark = Color("gradientDark")
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct SquareFrameModifier: ViewModifier {
    let side: CGFloat
    
    func body(content: Content) -> some View {
        content.frame(width: side, height: side)
    }
}

extension View {
    func squareFrame(side: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: SquareFrameModifier(side: side))
    }
}

extension View {
    func stylishTextField() -> some View {
        self.textFieldStyle(.plain)
            .foregroundColor(.gradientDark)
            .accentColor(.gradientLight)
            .frame(height: 32)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
            )
    }
}

extension View {
    /// Apply a mask to top and bottom in order to fade content away
    func maskScrollEdges(startPoint: UnitPoint, endPoint: UnitPoint) -> some View {
        self.mask(
            LinearGradient(gradient: Gradient(stops: [
                .init(color: .black.opacity(0), location: 0.0),
                .init(color: .black, location: 0.02),
                .init(color: .black, location: 0.98),
                .init(color: .black.opacity(0), location: 1.0),
            ]), startPoint: startPoint, endPoint: endPoint)
        )
    }
}

extension View {
    func coverWithLoader(_ cover: Bool) -> some View {
        ZStack {
            self
            if cover {
                Color.blue.opacity(0.15)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
            }
        }
    }
    func appBackgroundGradient() -> some View {
        self.preferredColorScheme(.light)
            .foregroundColor(.accentColor)
            .tint(.accentColor)
            .background(
                LinearGradient(gradient: Gradient(colors: [.gradientLight, .gradientDark]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func simpleAlert(isPresented: Binding<Bool>, title: String, message: String) -> some View {
        self.alert(title, isPresented: isPresented) {
                Button {
                    // Do nothing
                } label: {
                    Text("OK")
                }
            } message: {
                Text(message)
            }
    }
    func textFieldAlert(isPresented: Binding<Bool>, title: String, message: String, placeholder: String, input: Binding<String>, onConfirm: @escaping () -> Void) -> some View {
        self.alert(title, isPresented: isPresented) {
                TextField(placeholder, text: input)
                Button {
                    onConfirm()
                } label: {
                    Text("Confirm")
                }
                Button {
                    // Do not update
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text(message)
            }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var completionHandler: ((Bool) -> Void)? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            completionHandler?(completed)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
        //
    }
}

//extension Encodable {
//    var toDictionary: [String: Any]? {
//        guard let data =  try? JSONEncoder().encode(self) else { return nil }
//        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
//    }
//}

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
