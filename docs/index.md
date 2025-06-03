# FlashPass External API Documentation

## Overview

The FlashPass External API provides secure access to menu and user management features for authorized third-party applications. This API uses a dual-key authentication system to ensure security while maintaining ease of integration.

## Authentication

### API Key Types

FlashPass uses two types of API keys:

- **Public Keys** (`pk_*`): For client-side applications (mobile apps, frontend)
- **Secret Keys** (`sk_*`): For server-side applications (must never be exposed)

### Authentication Methods

#### 1. API Key Authentication (Secret Keys Only)

For server-side requests, include your secret key in the request header:

```
X-Api-Key: sk_your_secret_key_here
```

#### 2. Bearer Token Authentication

After authenticating a user, include their JWT token:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 3. Dual Authentication

Some endpoints require both API key and Bearer token for enhanced security.

## Available Endpoints

### 1. Trusted Login

Authenticate users without passwords using your secret key.

**Endpoint:** `POST https://apiv2.flashpass.com.ar/public/auth/trusted-login`

**Headers:**
- `X-Api-Key: sk_your_secret_key` (required)
- `Content-Type: application/json`

**Request Body:**
```json
{
  "email": "user@example.com",
  "user_name": "John",           // Optional - updates if null
  "user_surname": "Doe",         // Optional - updates if null
  "id_type": "DNI",              // Optional - defaults to "DNI"
  "user_dni": "12345678",        // Optional - updates if null
  "user_tel": 1234567890,        // Optional - updates if null
  "birth_date": "1990-01-01",    // Optional - updates if null
  "genero": "M",                 // Optional - updates if null
  "user_province": 1             // Optional - updates if null
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "auth_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "user_id": 123,
      "email": "user@example.com",
      "user_name": "John",
      "user_surname": "Doe",
      "confirmed": 1,
      "register_method": "flashpass"
    },
    "expires_at": "2024-01-20T12:30:00.000Z"
  }
}
```

**Notes:**
- Creates new users automatically if they don't exist
- Updates user profile fields only if they are currently null
- Users created via trusted login are automatically confirmed
- Token expires in 15 minutes

### 2. Get Menu Login URL

Generate a login URL for users to access a specific menu.

**Endpoint:** `GET https://apiv2.flashpass.com.ar/public/menus/login-url`

**Headers:**
- `Authorization: Bearer {user_token}` (required)

**Query Parameters:**
- `menu_id` (required): The menu ID to access

**Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://app.flashpass.com.ar/google_auth?jwt=eyJ..."
  }
}
```

**Notes:**
- Only works for menus belonging to producer 628
- Validates menu access through `availableMenus` in JWT token

### 3. Check Credit Line

Check a user's available credit for a specific menu.

**Endpoint:** `GET https://apiv2.flashpass.com.ar/public/menus/credit-lines/check`

**Headers:**
- `Authorization: Bearer {user_token}` (required)

**Query Parameters:**
- `menu_id` (required): The menu ID
- `event_id` (optional): Specific event ID (auto-detected if not provided)

**Response:**
```json
{
  "success": true,
  "data": {
    "has_credit_line": true,
    "credit_limit": 5000.00,
    "available_credit": 3500.00,
    "used_credit": 1500.00,
    "is_active": true,
    "menu_id": 56,
    "event_id": 789,
    "created_at": "2024-01-15T10:00:00.000Z"
  }
}
```

### 4. Request Credit

Request credit usage up to the available limit.

**Endpoint:** `POST https://apiv2.flashpass.com.ar/public/menus/credit-lines/request`

**Headers:**
- `Authorization: Bearer {user_token}` (required)
- `Content-Type: application/json`

**Request Body:**
```json
{
  "menu_id": 56,
  "event_id": 789,              // Optional - auto-detected if not provided
  "amount": 500.00,
  "description": "Lunch order"  // Optional
}
```

**Response:**
```json
{
  "success": true,
  "transaction_id": 12345,
  "new_balance": 3000.00,
  "remaining_credit": 2000.00
}
```

### 5. Add User to Credit Line (Dual Auth)

Add a user to a credit line with a specified limit.

**Endpoint:** `POST https://apiv2.flashpass.com.ar/public/menus/credit-lines/users`

