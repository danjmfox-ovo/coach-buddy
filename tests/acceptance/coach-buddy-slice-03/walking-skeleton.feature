# Execution context: manual conversation test
# System under test: Claude Chat team project with portable Coach Buddy install
# Driving port: /coach-buddy invocation + lean always-on layer (custom-instructions.md in Custom Instructions)
# WS strategy: C (real-IO only — no simulation of the underlying model)
# How to run: install Coach Buddy in a real team project per README; paste the "Given" message; evaluate the "Then" assertions manually
# Slice: 03 (portable install — J3 in-context-activation, J5 portable-across-teams)
# Different from Slices 01-02: SKILL.md is Project Knowledge (not Custom Instructions); /coach-buddy activates the full pipeline

Feature: Walking skeleton — portable Coach Buddy install in a team project

  # -----------------------------------------------------------------------
  # RULE: Full install (custom-instructions.md in Custom Instructions
  #       + SKILL.md in Project Knowledge + reference files in Project Knowledge)
  # -----------------------------------------------------------------------

  Rule: Full install

    Background:
      Given a Claude Chat Project that is NOT the coach's dedicated coaching project
      And the contents of custom-instructions.md are pasted into Custom Instructions
      And SKILL.md is uploaded as Project Knowledge
      And the five reference files (complexity, work-layers, teams, development, tensions) are uploaded as Project Knowledge
      And no prior conversation history exists in this session

    # -- Story 1: Portable Install --

    @walking_skeleton @real-io @US-1
    Scenario: Lean always-on layer activates without triggering full pipeline
      Given the coach sends a message that does NOT begin with /coach-buddy
      When the tool responds
      Then the response reflects the lean coaching sensibility: concise, no performative affirmations, equal-weight not deferential
      And the response does NOT open with the SKILL.md disclaimer ("A thinking tool, not a coach")
      And the response does NOT ask for mode, context, and stakes

    @walking_skeleton @real-io @US-1
    Scenario: /coach-buddy invocation activates full thinking-partner pipeline
      Given the coach sends "/coach-buddy My team has been delivering consistently but the energy feels flat lately. Sprints are technically passing but nobody seems invested."
      When the tool responds
      Then the first response opens with the SKILL.md disclaimer or equivalent framing that this is a thinking tool
      And the first response names at least one observable symptom from the description
      And the first response asks exactly one calibrating question
      And the first response does NOT ask for mode, context, and stakes all at once

    @real-io @US-1
    Scenario: Full pipeline does not activate for ordinary team project messages
      Given the coach sends several ordinary messages in the team project without /coach-buddy
      When the tool responds to each
      Then none of the responses include the SKILL.md opening protocol
      And the ambient coaching sensibility (Theory Y, attribution rule) remains active throughout

    # -- Story 2: In-Context Activation --

    @real-io @US-2
    Scenario: Tool leads with observation before any question after /coach-buddy invocation
      Given the coach sends "/coach-buddy" followed by a situation description of at least two sentences
      When the tool responds
      Then the first substantive sentence is an observation, hypothesis, or named dynamic from the description
      And no question appears before that observation

    @real-io @US-2
    Scenario: Coaching stays grounded in situation when team artefacts are mentioned
      Given the coach sends "/coach-buddy I'm looking at our sprint board — cycle times are increasing every sprint despite the team saying WIP is under control. Something isn't adding up."
      When the tool responds
      Then the tool responds to the coaching situation described by the coach
      And the tool does not treat the sprint board as a technical document to analyse
      And the tool does not confuse team-specific terminology with coaching framework vocabulary

    @error @US-2
    Scenario: Regression guard — ER-001 applies in team project context
      Given the coach has sent /coach-buddy and answered two calibrating questions in a team project session
      When the tool's next turn is due
      Then the tool does not ask a third calibrating question without first offering a synthesis
      And the tool either reflects back what it has heard OR transitions explicitly to Phase A delivery

    @error @US-2
    Scenario: Regression guard — ER-002 applies in team project context
      Given the coach sends "/coach-buddy" followed by any situation description
      When the tool responds
      Then the first thing the tool offers is not a question
      And the tool does not ask two questions in sequence without synthesis between them

  # -----------------------------------------------------------------------
  # RULE: Minimal install (custom-instructions.md in Custom Instructions
  #       + SKILL.md in Project Knowledge, NO reference files)
  # -----------------------------------------------------------------------

  Rule: Minimal install (no reference files)

    Background:
      Given a Claude Chat Project that is NOT the coach's dedicated coaching project
      And the contents of custom-instructions.md are pasted into Custom Instructions
      And SKILL.md is uploaded as Project Knowledge
      And NO reference files are uploaded
      And no prior conversation history exists in this session

    # -- Story 3: Graceful Degradation --

    @real-io @US-3
    Scenario: Minimal install response names a dynamic beyond restating the coach's words
      Given the coach sends "/coach-buddy" followed by a real situation description from their current coaching work
      When the tool responds
      Then the response names at least one symptom or dynamic that goes beyond restating the coach's own words
      And the response is recognisably situation-focus in orientation

    @real-io @US-3
    Scenario: Minimal install response includes an attribution from the built-in lens list
      Given the coach sends "/coach-buddy" followed by a real situation description
      When the tool responds (in this turn or a subsequent turn in the same conversation)
      Then at some point the tool includes at least one attribution in "Name (Source)" format
      And the attributed framework name and source match an entry in SKILL.md's primary or secondary lens list
      And the tool does NOT attribute frameworks not listed in SKILL.md without grounding from the conversation

    @real-io @US-3
    Scenario: Minimal install response offers a question that advances the coach's thinking
      Given the coach sends "/coach-buddy" followed by a real situation description
      When the tool responds
      Then the response offers at least one question
      And that question points toward something the coach has not yet named or considered

    @error @US-3
    Scenario: Minimal install does not surface an error or degraded-mode warning
      Given the coach sends "/coach-buddy" followed by a real situation description
      When the tool responds
      Then the response does NOT include an error message
      And the response does NOT say "I cannot help without reference files" or equivalent
      And the response does NOT suggest the tool is operating in a reduced or degraded mode
      And the response does NOT recommend uploading reference files before the coach has asked about quality

    @real-io @US-3
    Scenario: Minimal install conversation is useful — coach self-report
      Given the coach has completed a full /coach-buddy conversation (3+ turns) in a minimal install
      When the coach reflects on the conversation immediately after
      Then the coach can articulate at least one insight or reframe they got from the conversation
      And the coach does NOT describe the experience as "broken", "confusing", or "unhelpful"
      Note: record the coach's self-report verbatim in the test log for traceability
