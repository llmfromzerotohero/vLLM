from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="local-dev-key"
)

response = client.chat.completions.create(
    model="Qwen/Qwen2.5-0.5B-Instruct",
    messages=[{"role": "user", "content": "Olá!"}]
)
print(response.choices[0].message.content)