//
//  GroupReportView.swift
//  Expense Sharing
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
            ScrollView(.vertical, showsIndicators: false) {
                reportView
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
        }
        .appBackgroundGradient()
        .sheet(isPresented: $showingReportShare) {
            ActivityViewController(activityItems: getReportShareActivities()) { _ in
                clearReportSharedImage()
            }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .resizable().scaledToFit()
                        .squareFrame(side: 16)
                        .padding(.vertical, 4)
                    Text("Close")
                }
                .padding(.horizontal, 8)
            }
            Spacer()
            Button {
                // Render image from reportView with more width
                if reportImage == nil {
                    reportImage = reportViewForImage.snapshot()
                }
                
                if reportImage != nil {
                    showingReportShare = true
                } else {
                    alertTitle = "Error"
                    alertMessage = "Failed to generate report image."
                    showingAlert = true
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Share")
                    Image(systemName: "photo")
                        .resizable().scaledToFit()
                        .squareFrame(side: 20)
                        .padding(2)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
            }
        }
        .overlay {
            Text("Report").bold()
        }
        .padding([.bottom, .horizontal], 8)
    }
    
    private var reportView: some View {
        VStack(spacing: 12) {
            reportInfoView
            getReportChartView(widthLimit: UIScreen.main.bounds.width - 32)
            reportTransactionsView
        }
    }
    
    private var reportViewForImage: some View {
        VStack(spacing: 12) {
            reportInfoView.frame(width: 600, alignment: .center)
            getReportChartView(widthLimit: 600 - 32)
            reportTransactionsView.frame(width: 600, alignment: .center)
        }
        .padding(16)
        .appBackgroundGradient()
    }
    
    private var reportInfoView: some View {
        VStack {
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

            // Group title
            Text(vm.groupTitle)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            // Short description
            let moneyText = CurrencyManager.getText(for: vm.getTotalSpent(), currencyCode: vm.groupCurrencyCode)
            Text("Group of \(vm.groupUsers.count) users spent \(moneyText) over \(vm.groupTransactions.count) transactions.")
                .multilineTextAlignment(.leading)
        }
    }
    
    private func getReportChartView(widthLimit: CGFloat) -> some View {
        VStack {
            HStack(spacing: 0) {
                let maxWidth = widthLimit / 2
                let maxHeight: CGFloat = 60
                
                // Users
                VStack(alignment: .trailing, spacing: 4) {
                    Text("User").padding(.trailing, 12)
                        .font(.caption)
                        .padding(.bottom, 6)
                    
                    ForEach(vm.groupUsers) { user in
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(user.name).font(.headline)
                            Text(user.email).font(.subheadline)
                        }
                        .lineLimit(1)
                        .padding(.trailing, 6)
                        .frame(height: maxHeight)
                    }
                }
                .padding(.vertical, 4)
                .frame(width: maxWidth, alignment: .trailing)
                
                // Divider
                Capsule()
                    .fill()
                    .frame(width: 2)
                
                // Expenses
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expenses").padding(.leading, 12)
                        .font(.caption)
                        .padding(.bottom, 6)
                    
                    let limits = vm.getUsersAmountsLimits()
                    ForEach(vm.groupUsers) { user in
                        reportChartRowView(for: user, limit: limits.2, maxWidth: maxWidth, maxHeight: maxHeight)
                    }
                }
                .padding(.vertical, 4)
                .frame(width: maxWidth, alignment: .leading)
            }
            .padding(.vertical, 12)
        }
    }
    
    private func reportChartRowView(for user: User, limit: Double, maxWidth: CGFloat, maxHeight: CGFloat) -> some View {
        let paidAmount = vm.getUserAmounts(for: user).0
        let shareAmount = abs(vm.getUserAmounts(for: user).1)
        let dueAmount = -(shareAmount - paidAmount)
        
        let paidWidth = min(maxWidth, maxWidth * (paidAmount / limit))
        let shareWidth = min(maxWidth, maxWidth * (shareAmount / limit))
        let dueWidth = min(maxWidth, maxWidth * (abs(dueAmount) / limit))
        
        let paidText = CurrencyManager.getText(for: paidAmount, currencyCode: vm.groupCurrencyCode)
        let shareText = CurrencyManager.getText(for: shareAmount, currencyCode: vm.groupCurrencyCode)
        let dueText = (dueAmount > 0 ? "+" : "") + CurrencyManager.getText(for: dueAmount, currencyCode: vm.groupCurrencyCode)
        
        let barColor = vm.userColors[user.email] ?? .white
        let textColor: Color = barColor == .white ? .blue : .white
        let subHeight = maxHeight / 3 - 2
        
        return VStack(alignment: .leading, spacing: 1) {
            OneWayChartRowView(
                barColor: barColor,
                barWidth: shareWidth,
                barText: shareText,
                textColor: textColor,
                putTextOverBar: shareWidth > maxWidth / 2
            )
                .frame(height: subHeight)
            OneWayChartRowView(
                barColor: barColor,
                barWidth: paidWidth,
                barText: paidText,
                textColor: textColor,
                putTextOverBar: paidWidth > maxWidth / 2
            )
                .frame(height: subHeight)
            OneWayChartRowView(
                barColor: barColor,
                barWidth: dueWidth,
                barText: dueText,
                textColor: textColor,
                putTextOverBar: dueWidth > maxWidth / 2
            )
                .frame(height: subHeight)
        }
        .frame(height: maxHeight, alignment: .center)
        .font(.caption2)
    }
    
    private var reportTransactionsView: some View {
        VStack {
            // Transactions to resolve group expenses
            VStack(alignment: .leading, spacing: 12) {
                Text("Money transfers to settle all users:")
                    .font(.headline)
                let actions = vm.getCashFlowActions()
                if actions.isEmpty {
                    HStack(spacing: 0) {
                        Spacer()
                        Text("None needed.")
                            .font(.subheadline)
                        Spacer()
                    }
                } else {
                    ForEach(0..<actions.count) { i in
                        let action = actions[i]
                        let moneyText = CurrencyManager.getText(for: action.0, currencyCode: vm.groupCurrencyCode)
                        HStack(spacing: 6) {
                            Circle()
                                .fill()
                                .squareFrame(side: 16)
                                .padding(4)
                            Text("\(action.1.name) (\(action.1.email)) should transfer \(moneyText) to \(action.2.name) (\(action.2.email))")
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            // Date
            let dateText = dateFormatter.string(from: Date())
            Text(dateText)
                .font(.caption)
                .padding(.vertical, 16)
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
