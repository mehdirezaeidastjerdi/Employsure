import os
import requests
import anthropic
import json

# --- Config ---
MERAKI_API_KEY = ""
MERAKI_BASE_URL = "https://api.meraki.com/api/v1"

anthropic_client = anthropic.Anthropic(api_key="")

HEADERS = {
    "X-Cisco-Meraki-API-Key": MERAKI_API_KEY,
    "Content-Type": "application/json"
}

# --- Meraki API helpers ---
def get_organizations():
    r = requests.get(f"{MERAKI_BASE_URL}/organizations", headers=HEADERS)
    return r.json()

def get_networks(org_id):
    r = requests.get(f"{MERAKI_BASE_URL}/organizations/{org_id}/networks", headers=HEADERS)
    return r.json()

def get_devices(network_id):
    r = requests.get(f"{MERAKI_BASE_URL}/networks/{network_id}/devices", headers=HEADERS)
    return r.json()

def get_clients(network_id):
    r = requests.get(f"{MERAKI_BASE_URL}/networks/{network_id}/clients?timespan=3600", headers=HEADERS)
    return r.json()

def get_device_statuses(org_id):
    r = requests.get(f"{MERAKI_BASE_URL}/organizations/{org_id}/devices/statuses", headers=HEADERS)
    return r.json()

# --- Tool definitions for Claude ---
tools = [
    {
        "name": "get_organizations",
        "description": "Get all Meraki organizations accessible with this API key.",
        "input_schema": {"type": "object", "properties": {}, "required": []}
    },
    {
        "name": "get_networks",
        "description": "Get all networks in a Meraki organization.",
        "input_schema": {
            "type": "object",
            "properties": {
                "org_id": {"type": "string", "description": "The organization ID"}
            },
            "required": ["org_id"]
        }
    },
    {
        "name": "get_devices",
        "description": "Get all devices in a Meraki network.",
        "input_schema": {
            "type": "object",
            "properties": {
                "network_id": {"type": "string", "description": "The network ID"}
            },
            "required": ["network_id"]
        }
    },
    {
        "name": "get_clients",
        "description": "Get clients connected to a network in the last hour.",
        "input_schema": {
            "type": "object",
            "properties": {
                "network_id": {"type": "string", "description": "The network ID"}
            },
            "required": ["network_id"]
        }
    },
    {
        "name": "get_device_statuses",
        "description": "Get online/offline status of all devices in an organization.",
        "input_schema": {
            "type": "object",
            "properties": {
                "org_id": {"type": "string", "description": "The organization ID"}
            },
            "required": ["org_id"]
        }
    }
]

# --- Tool dispatcher ---
def run_tool(name, inputs):
    if name == "get_organizations":
        return get_organizations()
    elif name == "get_networks":
        return get_networks(inputs["org_id"])
    elif name == "get_devices":
        return get_devices(inputs["network_id"])
    elif name == "get_clients":
        return get_clients(inputs["network_id"])
    elif name == "get_device_statuses":
        return get_device_statuses(inputs["org_id"])
    else:
        return {"error": f"Unknown tool: {name}"}

# --- Agentic loop ---
def ask(question):
    print(f"\nYou: {question}")
    messages = [{"role": "user", "content": question}]

    while True:
        response = anthropic_client.messages.create(
            # model="claude-sonnet-4-20250514",
            model="claude-haiku-4-5-20251001",
            max_tokens=1024,
            system="You are a network assistant with access to Cisco Meraki APIs. Use the tools to answer questions about the user's network. Be concise and friendly.",
            tools=tools,
            messages=messages
        )

        # If Claude wants to use a tool
        if response.stop_reason == "tool_use":
            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    print(f"  [Calling tool: {block.name}]")
                    result = run_tool(block.name, block.input)
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": json.dumps(result)
                    })

            # Append Claude's response + tool results to messages
            messages.append({"role": "assistant", "content": response.content})
            messages.append({"role": "user", "content": tool_results})

        # Claude has a final answer
        elif response.stop_reason == "end_turn":
            for block in response.content:
                if hasattr(block, "text"):
                    print(f"\nClaude: {block.text}")
            break

# --- Main loop ---
if __name__ == "__main__":
    print("Meraki Network Assistant (type 'quit' to exit)\n")
    while True:
        user_input = input("Ask about your network: ").strip()
        if user_input.lower() in ("quit", "exit"):
            break
        if user_input:
            ask(user_input)