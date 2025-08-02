# 📦 Device Registry

A lightweight **Ruby on Rails** service for managing physical device assignments to users.  
Users can **assign** devices to themselves, **return** them, and the system ensures strict rules with a full audit trail.  

This project was implemented as part of a recruitment task.  

---

## 📋 Requirements

- **Ruby** 3.x  
- **Rails** 7.x  
- **Bundler**  
- **SQLite3** (default) or **PostgreSQL**  
- **RSpec** for testing  

---

## ⚡ Setup & Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mat52/device_registry_assessment.git
   cd device_registry_assessment
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Prepare the database**
   ```bash
   rails db:setup
   rails db:test:prepare
   ```

4. **Run the test suite**
   ```bash
   rspec
   ```

5. **Start the server**
   ```bash
   rails server
   ```
   Then open **http://localhost:3000**

---

## 📡 API Usage

The app exposes minimal endpoints for **assigning** and **returning** devices.

### Assign a Device
```bash
curl -X POST http://localhost:3000/devices/assign \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"device": {"serial_number": "ABC123"}, "new_owner_id": 1}'
```

### Return a Device
```bash
curl -X POST http://localhost:3000/devices/unassign \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"device": {"serial_number": "ABC123"}, "from_user": 1}'
```

---

## 🔒 Assignment Rules

- Users can **only assign devices to themselves**.  
- A device must be **unassigned** to be assigned.  
- Devices **returned by the same user** cannot be re-assigned to that user.  
- Only the **owner** of a device can return it.  
- Every assignment and return is logged in `DeviceAssignment`.  

---

### 🔄 Device Lifecycle

1. **Assign** – a user assigns a free device to themselves.  
2. **Return** – the user returns the device (device becomes unassigned).  
3. **Re-assign**:
   - The **same user cannot re-assign** a device they already returned.  
   - Another user can assign the device if it is free.  

---

## ⚠️ Error Handling

Custom domain errors provide clear responses:

- `AssigningError::Unauthorized` – user is not allowed to perform the action  
- `AssigningError::AlreadyUsedOnUser` – device was already assigned & returned by the same user  
- `AssigningError::AlreadyUsedOnOtherUser` – device is assigned to another user  
- `AssigningError::AlreadyUnassigned` – device is not currently assigned to the requested user  
- `AssigningError::DeviceNotFound` – device with the given serial number does not exist  

---

## 📂 Project Structure

- `app/models` – `User`, `Device`, and `DeviceAssignment` models  
- `app/services` – Core business logic:
  - `AssignDeviceToUser`
  - `ReturnDeviceFromUser`
- `spec/` – RSpec test suite for services and controllers

---

## 🧪 Testing

The project includes comprehensive **RSpec** tests covering:

- Service objects (`AssignDeviceToUser`, `ReturnDeviceFromUser`)  
- Edge cases: double assignment, unauthorized returns, missing devices  
- Controller API responses  

Run tests with:

```bash
rspec
```

To check coverage:

```bash
COVERAGE=true rspec
open coverage/index.html
```

---

## 👤 Author

Recruitment task solution by **Mateusz Łopatkiewicz**.
