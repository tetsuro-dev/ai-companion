import pytest
from pydantic import ValidationError

from app.core.validation import EnvironmentVariables, EnvVarError


def test_valid_env_vars():
    """有効な環境変数の検証テスト"""
    env_vars = EnvironmentVariables(
        openai_api_key="sk-" + "a" * 48,
        azure_speech_key="a" * 32,
        zonos_api_key="z_" + "a" * 32
    )
    assert env_vars.validate_all() is None


def test_missing_env_vars():
    """環境変数が未設定の場合のテスト"""
    with pytest.raises(ValidationError) as exc_info:
        EnvironmentVariables()

    error = str(exc_info.value)
    assert "Field required" in error


def test_invalid_openai_key():
    """無効なOpenAI APIキーの検証テスト"""
    with pytest.raises(ValidationError) as exc_info:
        EnvironmentVariables(
            openai_api_key="invalid-key",
            azure_speech_key="a" * 32,
            zonos_api_key="z_" + "a" * 32
        )

    error = str(exc_info.value)
    assert "OpenAI APIキーの形式が正しくありません" in error


def test_invalid_azure_key():
    """無効なAzure Speech Servicesキーの検証テスト"""
    with pytest.raises(ValidationError) as exc_info:
        EnvironmentVariables(
            openai_api_key="sk-" + "a" * 48,
            azure_speech_key="invalid-key",
            zonos_api_key="z_" + "a" * 32
        )

    error = str(exc_info.value)
    assert "Azure Speech Servicesキーの形式が正しくありません" in error


def test_invalid_zonos_key():
    """無効なZonos APIキーの検証テスト"""
    with pytest.raises(ValidationError) as exc_info:
        EnvironmentVariables(
            openai_api_key="sk-" + "a" * 48,
            azure_speech_key="a" * 32,
            zonos_api_key="invalid-key"
        )

    error = str(exc_info.value)
    assert "Zonos APIキーの形式が正しくありません" in error


def test_env_var_error_message():
    """環境変数エラーメッセージのテスト"""
    error = EnvVarError(
        missing=["openai_api_key"],
        invalid={"azure_speech_key": "形式が正しくありません"}
    )
    error_msg = str(error)
    assert "必須の環境変数が設定されていません: openai_api_key" in error_msg
    assert "azure_speech_key: 形式が正しくありません" in error_msg
