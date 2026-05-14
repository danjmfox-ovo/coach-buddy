import { mkdirSync, cpSync, existsSync } from 'fs'
import { join, dirname } from 'path'
import { homedir } from 'os'

export const SUB_SKILLS = ['cb-init', 'cb-log', 'cb-retro', 'cb-snapshot']

export const README_URL = 'https://github.com/danjmfox-ovo/coach-buddy#install'

/**
 * Determine the install target directory.
 * --global takes precedence over project-level detection.
 * Returns null when no supported tool is detected.
 */
export function detectTarget({ cwd, isGlobal, fs = { existsSync } } = {}) {
  if (isGlobal && fs.existsSync(join(homedir(), '.claude'))) {
    return join(homedir(), '.claude', 'skills', 'coach-buddy')
  }
  if (fs.existsSync(join(cwd, '.claude'))) {
    return join(cwd, '.claude', 'skills', 'coach-buddy')
  }
  if (fs.existsSync(join(cwd, '.cursor'))) {
    return join(cwd, '.cursor', 'skills', 'coach-buddy')
  }
  return null
}

/**
 * Copy all skills from the package root to the target location.
 * Main skill → target. Sub-skills → siblings of target.
 */
export function copyFiles(target, packageRoot, { fs = { existsSync, mkdirSync, cpSync } } = {}) {
  const skillsRoot = join(packageRoot, 'skills')
  const targetParent = dirname(target)

  copySkill(join(skillsRoot, 'coach-buddy'), target, fs)

  const customInstructions = join(packageRoot, 'custom-instructions.md')
  if (fs.existsSync(customInstructions)) {
    fs.cpSync(customInstructions, join(target, 'custom-instructions.md'))
  }

  for (const skill of SUB_SKILLS) {
    const src = join(skillsRoot, skill)
    if (fs.existsSync(src)) copySkill(src, join(targetParent, skill), fs)
  }
}

function copySkill(src, dest, fs) {
  fs.mkdirSync(dest, { recursive: true })
  fs.cpSync(src, dest, { recursive: true })
}
