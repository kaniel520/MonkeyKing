
import UIKit
import WebKit

public class MonkeyKing: NSObject {

    public typealias ResponseJSON = [String: Any]

    public typealias DeliverCompletionHandler = (Result<ResponseJSON?, Error>) -> Void
    public typealias LaunchCompletionHandler = (Result<Void, Error>) -> Void
    public typealias LaunchFromWeChatMiniAppCompletionHandler = (Result<String, Error>) -> Void
    public typealias OAuthCompletionHandler = (Result<ResponseJSON?, Error>) -> Void
    public typealias OAuthFromWeChatCodeCompletionHandler = (Result<String, Error>) -> Void
    public typealias OpenSchemeCompletionHandler = (Result<URL, Error>) -> Void
    public typealias PayCompletionHandler = (Result<Void, Error>) -> Void

    static let shared = MonkeyKing()

    var webView: WKWebView?

    var accountSet = Set<Account>()

    var deliverCompletionHandler: DeliverCompletionHandler?
    var launchCompletionHandler: LaunchCompletionHandler?
    var launchFromWeChatMiniAppCompletionHandler: LaunchFromWeChatMiniAppCompletionHandler?
    var oauthCompletionHandler: OAuthCompletionHandler?
    var oauthFromWeChatCodeCompletionHandler: OAuthFromWeChatCodeCompletionHandler?
    var openSchemeCompletionHandler: OpenSchemeCompletionHandler?
    var payCompletionHandler: PayCompletionHandler?

    private override init() {}

    public enum Account: Hashable {
        case weChat(appID: String, appKey: String?, miniAppID: String?)
        case qq(appID: String)
        case weibo(appID: String, appKey: String, redirectURL: String)
        case pocket(appID: String)
        case alipay(appID: String)
        case twitter(appID: String, appKey: String, redirectURL: String)

        public var isAppInstalled: Bool {
            switch self {
            case .weChat:
                return MonkeyKing.SupportedPlatform.weChat.isAppInstalled
            case .qq:
                return MonkeyKing.SupportedPlatform.qq.isAppInstalled
            case .weibo:
                return MonkeyKing.SupportedPlatform.weibo.isAppInstalled
            case .pocket:
                return MonkeyKing.SupportedPlatform.pocket.isAppInstalled
            case .alipay:
                return MonkeyKing.SupportedPlatform.alipay.isAppInstalled
            case .twitter:
                return MonkeyKing.SupportedPlatform.twitter.isAppInstalled
            }
        }

        public var appID: String {
            switch self {
            case .weChat(let appID, _, _):
                return appID
            case .qq(let appID):
                return appID
            case .weibo(let appID, _, _):
                return appID
            case .pocket(let appID):
                return appID
            case .alipay(let appID):
                return appID
            case .twitter(let appID, _, _):
                return appID
            }
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(appID)
        }

        public var canWebOAuth: Bool {
            switch self {
            case .qq, .weibo, .pocket, .weChat, .twitter:
                return true
            case .alipay:
                return false
            }
        }

        public static func == (lhs: MonkeyKing.Account, rhs: MonkeyKing.Account) -> Bool {
            switch (lhs, rhs) {
            case (.weChat(let lappID, _, _), .weChat(let rappID, _, _)),
                 (.qq(let lappID), .qq(let rappID)),
                 (.weibo(let lappID, _, _), .weibo(let rappID, _, _)),
                 (.pocket(let lappID), .pocket(let rappID)),
                 (.alipay(let lappID), .alipay(let rappID)),
                 (.twitter(let lappID, _, _), .twitter(let rappID, _, _)):
                return lappID == rappID
            case (.weChat, _),
                 (.qq, _),
                 (.weibo, _),
                 (.pocket, _),
                 (.alipay, _),
                 (.twitter, _):
                return false
            }
        }
    }

    public enum SupportedPlatform {
        case weChat
        case qq
        case weibo
        case pocket
        case alipay
        case twitter

        public var isAppInstalled: Bool {
            switch self {
            case .weChat:
                return shared.canOpenURL(urlString: "weixin://")
            case .qq:
                return shared.canOpenURL(urlString: "mqqapi://")
            case .weibo:
                return shared.canOpenURL(urlString: "weibosdk://request")
            case .pocket:
                return shared.canOpenURL(urlString: "pocket-oauth-v1://")
            case .alipay:
                return shared.canOpenURL(urlString: "alipayshare://") || shared.canOpenURL(urlString: "alipay://")
            case .twitter:
                return shared.canOpenURL(urlString: "twitter://")
            }
        }
    }

    public class func registerAccount(_ account: Account) {
        guard account.isAppInstalled || account.canWebOAuth else { return }
        for oldAccount in MonkeyKing.shared.accountSet {
            switch oldAccount {
            case .weChat:
                if case .weChat = account { shared.accountSet.remove(oldAccount) }
            case .qq:
                if case .qq = account { shared.accountSet.remove(oldAccount) }
            case .weibo:
                if case .weibo = account { shared.accountSet.remove(oldAccount) }
            case .pocket:
                if case .pocket = account { shared.accountSet.remove(oldAccount) }
            case .alipay:
                if case .alipay = account { shared.accountSet.remove(oldAccount) }
            case .twitter:
                if case .twitter = account { shared.accountSet.remove(oldAccount) }
            }
        }
        shared.accountSet.insert(account)
    }

    public class func registerLaunchFromWeChatMiniAppHandler(_ handler: @escaping LaunchFromWeChatMiniAppCompletionHandler) {
        shared.launchFromWeChatMiniAppCompletionHandler = handler
    }
}
