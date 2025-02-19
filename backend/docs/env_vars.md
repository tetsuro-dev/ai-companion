# 環境変数の設定

本アプリケーションを実行するには、以下の環境変数の設定が必要です。

## 必須の環境変数

### OPENAI_API_KEY
- 説明: OpenAI GPT-4 APIのアクセスキー
- 形式: `sk-` で始まる48文字の英数字
- 取得方法: [OpenAI Dashboard](https://platform.openai.com/account/api-keys)から取得

### AZURE_SPEECH_KEY
- 説明: Azure Speech ServicesのAPIキー
- 形式: 32文字の16進数
- リージョン: japaneast
- 取得方法: [Azure Portal](https://portal.azure.com/)のSpeech Servicesから取得

### ZONOS_API_KEY
- 説明: Zonos Text-to-Speech APIのアクセスキー
- 形式: `z_` で始まる32文字の英数字
- 取得方法: [Zonos Dashboard](https://dashboard.zonos.ai/)から取得

## 設定方法

1. `.env.example`ファイルを`.env`にコピー
```bash
cp .env.example .env
```

2. `.env`ファイルに各APIキーを設定
```env
OPENAI_API_KEY=your_openai_api_key_here
AZURE_SPEECH_KEY=your_azure_speech_key_here
ZONOS_API_KEY=your_zonos_api_key_here
```

## 注意事項
- APIキーは機密情報です。`.env`ファイルはGitにコミットしないでください
- 各APIキーの形式が正しくない場合、アプリケーション起動時にエラーが表示されます
- 環境変数が設定されていない場合、アプリケーションは起動しません
