# Demo Instructions

## Quick Start Demo

### 1. Backend Setup

Make sure your backend server is running on the configured port (default: 3000).

### 2. Flutter App Setup

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code
flutter packages pub run build_runner build

# Run the app
flutter run
```

### 3. Demo Flow

#### Step 1: End User Creates Request

1. **Login as End User**

   - Tap "Login as End User" on the login screen
   - You'll be redirected to the user dashboard

2. **Create New Request**

   - Tap the "+" floating action button
   - Select items from the available catalog
   - Adjust quantities as needed
   - Tap "Submit" to create the request

3. **View Request Status**
   - Return to the dashboard to see your request
   - Status should show "Pending"
   - Tap on the request to view details

#### Step 2: Receiver Reviews Request

1. **Login as Receiver**

   - Go back to login screen
   - Tap "Login as Receiver"
   - You'll see the assigned request

2. **Review and Confirm Items**

   - Tap on the request to open details
   - For each item, choose "Available" or "Not Available"
   - Tap "Save" to submit confirmations

3. **Observe Status Changes**
   - Return to receiver dashboard
   - Request status should update based on confirmations:
     - All items confirmed → "Confirmed"
     - Some items confirmed → "Partially Fulfilled"

#### Step 3: End User Views Updates

1. **Switch Back to End User**
   - Login as End User again
   - View the updated request status
   - See real-time progress updates

### 4. Testing Real-time Updates

#### WebSocket Testing

- The app automatically connects to WebSocket
- Status changes should appear immediately
- No manual refresh needed

#### Polling Fallback Testing

- If WebSocket fails, app falls back to polling
- Updates occur every 8 seconds
- Check console for connection status

### 5. Error Handling Testing

#### Network Errors

- Disconnect internet connection
- App should show error messages
- Reconnect and tap "Retry" to recover

#### Edge Cases

- Try creating request with no items
- Test with empty item catalog
- Verify proper error messages

### 6. UI/UX Testing

#### Navigation

- Test back button functionality
- Verify proper page transitions
- Check loading states

#### Responsiveness

- Test on different screen sizes
- Verify proper layout on tablets
- Check landscape orientation

## Expected Behavior

### Request Status Flow

```
Pending → (Receiver confirms items) → Confirmed or Partially Fulfilled
```

### Item Status Flow

```
Pending → (Receiver action) → Confirmed or Not Available
```

### Real-time Updates

- Status changes appear immediately
- Progress bars update dynamically
- No manual refresh required

## Troubleshooting

### Common Issues

1. **App won't start**

   - Check Flutter installation
   - Run `flutter doctor`
   - Verify dependencies with `flutter pub get`

2. **Backend connection failed**

   - Verify backend is running
   - Check `.env` configuration
   - Test API endpoints manually

3. **WebSocket connection failed**

   - Check WebSocket URL in `.env`
   - Verify backend WebSocket support
   - App will fallback to polling

4. **JSON serialization errors**
   - Run `flutter packages pub run build_runner build`
   - Check model definitions
   - Verify import statements

### Debug Tips

1. **Check Console Logs**

   - Look for error messages
   - Monitor network requests
   - Check WebSocket connection status

2. **Test API Endpoints**

   - Use Postman or curl
   - Verify request/response format
   - Check authentication

3. **Flutter Inspector**
   - Use Flutter Inspector for UI debugging
   - Check widget tree
   - Monitor state changes

## Demo Script for Presentation

### 1. Introduction (2 minutes)

- Show app structure and features
- Explain the two user roles
- Highlight real-time capabilities

### 2. End User Demo (3 minutes)

- Login as End User
- Create a request with multiple items
- Show request tracking and status updates

### 3. Receiver Demo (3 minutes)

- Login as Receiver
- Review assigned request
- Confirm items individually
- Show status changes

### 4. Real-time Demo (2 minutes)

- Switch between users
- Show immediate status updates
- Demonstrate WebSocket functionality

### 5. Technical Highlights (2 minutes)

- Show code structure
- Explain state management
- Highlight error handling

**Total Demo Time: ~12 minutes**

## Success Criteria

✅ **Functional Requirements**

- [ ] End User can create and submit requests
- [ ] Receiver can view and confirm items
- [ ] Status updates work correctly
- [ ] Real-time updates function
- [ ] Error handling works properly

✅ **Technical Requirements**

- [ ] Clean, maintainable code
- [ ] Proper state management
- [ ] Professional UI/UX
- [ ] Comprehensive error handling
- [ ] Good documentation

✅ **User Experience**

- [ ] Intuitive navigation
- [ ] Clear status indicators
- [ ] Responsive design
- [ ] Smooth animations
- [ ] Helpful error messages
