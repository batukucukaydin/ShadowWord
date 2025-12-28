//
//  CategorySelectionView.swift
//  ShadowWord
//

import SwiftUI

struct CategorySelectionView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground(showParticles: false)
                
                ScrollView {
                    VStack(spacing: SWSpacing.md) {
                        // Select All Toggle
                        GlassCard(padding: SWSpacing.md) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.swGradientPrimary)
                                
                                Text("All Categories")
                                    .font(SWTypography.headline)
                                    .foregroundColor(.swTextPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { viewModel.allCategoriesSelected },
                                    set: { isOn in
                                        if isOn {
                                            viewModel.selectAllCategories()
                                        } else {
                                            viewModel.deselectAllCategories()
                                        }
                                    }
                                ))
                                .tint(Color.swGlowPurple)
                                .labelsHidden()
                            }
                        }
                        
                        // Category List
                        ForEach(viewModel.availableCategories) { category in
                            CategoryRow(
                                category: category,
                                isSelected: viewModel.isCategorySelected(category.name)
                            ) {
                                viewModel.toggleCategory(category.name)
                            }
                        }
                        
                        Spacer(minLength: SWSpacing.xxxl)
                    }
                    .padding(.horizontal, SWSpacing.lg)
                    .padding(.top, SWSpacing.md)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.swGlowPurple)
                }
            }
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticsService.shared.selection()
            action()
        }) {
            GlassCard(padding: SWSpacing.md) {
                HStack(spacing: SWSpacing.md) {
                    // Category Icon
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .swGlowPurple : .swTextSecondary)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isSelected 
                                    ? Color.swGlowPurple.opacity(0.2) 
                                    : Color.swTextSecondary.opacity(0.1))
                        )
                    
                    // Category Info
                    VStack(alignment: .leading, spacing: SWSpacing.xxxs) {
                        Text(category.name)
                            .font(SWTypography.headline)
                            .foregroundColor(.swTextPrimary)
                        
                        Text("\(category.wordCount) words • \(category.questionCount) questions")
                            .font(SWTypography.caption)
                            .foregroundColor(.swTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Checkbox
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .swGlowPurple : .swTextSecondary.opacity(0.5))
                }
            }
        }
    }
}

#Preview {
    CategorySelectionView(viewModel: SettingsViewModel())
}
