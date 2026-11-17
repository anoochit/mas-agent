from google.adk.agents.llm_agent import Agent

root_agent = Agent(
    model='gemini-3.5-flash',
    name='root_agent',
    description='A helpful children\'s content generator assistant',
    instruction='Answer user questions to the best of your knowledge',
)

