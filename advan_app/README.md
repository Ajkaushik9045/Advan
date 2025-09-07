# Request Handling Workflow Prototype

A Flutter mobile application that simulates a real-world request and confirmation workflow with two distinct user roles: End User and Receiver.

## 🎯 Features

### End User Features

- **Create Requests**: Select multiple items and submit requests
- **View Request Status**: Track requests with real-time status updates
- **Request Statuses**:
  - `Pending` → Request submitted, awaiting receiver review
  - `Confirmed` → All items confirmed by the receiver
  - `Partially Fulfilled` → Some items confirmed, others reassigned

### Receiver Features

- **View Assigned Requests**: See all requests assigned to them
- **Item-by-Item Confirmation**: Review and confirm availability of items individually
- **Status Management**:
  - Mark items as Available/Not Available
  - Automatic status updates based on confirmation results
  - Partial fulfillment handling with item reassignment

### System Features

- **Real-time Updates**: WebSocket connection with polling fallback
- **Role-based Authentication**: Simple login system for different user types
- **Error Handling**: Comprehensive error handling for network issues
- **Professional UI**: Clean, minimal interface focused on usability

## 🏗️ Architecture

### Project Structure

```
lib/
├── config/
│   └── app_router.dart          # Navigation routing
├── core/
│   ├── network/
│   │   └── api_client.dart      # HTTP client configuration
│   ├── utils/
│   │   ├── enums.dart           # Application enums
│   │   ├── error_handler.dart   # Error handling utilities
│   │   └── date_formatter.dart  # Date formatting utilities
│   └── widgets/
│       ├── loading_widget.dart  # Loading indicators
│       ├── error_widget.dart    # Error display widgets
│       └── status_chip.dart     # Status display components
└── features/
    ├── auth/
    │   ├── models/              # User models
    │   ├── pages/
    │   │   └── login_page.dart  # Authentication UI
    │   └── provider/
    │       └── auth_provider.dart # Authentication state management
    ├── user/
    │   ├── models/              # User-specific models
    │   ├── pages/
    │   │   └── user_home_page.dart # End user dashboard
    │   └── services/
    │       └── user_service.dart # User API services
    ├── receiver/
    │   ├── models/              # Receiver-specific models
    │   ├── pages/
    │   │   └── receiver_home_page.dart # Receiver dashboard
    │   └── services/            # Receiver API services
    └── requests/
        ├── models/
        │   ├── request_model.dart    # Request data model
        │   └── item_model.dart       # Item data model
        ├── pages/
        │   ├── create_request_page.dart           # Request creation UI
        │   ├── request_details_page.dart          # Request details view
        │   └── receiver_request_details_page.dart # Receiver confirmation UI
        ├── provider/
        │   └── request_provider.dart # Request state management
        └── services/
            └── request_service.dart  # Request API services
```

### State Management

- **Provider Pattern**: Used for state management across the application
- **Separation of Concerns**: Each feature has its own provider and services
- **Real-time Updates**: WebSocket connection with automatic fallback to polling

### Data Models

- **Request**: Contains user info, items, status, and timestamps
- **Item**: Individual items with confirmation status
- **User**: User information and role management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Backend server running (Node.js/Express)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd advan_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment**

   ```bash
   cp .env.example .env
   ```

   Update `.env` with your backend configuration:

   ```env
   # For Android Emulator
   API_BASE_URL=http://10.0.2.2:3000
   WS_URL=ws://10.0.2.2:3000

   # For iOS Simulator
   API_BASE_URL=http://localhost:3000
   WS_URL=ws://localhost:3000

   # For Physical Device (replace with your computer's IP)
   API_BASE_URL=http://192.168.1.100:3000
   WS_URL=ws://192.168.1.100:3000
   ```

4. **Generate JSON serialization code**

   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Usage

### End User Workflow

1. **Login**: Select "Login as End User"
2. **Create Request**: Tap the "+" button to create a new request
3. **Select Items**: Choose items from available catalog
4. **Submit**: Submit the request for review
5. **Track Progress**: View request status and progress in real-time

### Receiver Workflow

1. **Login**: Select "Login as Receiver"
2. **View Requests**: See all assigned requests
3. **Review Request**: Tap on a request to view details
4. **Confirm Items**: Mark each item as Available or Not Available
5. **Save Changes**: Submit confirmation results

## 🔌 API Endpoints

The app expects the following backend endpoints:

### Requests

- `GET /requests` - Fetch requests (with optional userId/receiverId filters)
- `POST /requests` - Create new request
- `PATCH /requests/:id` - Update request status
- `PATCH /requests/:id/confirm` - Confirm items in a request

### Items

- `GET /items` - Fetch available items catalog

### Authentication

- `POST /auth/login` - User authentication
- `GET /auth/me` - Get current user info

## 🛠️ Technical Details

### Dependencies

- **flutter**: SDK
- **provider**: State management
- **dio**: HTTP client
- **web_socket_channel**: Real-time communication
- **shared_preferences**: Local storage
- **json_annotation**: JSON serialization
- **flutter_spinkit**: Loading animations
- **intl**: Internationalization
- **dotenv**: Environment configuration

### Real-time Updates

- **Primary**: WebSocket connection for instant updates
- **Fallback**: Polling every 8 seconds if WebSocket fails
- **Automatic Reconnection**: Handles connection drops gracefully

### Error Handling

- **Network Errors**: Automatic retry mechanisms
- **User Feedback**: Clear error messages and loading states
- **Graceful Degradation**: App continues to function with limited features

## 🎨 UI/UX Features

### Design Principles

- **Minimalist**: Clean, uncluttered interface
- **Professional**: Business-appropriate styling
- **Accessible**: Clear typography and contrast
- **Responsive**: Adapts to different screen sizes

### Key Components

- **Status Chips**: Color-coded status indicators
- **Progress Bars**: Visual progress tracking
- **Loading States**: Smooth loading animations
- **Error States**: Clear error messaging
- **Empty States**: Helpful guidance when no data

## 🧪 Testing

### Manual Testing

1. **End User Flow**: Create request → Track status → View details
2. **Receiver Flow**: View requests → Confirm items → Submit changes
3. **Real-time Updates**: Test WebSocket and polling fallback
4. **Error Handling**: Test network failures and edge cases

### Test Scenarios

- [ ] Create request with multiple items
- [ ] Confirm all items (status → Confirmed)
- [ ] Confirm some items (status → Partially Fulfilled)
- [ ] Real-time status updates
- [ ] Network error handling
- [ ] Role-based navigation

## 📋 Future Enhancements

- [ ] Push notifications for status updates
- [ ] Offline support with local caching
- [ ] Advanced filtering and search
- [ ] Request history and analytics
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Biometric authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support or questions, please contact the development team or create an issue in the repository.

---

**Note**: This is a prototype application for demonstration purposes. In a production environment, additional security measures, data validation, and performance optimizations would be implemented.
