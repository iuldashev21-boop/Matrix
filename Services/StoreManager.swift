import Foundation
import StoreKit

@MainActor
@Observable
final class StoreManager {
    static let shared = StoreManager()

    private let productID = "com.construct.matrixhabit.redpill"
    private let purchasedKey = "com.matrixhabit.redpill.purchased"

    var isRedPillOwned: Bool = false
    var redPillProduct: Product? = nil
    var purchaseInProgress: Bool = false
    var errorMessage: String? = nil

    static let freeHabitLimit = 3

    private var transactionListener: Task<Void, Never>?

    private init() {
        self.isRedPillOwned = UserDefaults.standard.bool(forKey: purchasedKey)

        Task { await checkEntitlements() }

        transactionListener = Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await handle(verificationResult)
            }
        }
    }

    func loadProduct() async {
        guard redPillProduct == nil else { return }
        do {
            let products = try await Product.products(for: [productID])
            redPillProduct = products.first
        } catch {
            errorMessage = "PRODUCT UNAVAILABLE"
        }
    }

    func purchase() async {
        guard let product = redPillProduct else {
            await loadProduct()
            guard let product = redPillProduct else { return }
            return await purchaseProduct(product)
        }
        await purchaseProduct(product)
    }

    private func purchaseProduct(_ product: Product) async {
        purchaseInProgress = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            case .pending:
                errorMessage = "AWAITING APPROVAL"
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "PURCHASE FAILED"
        }

        purchaseInProgress = false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            errorMessage = "RESTORE FAILED"
        }
    }

    private func checkEntitlements() async {
        for await verificationResult in Transaction.currentEntitlements {
            await handle(verificationResult)
        }
    }

    private func handle(_ verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else { return }

        if transaction.productID == productID {
            if transaction.revocationDate != nil {
                isRedPillOwned = false
                UserDefaults.standard.set(false, forKey: purchasedKey)
            } else {
                isRedPillOwned = true
                UserDefaults.standard.set(true, forKey: purchasedKey)
            }
        }

        await transaction.finish()
    }

    func canCreateHabit(currentCount: Int) -> Bool {
        isRedPillOwned || currentCount < StoreManager.freeHabitLimit
    }
}
