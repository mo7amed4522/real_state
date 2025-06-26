from rest_framework import generics, permissions, status # type: ignore
from rest_framework.response import Response # type: ignore
from rest_framework.views import APIView # type: ignore
from .models import ChatRoom, Message
from .serializers import ChatRoomSerializer, MessageSerializer
from django.shortcuts import get_object_or_404 # type: ignore
from django.db import models # type: ignore
from .utils import moderate_message_with_openai

class ChatRoomCreateView(generics.CreateAPIView):
    queryset = ChatRoom.objects.all()
    serializer_class = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save()

class ChatRoomDeleteView(generics.DestroyAPIView):
    queryset = ChatRoom.objects.all()
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'pk'

class ChatRoomMuteView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, room_id):
        mute = request.data.get('mute', True)
        room = get_object_or_404(ChatRoom, id=room_id)
        if mute:
            room.muted_by.add(request.user)
        else:
            room.muted_by.remove(request.user)
        return Response({'muted': mute}, status=status.HTTP_200_OK)

class ChatRoomRemoveUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, room_id):
        user_id = request.data.get('user_id')
        room = get_object_or_404(ChatRoom, id=room_id)
        # Only allow the seller or admin to remove users
        if request.user != room.seller and not request.user.is_staff:
            return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)
        # Remove user from room (custom logic, e.g., set buyer/seller to None)
        if str(room.buyer_id) == str(user_id):
            room.buyer = None
        elif str(room.seller_id) == str(user_id):
            room.seller = None
        else:
            return Response({'detail': 'User not in room.'}, status=status.HTTP_400_BAD_REQUEST)
        room.save()
        return Response({'removed': user_id}, status=status.HTTP_200_OK)

class ChatRoomListView(generics.ListAPIView):
    serializer_class = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return ChatRoom.objects.filter(models.Q(buyer=user) | models.Q(seller=user)).order_by('-last_message_at')

class MessageListView(generics.ListAPIView):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        room_id = self.kwargs['room_id']
        return Message.objects.filter(chat_room_id=room_id).order_by('created_at')

class SendMessageView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = MessageSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        content = serializer.validated_data['content']
        flagged, categories = moderate_message_with_openai(content)
        message = serializer.save(sender=request.user, is_flagged=flagged)
        return Response({
            **MessageSerializer(message).data,
            'moderation': {'flagged': flagged, 'categories': categories}
        }, status=status.HTTP_201_CREATED)

class MarkMessagesReadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, room_id):
        room = get_object_or_404(ChatRoom, id=room_id)
        Message.objects.filter(chat_room=room, is_read=False).exclude(sender=request.user).update(is_read=True)
        return Response({'status': 'all messages marked as read'}, status=status.HTTP_200_OK)

class MarkMessageReadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, message_id):
        message = get_object_or_404(Message, id=message_id)
        if message.sender == request.user:
            return Response({'detail': 'Cannot mark your own message as read.'}, status=status.HTTP_400_BAD_REQUEST)
        message.is_read = True
        message.save()
        return Response({'status': 'message marked as read'}, status=status.HTTP_200_OK)

class AIModerateMessageView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, message_id):
        message = get_object_or_404(Message, id=message_id)
        # Here you would call your AI moderation API/service
        # For now, we'll just flag the message
        message.is_flagged = True
        message.save()
        return Response({'status': 'message flagged for moderation'}, status=status.HTTP_200_OK) 