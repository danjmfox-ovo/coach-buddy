#!/usr/bin/env node

import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync, statSync, copyFileSync } from 'fs'
import { resolve, dirname, join } from 'path'
import { fileURLToPath } from 'url'
import { tmpdir } from 'os'

// ---------------------------------------------------------------------------
// Pure domain logic
// ---------------------------------------------------------------------------

/**
 * Resolve the plugin build staging directory from env or default.
 * Accepts an env map for testability.
 *
 * @param {Record<string, string|undefined>} [env]
 * @returns {string}
 */
export function resolvePluginBuildDir(env = process.env) {
  return env.PLUGIN_BUILD_DIR ?? join(tmpdir(), 'coach-buddy-plugin-build')
}

/**
 * Transform SKILL.md content: promote all keys nested under `metadata:` to
 * top-level frontmatter and remove the `metadata:` block. If no `metadata:`
 * block exists, returns input unchanged.
 *
 * @param {string} content  Raw SKILL.md content
 * @returns {string}        Transformed content
 */
export function transformFrontmatter(content) {
  const fmMatch = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/s)
  if (!fmMatch) return content

  const fm = fmMatch[1]
  const body = fmMatch[2]

  if (!/^metadata:/m.test(fm)) return content

  const lines = fm.split('\n')
  const beforeMetadata = []
  const promotedLines = []
  let inMetadata = false

  for (const line of lines) {
    if (/^metadata:/.test(line)) {
      inMetadata = true
      continue
    }
    if (inMetadata) {
      if (/^  \S/.test(line)) {
        promotedLines.push(line.slice(2))
      } else {
        inMetadata = false
        beforeMetadata.push(line)
      }
    } else {
      beforeMetadata.push(line)
    }
  }

  const newFm = [...beforeMetadata, ...promotedLines].join('\n')
  return `---\n${newFm}\n---\n${body}`
}

/**
 * Recursively copy a skill directory to dest, applying transformFrontmatter
 * to SKILL.md and copying all other files verbatim.
 *
 * @param {string} srcDir   Absolute path to source skill directory
 * @param {string} destDir  Absolute path to destination directory
 */
export function syncSkillDir(srcDir, destDir) {
  mkdirSync(destDir, { recursive: true })

  for (const entry of readdirSync(srcDir)) {
    if (entry === '.DS_Store') continue

    const srcPath = join(srcDir, entry)
    const destPath = join(destDir, entry)

    if (statSync(srcPath).isDirectory()) {
      syncSkillDir(srcPath, destPath)
    } else if (entry === 'SKILL.md') {
      const content = readFileSync(srcPath, 'utf8')
      writeFileSync(destPath, transformFrontmatter(content), 'utf8')
    } else {
      copyFileSync(srcPath, destPath)
    }
  }
}

// ---------------------------------------------------------------------------
// CLI entry point
// ---------------------------------------------------------------------------

function runCli() {
  const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), '..')
  const skillsDir = resolve(rootDir, 'skills')
  const outputDir = join(resolvePluginBuildDir(), 'skills')

  const skillNames = readdirSync(skillsDir).filter(name => {
    const skillMd = resolve(skillsDir, name, 'SKILL.md')
    return existsSync(skillMd)
  })

  for (const name of skillNames) {
    syncSkillDir(resolve(skillsDir, name), join(outputDir, name))
    console.log(`  synced ${name}/`)
  }

  console.log(`Synced ${skillNames.length} skills → ${outputDir}/`)
}

if (process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url))) {
  runCli()
}
