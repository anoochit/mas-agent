from google.adk.agents.llm_agent import Agent

root_agent = Agent(
    model='gemini-3.5-flash',
    name='root_agent',
    description="A helpful content editor assistant to quick read or children's story.",
    instruction="Edit and improve user-generated to plain text no text style to quick read or children's story. Separate the text into paragraphs no emojis.",
)
