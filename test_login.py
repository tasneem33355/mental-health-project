import requests

URL = "https://alisakr9997-safespace.hf.space/api/v1/auth/login"

def test_login(email, password):
    print(f"Testing login for {email} ...")
    response = requests.post(URL, json={"email": email, "password": password})
    if response.status_code == 200:
        print("[SUCCESS]:", response.json())
    else:
        print("[FAILED]:", response.status_code, response.text)

print("--- Testing Database Accounts ---")
test_login("admin@admin.com", "adminadmin")
test_login("test@example.com", "hashed_password_123")
