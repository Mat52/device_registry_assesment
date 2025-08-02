# Device Registry

A simple Ruby on Rails application for registering devices to users, returning devices, and validating assignment rules.  
This project is part of a recruitment task.

---

## Requirements

- Ruby 3.x
- Rails 7.x
- Bundler
- SQLite3 (default) or PostgreSQL
- RSpec for testing

---

## Setup

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

---

## Project Structure

- `app/models` – User, Device, and ApiKey models
- `app/services` – Service objects handling device assignment and returning:
  - `AssignDeviceToUser`
  - `ReturnDeviceFromUser`
- `spec/` – RSpec tests for models and services

---

## Usage

To run the application locally:

```bash
rails server
```

Then open `http://localhost:3000` in your browser.

---

## Error Handling

The application includes custom error classes to handle edge cases:

- `AssigningError::AlreadyUsedBySameUser` – device was already used and returned by the same user
- `AssigningError::AlreadyUsedOnOtherUser` – device is already assigned to another user
- `ReturningError::Unauthorized` – user attempting to return a device they do not own
- `UnassigningError::AlreadyUnassigned` – device is already unassigned

---

## Notes

- Devices can be assigned to users.
- Devices can be returned, and the system tracks the assignments.
- Tests cover main business logic for assigning and returning devices.

---

## Author

Recruitment task solution by **Mateusz Łopatkiewicz**.
