import json
from channels.generic.websocket import AsyncWebsocketConsumer # type: ignore
from channels.db import database_sync_to_async # type: ignore
from django.contrib.auth import get_user_model # type: ignore
from .serializers import MessageSerializer

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        if data.get('type') == 'read':
            await self.mark_message_read(data['message_id'])
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'read_receipt',
                    'message_id': data['message_id'],
                    'reader_id': self.scope['user'].id,
                }
            )
            return
        sender_id = data.get('sender_id')
        content = data.get('content')
        if sender_id and content:
            message = await self.save_message(sender_id, content)
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': MessageSerializer(message).data
                }
            )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event['message']))

    async def read_receipt(self, event):
        await self.send(text_data=json.dumps({
            'type': 'read',
            'message_id': event['message_id'],
            'reader_id': event['reader_id'],
        }))

    @database_sync_to_async
    def save_message(self, sender_id, content):
        from .models import ChatRoom, Message
        sender = User.objects.get(id=sender_id)
        room = ChatRoom.objects.get(id=self.room_id)
        message = Message.objects.create(chat_room=room, sender=sender, content=content)
        room.last_message_at = message.created_at
        room.save()
        return message

    @database_sync_to_async
    def mark_message_read(self, message_id):
        from .models import Message
        msg = Message.objects.get(id=message_id)
        msg.is_read = True
        msg.save() 