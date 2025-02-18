from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    openai_api_key: str
    azure_speech_key: str
    zonos_api_key: str

    class Config:
        env_file = ".env"

@lru_cache()
def get_settings():
    return Settings()
