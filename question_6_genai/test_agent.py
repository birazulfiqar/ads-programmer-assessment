import requests

url = "http://127.0.0.1:8000/ae-agent"


# Test questions
questions = [
    "Show me moderate severity adverse events",
    "Find subjects with headache",
    "Give me cardiac related events",
    "Show mild adverse events",
    "Skin disorders cases"
]


# Send requests to API
for q in questions:

    response = requests.post(
        url,
        json={"question": q}
    )

    print("\nQUESTION:", q)
    print("RESPONSE:", response.json())