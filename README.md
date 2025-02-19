# AI Companion

かわいい動物キャラクターとAIを使って会話ができるiOSアプリです。
自然な対話とリアルタイムなリップシンクで、まるで本物のペットと話しているような体験ができます。

## 特徴
- GPT-4を活用したナチュラルな会話
- リアルタイムな音声認識と応答
- キャラクターの表情やリップシンクによる自然な演出
- 日本語でのコミュニケーション

## 技術スタック
- Frontend: SwiftUI
- Backend: FastAPI
- AI: OpenAI GPT-4
- 音声認識: Azure Speech Services
- 音声合成: Zonos API

## 開発環境のセットアップ
1. リポジトリのクローン
    ```
    git clone https://github.com/tetsuro-dev/ai-companion.git
    ```

2. 必要な環境変数の設定
    詳細な設定方法は[環境変数のドキュメント](backend/docs/env_vars.md)を参照してください。
    - OPENAI_API_KEY (OpenAI GPT-4 APIキー)
    - AZURE_SPEECH_KEY (Azure Speech Servicesキー)
    - ZONOS_API_KEY (Zonos Text-to-Speech APIキー)

3. Xcodeでプロジェクトを開く

## ライセンス
MIT License

## 作者
@tetsuro-dev
