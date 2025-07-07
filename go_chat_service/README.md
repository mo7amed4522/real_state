# Go Chat Service

A real-time chat microservice built with Go, Gin, and WebSockets that integrates with your existing PostgreSQL database and NestJS user system.

## Features

- **Real-time Chat**: WebSocket-based real-time messaging
- **User Management**: Integration with existing user system (buyer, developer, broker, admin)
- **Conversation Management**: Create and manage conversations between users
- **Message History**: Persistent message storage with read status
- **RESTful API**: Complete REST API for chat operations
- **Database Integration**: Uses existing PostgreSQL database with your user schema

## Database Schema

The service creates the following tables in your existing database:

### Conversations
- `id` (UUID, Primary Key)
- `participant1_id` (UUID, Foreign Key to users.id)
- `participant2_id` (UUID, Foreign Key to users.id)
- `last_message_id` (UUID, Foreign Key to messages.id)
- `created_at`, `updated_at`

### Messages
- `id` (UUID, Primary Key)
- `conversation_id` (UUID, Foreign Key to conversations.id)
- `sender_id` (UUID, Foreign Key to users.id)
- `content` (Text)
- `message_type` (Enum: text, image, file)
- `is_read` (Boolean)
- `created_at`, `updated_at`

## API Endpoints

### Chat Endpoints

#### Get User Conversations
```
GET /api/v1/chat/conversations/:user_id
```

#### Get Conversation Messages
```
GET /api/v1/chat/conversations/:conversation_id/messages?limit=50&offset=0
```

#### Create Conversation
```
POST /api/v1/chat/conversations
{
  "user1Id": "uuid",
  "user2Id": "uuid"
}
```

#### Send Message
```
POST /api/v1/chat/messages
{
  "conversationId": "uuid",
  "senderId": "uuid",
  "content": "Hello!",
  "messageType": "text"
}
```

#### Mark Conversation as Read
```
PUT /api/v1/chat/conversations/:conversation_id/read?user_id=uuid
```

#### Get Unread Message Count
```
GET /api/v1/chat/users/:user_id/unread-count
```

### User Endpoints

#### Get All Users
```
GET /api/v1/users/
```

#### Get Active Users
```
GET /api/v1/users/active
```

#### Get User by ID
```
GET /api/v1/users/:user_id
```

#### Get Users by Role
```
GET /api/v1/users/role/:role
```
Roles: `buyer`, `developer`, `broker`, `admin`

### WebSocket Endpoint

#### Connect to WebSocket
```
GET /ws?user_id=uuid
```

WebSocket Message Format:
```json
{
  "type": "chat_message",
  "data": {
    "id": "uuid",
    "conversationId": "uuid",
    "senderId": "uuid",
    "content": "Hello!",
    "messageType": "text",
    "isRead": false,
    "createdAt": "2024-01-01T00:00:00Z",
    "sender": {
      "id": "uuid",
      "firstName": "John",
      "lastName": "Doe",
      "avatarUrl": "https://example.com/avatar.jpg"
    }
  },
  "userId": "uuid",
  "timestamp": 1704067200
}
```

## Environment Variables

Create a `config.env` file:

```env
DB_HOST=localhost
DB_PORT=5420
DB_USER=postgres
DB_PASSWORD=2521
DB_NAME=real-state
DB_SSL_MODE=disable

SERVER_PORT=8081
LOG_LEVEL=info
```

## Running the Service

### Local Development

1. Install Go 1.21+
2. Install dependencies:
   ```bash
   go mod tidy
   ```
3. Run the service:
   ```bash
   go run main.go
   ```

### Docker

1. Build and run with Docker Compose:
   ```bash
   docker-compose up go_chat_service
   ```

2. Or build individually:
   ```bash
   docker build -t go-chat-service .
   docker run -p 8081:8081 go-chat-service
   ```

## Integration with Existing Services

This service integrates with your existing microservices:

- **NestJS Service**: Uses the same PostgreSQL database and user schema
- **Database**: Connects to the same PostgreSQL instance (port 5420)
- **User System**: Leverages existing users table with roles (buyer, developer, broker, admin)

## Example Usage

### Creating a Chat Between Users

1. Get all users:
   ```bash
   curl http://localhost:8081/api/v1/users/
   ```

2. Create a conversation:
   ```bash
   curl -X POST http://localhost:8081/api/v1/chat/conversations \
     -H "Content-Type: application/json" \
     -d '{
       "user1Id": "user-uuid-1",
       "user2Id": "user-uuid-2"
     }'
   ```

3. Send a message:
   ```bash
   curl -X POST http://localhost:8081/api/v1/chat/messages \
     -H "Content-Type: application/json" \
     -d '{
       "conversationId": "conversation-uuid",
       "senderId": "user-uuid-1",
       "content": "Hello! How are you?",
       "messageType": "text"
     }'
   ```

4. Connect to WebSocket for real-time chat:
   ```javascript
   const ws = new WebSocket('ws://localhost:8081/ws?user_id=your-user-uuid');
   
   ws.onmessage = function(event) {
     const message = JSON.parse(event.data);
     console.log('New message:', message);
   };
   ```

## Health Check

```
GET /health
```

Returns:
```json
{
  "status": "ok",
  "service": "go-chat-service"
}
``` 