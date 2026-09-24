//
//  PrescriptionListView.swift
//  MedCare

import SwiftUI

struct PrescriptionListView: View {
    @EnvironmentObject var controller: PrescriptionController
    @EnvironmentObject var loc: LocalizationManager
    @State private var isShowingAddSheet = false
    @State private var searchText = ""

    private var filteredPrescriptions: [Prescription] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return controller.prescriptions
        }
        return controller.prescriptions.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.dosage.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            BotanicalBackgroundView()

            if controller.prescriptions.isEmpty {
                emptyState
            } else if filteredPrescriptions.isEmpty {
                noResultsState
            } else {
                List {
                    ForEach(filteredPrescriptions) { prescription in
                        NavigationLink {
                            PrescriptionDetailView(prescription: prescription)
                        } label: {
                            PrescriptionRowView(prescription: prescription)
                        }
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: loc.t("Search medicines"))
            }
        }
        .navigationTitle(loc.t("Medicines"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            PrescriptionFormView(mode: .add)
        }
    }

    private var noResultsState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(Theme.leafGreen)
            Text("No matches for \"\(searchText)\"")
                .font(Theme.bodyFont)
                .secondaryTextStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "pills.circle")
                .font(.system(size: 50))
                .foregroundColor(Theme.leafGreen)
            Text(loc.t("No medicines yet"))
                .font(Theme.headingFont)
            Text("Tap the + button to log your first prescription.")
                .font(Theme.bodyFont)
                .secondaryTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                isShowingAddSheet = true
            } label: {
                Text(loc.t("Add Prescription"))
                    .font(Theme.bodyFont.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.leafGreen)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    NavigationStack {
        PrescriptionListView()
            .environmentObject(PrescriptionController())
            .environmentObject(NotificationController())
            .environmentObject(AccessibilitySettings())
            .environmentObject(LocalizationManager())
    }
}
