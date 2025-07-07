# Troubleshooting Guide

## Foreign Key Constraint Error

If you encounter this error:
```
ERROR: insert or update on table "conversations" violates foreign key constraint "fk_conversations_participant2" (SQLSTATE 23503)
```

This means you're trying to create a conversation between users that don't exist in the database.

### Solution

1. **Check if the chat service is running:**
   ```bash
   curl http://localhost:8080/health
   ```

2. **Create the missing users first:**
   ```bash
   # Create user1
   curl -X POST http://localhost:8080/api/v1/users/ \
     -H "Content-Type: application/json" \
     -d '{
       "id": "50b46bfd-de84-4289-bf64-4606cbcd204d",
       "email": "user1@example.com",
       "password": "password123",
       "firstName": "John",
       "lastName": "Doe",
       "countryCode": "+1",
       "phoneNumber": "1234567890",
       "role": "buyer",
       "status": "active"
     }'

   # Create user2
   curl -X POST http://localhost:8080/api/v1/users/ \
     -H "Content-Type: application/json" \
     -d '{
       "id": "4146072f-d75a-4ec9-baf1-a4b86577f470",
       "email": "user2@example.com",
       "password": "password123",
       "firstName": "Jane",
       "lastName": "Smith",
       "countryCode": "+1",
       "phoneNumber": "0987654321",
       "role": "developer",
       "status": "active"
     }'
   ```

3. **Verify users were created:**
   ```bash
   curl http://localhost:8080/api/v1/users/
   ```

4. **Now create the conversation:**
   ```bash
   curl -X POST http://localhost:8080/api/v1/chat/conversations \
     -H "Content-Type: application/json" \
     -d '{
       "user1Id": "50b46bfd-de84-4289-bf64-4606cbcd204d",
       "user2Id": "4146072f-d75a-4ec9-baf1-a4b86577f470"
     }'
   ```

### Alternative: Use the test script

You can also use the provided test script:
```bash
# If you have the httpie tool installed
httpie < test_conversation.http

# Or use the Go script
go run scripts/check_users.go
```

### Database Schema

The conversation table has these foreign key constraints:
- `fk_conversations_participant1` → references `users(id)`
- `fk_conversations_participant2` → references `users(id)`

Both user IDs must exist in the `users` table before creating a conversation.

### Prevention

To prevent this issue in the future:
1. Always verify that users exist before creating conversations
2. Use the user creation endpoint to create test users
3. Consider adding validation in your application logic to check user existence 