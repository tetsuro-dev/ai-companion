# AI Companion

かわいい動物キャラクターとAIを使って会話ができるiOSアプリです。
自然な対話とリアルタイムなリップシンクで、まるで本物のペットと話しているような体験ができます。

## 特徴
- GPT-4を活用したナチュラルな会話
- リアルタイムな音声認識と応答
- キャラクターの表情やリップシンクによる自然な演出
- 日本語でのコミュニケーション
- プライバシーとデータセキュリティを重視した設計

## システム構成
### フロントエンド (iOS)
- SwiftUIを使用したモダンなUIの実装
- MVVMアーキテクチャに基づいた設計
- 再利用可能なコンポーネント設計
- 非同期通信（async/await）による効率的なAPI連携
- エラーハンドリングの徹底

### バックエンド
- FastAPIによる高速なRESTful API
- WebSocketを活用したリアルタイム通信
- 効率的なAPIルーティングと処理

## 技術スタック
### フロントエンド
- SwiftUI: モダンなUIフレームワーク
- Combine: 非同期データストリーム処理
- WebSocket: リアルタイム通信

### バックエンド
- FastAPI: 高性能なPythonウェブフレームワーク
- OpenAI GPT-4: 自然言語処理
- Azure Speech Services: 音声認識
- Zonos API: 音声合成

## プロジェクト構成
```
.
├── iOS/           # iOSアプリケーション
│   ├── Models     # データモデル
│   ├── Views      # UI実装
│   ├── ViewModels # ビジネスロジック
│   ├── Services   # APIサービス
│   └── Resources  # リソースファイル
│
└── backend/       # バックエンドサーバー
```

## 開発環境のセットアップ
1. リポジトリのクローン
```bash
git clone https://github.com/tetsuro-dev/ai-companion.git
```

2. 必要な環境変数の設定
以下の環境変数を`.env`ファイルに設定してください：
```
OPENAI_API_KEY=your_openai_api_key
AZURE_SPEECH_KEY=your_azure_speech_key
ZONOS_API_KEY=your_zonos_api_key
```

3. iOSアプリの開発
- Xcode 14.0以上が必要です
- プロジェクトを開く: `iOS/AI-Companion.xcodeproj`
- 必要なパッケージの自動インストールが行われます

4. バックエンドの開発
- Python 3.8以上が必要です
- 依存パッケージのインストール:
```bash
cd backend
pip install -r requirements.txt
```

## 開発ガイドライン
- SwiftUIのベストプラクティスに従う
- MVVMアーキテクチャを維持
- コンポーネントの再利用性を重視
- 適切なエラーハンドリングの実装
- async/awaitを使用した非同期通信
- ユーザープライバシーとデータセキュリティの考慮

## ライセンス
MIT License

## 作者
@tetsuro-dev
