# Device Registry

A lightweight **Ruby on Rails** service for managing physical device assignments to users.  
Users can register devices to themselves, return them, and the system ensures strict assignment rules with a full audit trail.  
This project was implemented as part of a recruitment task.

---

## 📋 Requirements

- Ruby 3.x  
- Rails 7.x  
- Bundler  
- SQLite3 (default) or PostgreSQL  
- RSpec for testing

---

## ⚡ Setup & Run

1. **Clone the repository**
   ```bash
   git clone <your_repo_url>
   cd device_registry
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
   Then open `http://localhost:3000`

---

## 📡 API Usage

The app exposes a minimal API for assigning and returning devices:

### Assign a Device
```bash
curl -X POST http://localhost:3000/api/assign   -H "Content-Type: application/json"   -d '{"device": {"serial_number": "ABC123"}}'
```

### Return a Device
```bash
curl -X POST http://localhost:3000/api/unassign   -H "Content-Type: application/json"   -d '{"device": {"serial_number": "ABC123"}}'
```

---

## 🔒 Assignment Rules

- Users can **only assign devices to themselves**.  
- A device must be **unassigned** to be assigned.  
- Devices **returned by the same user** cannot be re-assigned to that user.  
- Only the **owner** of a device can return it.  
- Every assignment and return is logged in `DeviceAssignment`.

---

## 📂 Project Structure

- `app/models` – User, Device, and ApiKey models  
- `app/services` – Business logic for device lifecycle:
  - `AssignDeviceToUser`
  - `ReturnDeviceFromUser`
- `spec/` – RSpec test suite for models and services

---

## ⚠️ Error Handling

Custom errors are used for better domain-driven error reporting:

- `AssigningError::AlreadyUsedBySameUser` – device already used & returned by same user  
- `AssigningError::AlreadyUsedOnOtherUser` – device currently assigned to another user  
- `ReturningError::Unauthorized` – returning a device not owned by the user  
- `UnassigningError::AlreadyUnassigned` – device already unassigned

---

## 🧪 Testing

The project is fully covered with RSpec tests for:

- Service objects (`AssignDeviceToUser`, `ReturnDeviceFromUser`)  
- Edge cases like double assignment or unauthorized returns  
- Controller API responses

Run tests with:

```bash
rspec
```

---

## 👤 Author

Recruitment task solution by **Mateusz Łopatkiewicz**.
