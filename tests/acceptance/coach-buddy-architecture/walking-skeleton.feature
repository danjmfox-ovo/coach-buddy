# Execution context: manual conversation test
# System under test: Claude Chat Project configured with SKILL.md + reference files
# Driving port: conversational turn (coach message in Claude Chat Project)
# WS strategy: C (real-IO only — no simulation of the underlying model)
# How to run: open the Chat Project, paste the "Given" message, evaluate the "Then" assertions manually
# Slice: 01 (thinking-partner / situation-focus only)

Feature: Walking skeleton — thinking-partner situation-focus conversation

  Background:
    Given the Claude Chat Project is open
    And SKILL.md is installed as custom instructions
    And the reference files are uploaded as project knowledge
    And no prior conversation history exists in this session

  # --- Core walking skeleton ---

  @walking_skeleton @real-io @US-1
  Scenario: Coach describes a situation and receives a reflection with no unrequested framework
    Given the coach sends "My team has been delivering consistently but the energy feels flat lately. Sprints are technically passing but nobody seems invested."
    When the tool responds
    Then the response names at least one observable symptom from the description
    And the response does not introduce a named framework unprompted
    And the response does not include attribution markup in "Name (Source)" format
    And the response ends with exactly one question

  @walking_skeleton @real-io @US-1
  Scenario: Tool leads with observation, not question, on first turn
    Given the coach sends a situation description of at least two sentences
    When the tool responds
    Then the first substantive sentence is an observation, hypothesis, or named dynamic
    And no question appears before that observation

  @real-io @US-2
  Scenario: Coach explicitly requests a framework and receives attributed response
    Given the coach is in a situation-focus conversation
    When the coach sends "Is there a framework I could use to think about this?"
    Then the tool introduces one relevant framework
    And the attribution format is "Name (Source)" or "Name (Author)" on first mention
    And the response explains the framework's relevance to the current situation
    And the response introduces no more than two frameworks in this turn

  @real-io @US-2
  Scenario: Framework not re-attributed on second mention in same conversation
    Given "Cynefin (Snowden)" has been mentioned and attributed once in the current conversation
    When the tool or coach references Cynefin again in a later turn
    Then the response refers to it as "Cynefin" only
    And the "(Snowden)" attribution is not repeated

  # --- Calibration and delivery protocol ---

  @real-io @US-1
  Scenario: Tool transitions to reflection after 3-4 exchanges
    Given the coach and tool have exchanged at least three turns on a single situation
    When the tool judges it has gathered enough to reflect back
    Then the tool says something equivalent to "I think I have enough to work with — let me reflect back what I'm hearing"
    And the tool then produces a substantive reflection in the same response

  @error
  Scenario: Regression guard — ER-001: calibration loop exit condition
    Given the coach has described a situation and answered two calibrating questions
    When the tool's next turn is due
    Then the tool does not ask a third calibrating question without first offering a synthesis
    And the tool either reflects back what it has heard OR transitions explicitly to Phase A delivery

  @error
  Scenario: Regression guard — ER-002: observation before question
    Given the coach sends any message describing a situation
    When the tool responds
    Then the first thing the tool offers is not a question
    And the tool does not ask two questions in sequence without synthesis between them

  @error
  Scenario: Regression guard — ER-004: framework vocabulary requires attribution on first mention
    Given the tool has not yet attributed "psychological safety" in the current conversation
    When the tool uses the phrase "psychological safety" in any response
    Then the response includes "(Edmondson)" alongside the first use
    And this applies whether the term is used as named framework or as conversational vocabulary

  # --- High-stakes tiebreaker (D5) ---

  @real-io @US-1
  Scenario: Stakes stated as consequential — tool holds situation-focus
    Given the coach sends "I have a session tomorrow that could end the engagement if it goes wrong"
    And the prior conversation has touched on both a specific situation and a general learning interest
    When the tool determines its orientation
    Then the tool responds in situation-focus
    And the response contains no unsolicited framework introduction
    And if the tool surfaces its orientation it uses language like "Keeping this in situation-focus given the stakes"
