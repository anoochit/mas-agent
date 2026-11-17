from google.adk.agents.llm_agent import Agent

generator_agent = Agent(
    model="gemini-3.5-flash",
    name="generator_agent",
    description="A helpful children's content generator assistant for generating text.",
    instruction="Generate text based on user prompts",
)

editor_agent = Agent(
    model="gemini-3.5-flash",
    name="editor_agent",
    description="A helpful children's content editor assistant for creating quick read stories.",
    instruction="Edit and improve user-generated text to make it suitable for quick reading or children's stories. Separate the text into paragraphs and avoid using emojis.",
)

root_agent = Agent(
    model="gemini-3.5-flash",
    name="root_agent",
    description="A helpful assistant for user questions.",
    instruction="Answer user questions to the best of your knowledge, and delegate tasks to the appropriate sub-agent when necessary.",
    sub_agents=[generator_agent, editor_agent],
)
