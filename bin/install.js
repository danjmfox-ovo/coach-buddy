#!/usr/bin/env node
import { mkdirSync, cpSync, existsSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { homedir } from 'os'

const packageRoot = join(dirname(fileURLToPath(import.meta.url)), '..')
const cwd = process.cwd()
const args = process.argv.slice(2)
const isGlobal = args.includes('--global') || args.includes('-g')
const force = args.includes('--force') || args.includes('-f')

const README_URL = 'https://github.com/danjmfox-ovo/coach-buddy#install'

function detectTarget() {
  if (existsSync(join(cwd, '.claude'))) {
    return join(cwd, '.claude', 'skills', 'coach-buddy')
  }
  if (existsSync(join(cwd, '.cursor'))) {
    return join(cwd, '.cursor', 'skills', 'coach-buddy')
  }
  if (isGlobal && existsSync(join(homedir(), '.claude'))) {
    return join(homedir(), '.claude', 'skills', 'coach-buddy')
  }
  return null
}

function copyFiles(target) {
  mkdirSync(target, { recursive: true })
  for (const item of ['SKILL.md', 'custom-instructions.md', 'references', 'assets']) {
    const src = join(packageRoot, item)
    if (existsSync(src)) {
      cpSync(src, join(target, item), { recursive: true })
    }
  }
}

const target = detectTarget()

if (!target) {
  console.log('\nNo supported tool detected in the current directory.')
  console.log('\nFor Claude Chat Project setup, follow the manual steps in the README:')
  console.log(README_URL)
  process.exit(0)
}

if (existsSync(target) && !force) {
  console.error(`\ncoach-buddy is already installed at:\n  ${target}`)
  console.error('\nUse --force to overwrite the existing install.')
  process.exit(1)
}

copyFiles(target)

console.log(`\ncoach-buddy installed to:\n  ${target}`)
console.log('\nUse /coach-buddy in any conversation to activate the full thinking-partner pipeline.')
