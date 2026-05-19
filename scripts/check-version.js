#!/usr/bin/env node
/**
 * check-version.js
 *
 * Validates that all version sources agree before a plugin release.
 * Source of truth: package.json
 *
 * Checked sources:
 *   - package.json                              (required, source of truth)
 *   - plugins/coach-buddy/.claude-plugin/plugin.json  (required)
 *   - skills/coach-buddy/SKILL.md frontmatter   (optional — warns but does not block)
 *   - CHANGELOG.md                              (required — heading must exist for the release version)
 *
 * Usage (programmatic):
 *   import { checkVersions } from './scripts/check-version.js'
 *   const result = checkVersions(rootDirFiles)  // rootDirFiles: { packageJson, pluginJson, skillMd, changelogMd }
 *
 * Usage (CLI):
 *   node scripts/check-version.js
 */

import { readFileSync, existsSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

// ---------------------------------------------------------------------------
// Pure domain logic
// ---------------------------------------------------------------------------

/**
 * Extract the version string from serialised package.json content.
 * @param {string} content
 * @returns {string}
 */
function readPackageVersion(content) {
  return JSON.parse(content).version
}

/**
 * Extract the version string from serialised plugin.json content.
 * Returns null when the field is absent.
 * @param {string} content
 * @returns {string|null}
 */
function readPluginVersion(content) {
  return JSON.parse(content).version ?? null
}

/**
 * Extract version from SKILL.md YAML frontmatter under metadata.version.
 * Returns null when absent (non-blocking, warn-only).
 * @param {string} content
 * @returns {string|null}
 */
function readSkillVersion(content) {
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/)
  if (!frontmatterMatch) return null
  const frontmatter = frontmatterMatch[1]
  const versionMatch = frontmatter.match(/^\s+version:\s*["']?([^"'\s]+)["']?/m)
  return versionMatch ? versionMatch[1] : null
}

/**
 * Check whether CHANGELOG.md contains a heading for the given version.
 * Accepts both "## v1.7" and "## v1.7.0" for a package version of "1.7.0".
 * @param {string} content
 * @param {string} version  e.g. "1.7.0"
 * @returns {boolean}
 */
function changelogContainsVersion(content, version) {
  // Strip trailing .0 patch to match headings like "## v1.7"
  const shortVersion = version.replace(/\.0$/, '')
  const exactPattern = new RegExp(`^##\\s+v${escapeRegex(version)}(?:\\b|\\s|$)`, 'm')
  const shortPattern = new RegExp(`^##\\s+v${escapeRegex(shortVersion)}(?:\\b|\\s|$)`, 'm')
  return exactPattern.test(content) || shortPattern.test(content)
}

function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

// ---------------------------------------------------------------------------
// Aggregated check
// ---------------------------------------------------------------------------

/**
 * Check all version sources against the package.json version.
 *
 * @param {{ packageJson: string, pluginJson: string, skillMd: string, changelogMd: string }} sources
 * @returns {{ exitCode: number, output: string }}
 */
export function checkVersions(sources) {
  const lines = []
  let passed = true
  let warned = false

  const expected = readPackageVersion(sources.packageJson)
  lines.push(`Version source of truth (package.json): ${expected}`)
  lines.push('')

  // plugin.json (required)
  const pluginVersion = readPluginVersion(sources.pluginJson)
  if (pluginVersion === null) {
    lines.push(`  plugin.json: NO version field found — FAIL`)
    passed = false
  } else if (pluginVersion !== expected) {
    lines.push(`  plugin.json: ${pluginVersion} — MISMATCH (expected ${expected}) — FAIL`)
    passed = false
  } else {
    lines.push(`  plugin.json: ${pluginVersion} — OK`)
  }

  // SKILL.md (optional — warn only)
  const skillVersion = readSkillVersion(sources.skillMd)
  if (skillVersion === null) {
    lines.push(`  SKILL.md: no metadata.version field — skipping (non-blocking) — WARN`)
    warned = true
  } else if (skillVersion !== expected) {
    lines.push(`  SKILL.md: ${skillVersion} — MISMATCH (expected ${expected}) — FAIL`)
    passed = false
  } else {
    lines.push(`  SKILL.md: ${skillVersion} — OK`)
  }

  // CHANGELOG.md (required)
  const changelogFound = changelogContainsVersion(sources.changelogMd, expected)
  if (!changelogFound) {
    lines.push(`  CHANGELOG.md: no heading found for ${expected} — FAIL`)
    passed = false
  } else {
    lines.push(`  CHANGELOG.md: ${expected} heading found — OK`)
  }

  lines.push('')
  if (!passed) {
    lines.push('Version check FAILED — resolve mismatches before releasing.')
  } else if (warned) {
    lines.push('Version check PASSED (with warnings — see above).')
  } else {
    lines.push('Version check PASSED — all sources aligned.')
  }

  return {
    exitCode: passed ? 0 : 1,
    output: lines.join('\n'),
  }
}

// ---------------------------------------------------------------------------
// CLI entry point — reads real files from disk, maps result to process.exit
// ---------------------------------------------------------------------------

function readFile(filePath) {
  return readFileSync(filePath, 'utf8')
}

function runCli() {
  const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), '..')

  const sources = {
    packageJson: readFile(resolve(rootDir, 'package.json')),
    pluginJson: readFile(resolve(rootDir, 'plugin/plugin.json')),
    skillMd: existsSync(resolve(rootDir, 'skills/coach-buddy/SKILL.md'))
      ? readFile(resolve(rootDir, 'skills/coach-buddy/SKILL.md'))
      : '---\n---\n',
    changelogMd: existsSync(resolve(rootDir, 'CHANGELOG.md'))
      ? readFile(resolve(rootDir, 'CHANGELOG.md'))
      : '',
  }

  const { exitCode, output } = checkVersions(sources)

  if (exitCode === 0) {
    process.stdout.write(output + '\n')
  } else {
    process.stderr.write(output + '\n')
  }

  process.exit(exitCode)
}

// Only run CLI when this file is the entry point
if (process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url))) {
  runCli()
}
