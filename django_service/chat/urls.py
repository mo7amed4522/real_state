from django.urls import path # type: ignore
from . import views

urlpatterns = [
    path('rooms/', views.ChatRoomCreateView.as_view(), name='chatroom-create'),
    path('rooms/<uuid:pk>/', views.ChatRoomDeleteView.as_view(), name='chatroom-delete'),
    path('rooms/<uuid:room_id>/mute/', views.ChatRoomMuteView.as_view(), name='chatroom-mute'),
    path('rooms/<uuid:room_id>/remove/', views.ChatRoomRemoveUserView.as_view(), name='chatroom-remove-user'),
    path('rooms/list/', views.ChatRoomListView.as_view(), name='chatroom-list'),
    path('room/<uuid:room_id>/messages/', views.MessageListView.as_view(), name='chatroom-messages'),
    path('send/', views.SendMessageView.as_view(), name='chat-send'),
    path('room/<uuid:room_id>/mark-read/', views.MarkMessagesReadView.as_view(), name='chat-mark-read'),
    path('message/<uuid:message_id>/mark-read/', views.MarkMessageReadView.as_view(), name='chat-message-mark-read'),
    path('message/<uuid:message_id>/moderate/', views.AIModerateMessageView.as_view(), name='chat-message-moderate'),
] 