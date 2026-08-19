# Delegation policy for How to grow

For larger tasks, proactively delegate independent, clearly bounded supporting work to the custom `spark_ui_worker` agent when doing so materially improves speed or lets useful work run in parallel.

Good Spark subtasks include:

- comparing an in-game screenshot with a user-designated source-of-truth image;
- measuring UI positions, proportions, padding, scale, crop, and layer order;
- locating the exact scenes, scripts, nodes, themes, and assets involved in a visual issue;
- implementing a small isolated UI adjustment with a clear acceptance target;
- inspecting focused test output or checking a narrow regression.

Keep architecture, ambiguous requirements, cross-cutting changes, conflict-prone edits, final visual judgment, integration, and end-to-end verification with the primary agent. Do not delegate trivial work or work that cannot be independently checked. The primary agent must inspect and verify all delegated results before presenting them to the user.
