Feature: npx installer for Coach Buddy

  Background:
    Given the coach-buddy npm package is available via npx
    And the package root contains skills/coach-buddy/, skills/cb-init/, skills/cb-log/,
        skills/cb-retro/, skills/cb-snapshot/, and custom-instructions.md

  # --- Global flag precedence ---

  Scenario: --global flag takes precedence over project-level .claude
    Given the current directory contains a .claude/ folder
    And ~/.claude/ exists
    When I run `npx coach-buddy --global`
    Then SKILL.md is present at ~/.claude/skills/coach-buddy/SKILL.md
    And the output includes "/coach-buddy"
    And the exit code is 0

  # --- Claude Code ---

  Scenario: Install into Claude Code project (project-level)
    Given the current directory contains a .claude/ folder
    And the --global flag is not passed
    When I run `npx coach-buddy`
    Then SKILL.md is present at .claude/skills/coach-buddy/SKILL.md
    And custom-instructions.md is present at .claude/skills/coach-buddy/custom-instructions.md
    And the output includes "/coach-buddy"
    And the exit code is 0

  Scenario: Install at user level with --global flag
    Given the current directory does not contain a .claude/ folder
    And ~/.claude/ exists
    When I run `npx coach-buddy --global`
    Then SKILL.md is present at ~/.claude/skills/coach-buddy/SKILL.md
    And the exit code is 0

  # --- Sub-skills installed alongside main skill ---

  Scenario: Sub-skills are installed alongside the main skill
    Given the current directory contains a .claude/ folder
    When I run `npx coach-buddy`
    Then SKILL.md is present at .claude/skills/coach-buddy/SKILL.md
    And SKILL.md is present at .claude/skills/cb-init/SKILL.md
    And SKILL.md is present at .claude/skills/cb-log/SKILL.md
    And SKILL.md is present at .claude/skills/cb-retro/SKILL.md
    And SKILL.md is present at .claude/skills/cb-snapshot/SKILL.md

  Scenario: Sub-skill references are installed with their owning skill
    Given the current directory contains a .claude/ folder
    When I run `npx coach-buddy`
    Then coaching-log-format.md is present at .claude/skills/cb-log/references/coaching-log-format.md
    And board-snapshot-guide.md is present at .claude/skills/cb-snapshot/references/board-snapshot-guide.md

  # --- Cursor ---

  Scenario: Install into Cursor project
    Given the current directory contains a .cursor/ folder
    And the current directory does not contain a .claude/ folder
    When I run `npx coach-buddy`
    Then SKILL.md is present at .cursor/skills/coach-buddy/SKILL.md
    And the exit code is 0

  # --- No tool detected ---

  Scenario: No supported tool detected in current directory
    Given the current directory does not contain a .claude/ or .cursor/ folder
    And the --global flag is not passed
    When I run `npx coach-buddy`
    Then the output includes manual Chat Project setup instructions
    And the output includes a link to the README
    And the exit code is 0

  # --- Overwrite protection ---

  Scenario: Existing install without --force exits with error
    Given coach-buddy is already installed at .claude/skills/coach-buddy/
    When I run `npx coach-buddy`
    Then the output includes "already installed"
    And the output mentions --force
    And the exit code is 1

  Scenario: Existing install overwritten with --force
    Given coach-buddy is already installed at .claude/skills/coach-buddy/
    When I run `npx coach-buddy --force`
    Then the files at .claude/skills/coach-buddy/ reflect the current package contents
    And the exit code is 0

  # --- AGENT-SKILLS.io spec compliance ---

  Scenario: Installed skill directories satisfy AGENT-SKILLS.io naming constraint
    Given the current directory contains a .claude/ folder
    When I run `npx coach-buddy`
    Then each installed skill directory name matches the name field in its SKILL.md