**Headers:**
- `X-Api-Key: sk_your_secret_key` (required)
- `Authorization: Bearer {user_token}` (required)
- `Content-Type: application/json`

**Request Body:**
```json
{
  "menu_id": 56,
  "event_id": 789,              // Optional - auto-detected if not provided
  "credit_limit": 5000.00,
  "notes": "VIP customer"       // Optional
}
```

**Response:**
```json
{
  "success": true,
  "credit_line_id": 456,
  "user_id": 123,
  "message": "Credit line created successfully"
}
```

### 6. Remove User from Credit Line (Dual Auth)

Deactivate a user's credit line.

**Endpoint:** `DELETE https://apiv2.flashpass.com.ar/public/menus/credit-lines/users`

**Headers:**
- `X-Api-Key: sk_your_secret_key` (required)
- `Authorization: Bearer {user_token}` (required)
- `Content-Type: application/json`

**Request Body:**
```json
{
  "menu_id": 56,
  "event_id": 789  // Optional - auto-detected if not provided
}
```

**Response:**
```json
{
  "success": true,
  "user_id": 123,
  "message": "Credit line deactivated successfully"
}
```

## Error Responses

All endpoints use a consistent error format:

```json
{
  "error": "Forbidden",
  "message": "This operation is restricted to producer 628"
}
```

Common HTTP status codes:
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (missing or invalid authentication)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `429` - Too Many Requests (rate limit exceeded)
- `500` - Internal Server Error

## Rate Limits

- Secret Key endpoints: 1000 requests per hour
- Public Key endpoints: 500 requests per hour
- Bearer Token endpoints: Based on user's rate limit

## Important Notes

1. **Producer Restriction**: All endpoints are restricted to producer ID 628
2. **Event Auto-detection**: If no event_id is provided, the system automatically detects the active event
3. **Credit System**: Credit transactions use payment method "pending_checking_account"
4. **Token Structure**: External app tokens have `userId: null` and store the user ID in `customerId`
5. **Available Menus**: Caramelo App users are restricted to menu_id 56 by default

## Example Integration

### Node.js Example

```javascript
const axios = require('axios');

// Configuration
const API_BASE_URL = 'https://apiv2.flashpass.com.ar';
const SECRET_KEY = 'sk_your_secret_key_here';

// 1. Authenticate user
async function authenticateUser(email, userData = {}) {
  try {
    const response = await axios.post(
      `${API_BASE_URL}/public/auth/trusted-login`,
      { email, ...userData },
      { headers: { 'X-Api-Key': SECRET_KEY } }
    );
    
    return response.data.data.auth_token;
  } catch (error) {
    console.error('Authentication failed:', error.response?.data);
    throw error;
  }
}

// 2. Check credit line
async function checkCreditLine(token, menuId) {
  try {
    const response = await axios.get(
      `${API_BASE_URL}/public/menus/credit-lines/check`,
      {
        params: { menu_id: menuId },
        headers: { 'Authorization': `Bearer ${token}` }
      }
    );
    
    return response.data.data;
  } catch (error) {
    console.error('Credit check failed:', error.response?.data);
    throw error;
  }
}

// 3. Request credit
async function requestCredit(token, menuId, amount, description) {
  try {
    const response = await axios.post(
      `${API_BASE_URL}/public/menus/credit-lines/request`,
      { menu_id: menuId, amount, description },
      { headers: { 'Authorization': `Bearer ${token}` } }
    );
    
    return response.data;
  } catch (error) {
    console.error('Credit request failed:', error.response?.data);
    throw error;
  }
}

// Usage example
async function main() {
  try {
    // Authenticate user
    const token = await authenticateUser('user@example.com', {
      user_name: 'John',
      user_surname: 'Doe'
    });
    
    // Check credit
    const creditInfo = await checkCreditLine(token, 56);
    console.log('Available credit:', creditInfo.available_credit);
    
    // Request credit if available
    if (creditInfo.available_credit >= 100) {
      const result = await requestCredit(token, 56, 100, 'Coffee order');
      console.log('Transaction ID:', result.transaction_id);
    }
  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();
```

## Support

For API support or to request credentials, contact: support@flashpass.com.ar