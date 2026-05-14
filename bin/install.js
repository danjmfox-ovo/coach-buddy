#!/usr/bin/env node
import { existsSync } from 'fs'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { detectTarget, copyFiles, README_URL } from './installer.js'

const packageRoot = dirname(dirname(fileURLToPath(import.meta.url)))
const cwd = process.cwd()
const args = process.argv.slice(2)
const isGlobal = args.includes('--global') || args.includes('-g')
const force = args.includes('--force') || args.includes('-f')

const target = detectTarget({ cwd, isGlobal })

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

copyFiles(target, packageRoot)

console.log(`\ncoach-buddy installed to:\n  ${target}`)
console.log('\nUse /coach-buddy in any conversation to activate the full thinking-partner pipeline.')
