import re
from typing import Dict, List, Optional

from pydantic import BaseModel, Field, field_validator


class EnvVarError(Exception):
    def __init__(self, missing: List[str], invalid: Dict[str, str]):
        self.missing = missing
        self.invalid = invalid

    def __str__(self) -> str:
        errors = []
        if self.missing:
            errors.append(f"必須の環境変数が設定されていません: {', '.join(self.missing)}")
        for var, reason in self.invalid.items():
            errors.append(f"{var}: {reason}")
        return "\n".join(errors)


class EnvironmentVariables(BaseModel):
    openai_api_key: str = Field(..., description="OpenAI APIキー")
    azure_speech_key: str = Field(..., description="Azure Speech Servicesキー")
    zonos_api_key: str = Field(..., description="Zonos APIキー")

    @field_validator("openai_api_key")
    @classmethod
    def validate_openai_key(cls, v: str) -> str:
        if not re.match(r"^sk-[A-Za-z0-9]{48}$", v):
            raise ValueError("OpenAI APIキーの形式が正しくありません")
        return v

    @field_validator("azure_speech_key")
    @classmethod
    def validate_azure_key(cls, v: str) -> str:
        if not re.match(r"^[A-Fa-f0-9]{32}$", v):
            raise ValueError("Azure Speech Servicesキーの形式が正しくありません")
        return v

    @field_validator("zonos_api_key")
    @classmethod
    def validate_zonos_key(cls, v: str) -> str:
        if not re.match(r"^z_[A-Za-z0-9]{32}$", v):
            raise ValueError("Zonos APIキーの形式が正しくありません")
        return v

    def validate_all(self) -> Optional[EnvVarError]:
        """全ての環境変数を検証します。"""
        missing = []
        invalid = {}

        # Check for missing variables
        for field_name in self.model_fields:
            value = getattr(self, field_name)
            if not value:
                missing.append(field_name)
                continue

            # Validate format using field validators
            try:
                # Use the field validator directly
                if field_name == "openai_api_key":
                    self.validate_openai_key(value)
                elif field_name == "azure_speech_key":
                    self.validate_azure_key(value)
                elif field_name == "zonos_api_key":
                    self.validate_zonos_key(value)
            except ValueError as e:
                invalid[field_name] = str(e)

        if missing or invalid:
            return EnvVarError(missing, invalid)
        return None
