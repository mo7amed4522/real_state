import openai # type: ignore
from django.conf import settings # type: ignore

def moderate_message_with_openai(content):
    openai.api_key = getattr(settings, 'OPENAI_API_KEY', None)
    if not openai.api_key:
        return False, {}
    response = openai.Moderation.create(input=content)
    flagged = response['results'][0]['flagged']
    categories = response['results'][0]['categories']
    return flagged, categories 