//
//  PrescriptionListView.swift
//  MedCare
//
//  SCREEN 2 — "Medicines". Lists every prescription the user has
//  logged, with navigation to a detail screen and a button to add a
//  new one.
//

import SwiftUI

struct PrescriptionListView: View {
    @EnvironmentObject var controller: PrescriptionController
    @State private var isShowingAddSheet = false

    var body: some View {
        ZStack {
            BotanicalBackgroundView()

            if controller.prescriptions.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(controller.prescriptions) { prescription in
                        NavigationLink {
                            PrescriptionDetailView(prescription: prescription)
                        } label: {
                            PrescriptionRowView(prescription: prescription)
                        }
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Medicines")
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

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "pills.circle")
                .font(.system(size: 50))
                .foregroundColor(Theme.leafGreen)
            Text("No medicines yet")
                .font(Theme.headingFont)
            Text("Tap the + button to log your first prescription.")
                .font(Theme.bodyFont)
                .secondaryTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                isShowingAddSheet = true
            } label: {
                Text("Add Prescription")
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
    }
}
