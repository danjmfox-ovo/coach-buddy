#!/usr/bin/env node
/**
 * validate-plugin.js
 *
 * Validates plugin structure before building the .plugin zip.
 * Catches the two failure modes that cause "invalid plugin format" on CoWork upload:
 *   1. plugin.json missing required fields (skills, version, repository, license, keywords)
 *   2. SKILL.md frontmatter missing the metadata: block (user-invocable, argument-hint stripped)
 *
 * Usage (CLI — run before zipping):
 *   node scripts/validate-plugin.js
 *
 * Usage (programmatic):
 *   import { validatePluginJson, validateSkillFrontmatter, validatePlugin } from './scripts/validate-plugin.js'
 */

import { readFileSync, readdirSync, existsSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

// ---------------------------------------------------------------------------
// Pure domain logic
// ---------------------------------------------------------------------------

const REQUIRED_PLUGIN_FIELDS = [
  'name',
  'version',
  'description',
  'author',
  'repository',
  'license',
  'keywords',
  'skills',
]

/**
 * Validate that plugin.json contains all fields required by the CoWork validator.
 * @param {string} content  Raw JSON string
 * @returns {{ ok: boolean, missing: string[] }}
 */
export function validatePluginJson(content) {
  const plugin = JSON.parse(content)
  const missing = REQUIRED_PLUGIN_FIELDS.filter(f => !(f in plugin))
  return { ok: missing.length === 0, missing }
}

/**
 * Validate a SKILL.md file's YAML frontmatter.
 * Checks:
 *   - Frontmatter delimiters (--- ... ---) exist
 *   - Top-level `metadata:` block is present
 *   - `user-invocable: true` is present (required for CoWork skill discovery)
 *
 * @param {string} filename  Relative path used in error messages
 * @param {string} content   Raw SKILL.md content
 * @returns {{ ok: boolean, errors: string[] }}
 */
export function validateSkillFrontmatter(filename, content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/)
  if (!match) {
    return { ok: false, errors: [`${filename}: no YAML frontmatter found`] }
  }

  const fm = match[1]
  const errors = []

  if (!/^metadata:/m.test(fm)) {
    errors.push(`${filename}: missing top-level 'metadata:' block`)
  }

  if (!/user-invocable:\s*true/.test(fm)) {
    errors.push(`${filename}: missing 'user-invocable: true'`)
  }

  return { ok: errors.length === 0, errors }
}

/**
 * Validate the full plugin: plugin.json plus all skill manifests.
 *
 * @param {{ pluginJson: string, skillMds: Record<string, string> }} input
 * @returns {{ ok: boolean, errors: string[] }}
 */
export function validatePlugin({ pluginJson, skillMds }) {
  const errors = []

  const pj = validatePluginJson(pluginJson)
  if (!pj.ok) {
    errors.push(...pj.missing.map(f => `plugin.json: missing required field '${f}'`))
  }

  for (const [filename, content] of Object.entries(skillMds)) {
    const sm = validateSkillFrontmatter(filename, content)
    if (!sm.ok) errors.push(...sm.errors)
  }

  return { ok: errors.length === 0, errors }
}

// ---------------------------------------------------------------------------
// CLI entry point
// ---------------------------------------------------------------------------

function runCli() {
  const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), '..')
  const pluginDir = resolve(rootDir, 'plugins/coach-buddy')

  const pluginJsonPath = resolve(pluginDir, '.claude-plugin/plugin.json')
  const pluginJson = readFileSync(pluginJsonPath, 'utf8')

  const skillsDir = resolve(pluginDir, 'skills')
  const skillMds = {}
  for (const dir of readdirSync(skillsDir)) {
    const skillPath = resolve(skillsDir, dir, 'SKILL.md')
    if (existsSync(skillPath)) {
      skillMds[`skills/${dir}/SKILL.md`] = readFileSync(skillPath, 'utf8')
    }
  }

  const result = validatePlugin({ pluginJson, skillMds })

  if (result.ok) {
    console.log('Plugin structure valid')
    process.exit(0)
  } else {
    console.error('Plugin validation FAILED:')
    for (const error of result.errors) {
      console.error(`  - ${error}`)
    }
    process.exit(1)
  }
}

if (process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url))) {
  runCli()
}
