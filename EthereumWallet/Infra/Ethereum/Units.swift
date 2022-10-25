import BigInt
import Foundation

class Units {
    static let etherInWei = pow(Decimal(10), 18)

    static func toEther(wei: BigUInt) -> Decimal? {
        guard let decimalWei = Decimal(string: wei.description) else {
            return nil
        }
        return decimalWei / etherInWei
    }

    static func toEtherString(wei: BigUInt) -> String {
        guard let ether = toEther(wei: wei) else {
            return ""
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(for: ether) ?? ""
    }

    static func toWei(ether: Decimal) -> BigUInt? {
        guard let wei = BigUInt((ether * etherInWei).description) else {
            return nil
        }
        return wei
    }
}
