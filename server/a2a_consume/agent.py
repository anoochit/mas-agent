from google.adk.agents.llm_agent import Agent
from google.adk.agents.remote_a2a_agent import (
    AGENT_CARD_WELL_KNOWN_PATH,
    RemoteA2aAgent,
)

remote_agent = RemoteA2aAgent(
    name='remote_agent',
    description="A helpful assistant for user questions.",
    agent_card=f"http://localhost:8001{AGENT_CARD_WELL_KNOWN_PATH}",
)

root_agent = Agent(
    model='gemini-3.5-flash',
    name='root_agent',
    description="Root agent that delegates tasks to remote A2A agents.",
    sub_agents=[remote_agent],
)
