from functools import lru_cache
import logging

from pydantic_settings import BaseSettings

from .validation import EnvironmentVariables, EnvVarError

logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    openai_api_key: str
    azure_speech_key: str
    zonos_api_key: str

    class Config:
        env_file = ".env"

    def validate_environment(self):
        """環境変数の検証を行います。"""
        env_vars = EnvironmentVariables(
            openai_api_key=self.openai_api_key,
            azure_speech_key=self.azure_speech_key,
            zonos_api_key=self.zonos_api_key
        )
        if error := env_vars.validate_all():
            logger.error("環境変数の検証に失敗しました: %s", str(error))
            raise error
        logger.info("環境変数の検証が完了しました")


@lru_cache()
def get_settings():
    settings = Settings()
    settings.validate_environment()
    return settings
