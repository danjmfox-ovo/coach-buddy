import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { join, dirname } from 'path'
import { homedir, tmpdir } from 'os'
import { mkdtempSync, rmSync, mkdirSync, writeFileSync, existsSync, readFileSync } from 'fs'
import { spawnSync } from 'child_process'
import { fileURLToPath } from 'url'
import { detectTarget, copyFiles, SUB_SKILLS, README_URL } from '../../bin/installer.js'

const home = homedir()
const packageRoot = join(dirname(fileURLToPath(import.meta.url)), '..', '..')

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeTempDir() {
  return mkdtempSync(join(tmpdir(), 'coach-buddy-test-'))
}

function makeFs(existingPaths = []) {
  const calls = { mkdirSync: [], cpSync: [] }
  const fs = {
    existsSync: (p) => existingPaths.some((e) => p === e || p.startsWith(e)),
    mkdirSync: (p, opts) => calls.mkdirSync.push({ path: p, opts }),
    cpSync: (src, dest, opts) => calls.cpSync.push({ src, dest, opts }),
  }
  return { fs, calls }
}

// ---------------------------------------------------------------------------
// SUB_SKILLS integrity
// ---------------------------------------------------------------------------

describe('SUB_SKILLS', () => {
  it('contains exactly the four expected sub-skill names', () => {
    expect(SUB_SKILLS).toEqual(['cb-init', 'cb-log', 'cb-retro', 'cb-snapshot'])
  })

  it('each sub-skill has a corresponding directory in skills/', () => {
    for (const skill of SUB_SKILLS) {
      expect(existsSync(join(packageRoot, 'skills', skill))).toBe(true)
    }
  })
})

// ---------------------------------------------------------------------------
// detectTarget — unit
// ---------------------------------------------------------------------------

describe('detectTarget', () => {
  it('returns global target when --global and ~/.claude exists', () => {
    const { fs } = makeFs([join(home, '.claude')])
    expect(detectTarget({ cwd: '/some/project', isGlobal: true, fs }))
      .toBe(join(home, '.claude', 'skills', 'coach-buddy'))
  })

  it('--global takes precedence when both ~/.claude and cwd/.claude exist', () => {
    const cwd = '/some/project'
    const { fs } = makeFs([join(home, '.claude'), join(cwd, '.claude')])
    expect(detectTarget({ cwd, isGlobal: true, fs }))
      .toBe(join(home, '.claude', 'skills', 'coach-buddy'))
  })

  it('falls through to cwd/.claude when --global set but ~/.claude absent', () => {
    const cwd = '/some/project'
    const { fs } = makeFs([join(cwd, '.claude')])
    expect(detectTarget({ cwd, isGlobal: true, fs }))
      .toBe(join(cwd, '.claude', 'skills', 'coach-buddy'))
  })

  it('returns project-level claude target when .claude exists in cwd', () => {
    const cwd = '/some/project'
    const { fs } = makeFs([join(cwd, '.claude')])
    expect(detectTarget({ cwd, isGlobal: false, fs }))
      .toBe(join(cwd, '.claude', 'skills', 'coach-buddy'))
  })

  it('.claude takes precedence over .cursor when both exist in cwd', () => {
    const cwd = '/some/project'
    const { fs } = makeFs([join(cwd, '.claude'), join(cwd, '.cursor')])
    expect(detectTarget({ cwd, isGlobal: false, fs }))
      .toBe(join(cwd, '.claude', 'skills', 'coach-buddy'))
  })

  it('returns cursor target when only .cursor exists in cwd', () => {
    const cwd = '/some/project'
    const { fs } = makeFs([join(cwd, '.cursor')])
    expect(detectTarget({ cwd, isGlobal: false, fs }))
      .toBe(join(cwd, '.cursor', 'skills', 'coach-buddy'))
  })

  it('returns null when no supported tool is detected', () => {
    const { fs } = makeFs([])
    expect(detectTarget({ cwd: '/some/project', isGlobal: false, fs })).toBeNull()
  })

  it('returns null when --global passed but ~/.claude does not exist', () => {
    const { fs } = makeFs([])
    expect(detectTarget({ cwd: '/some/project', isGlobal: true, fs })).toBeNull()
  })
})

// ---------------------------------------------------------------------------
// copyFiles — unit (mocked fs)
// ---------------------------------------------------------------------------

describe('copyFiles', () => {
  const target = '/dest/.claude/skills/coach-buddy'
  const targetParent = '/dest/.claude/skills'

  it('creates target directory recursively', () => {
    const { fs, calls } = makeFs([packageRoot])
    copyFiles(target, packageRoot, { fs })
    expect(calls.mkdirSync).toContainEqual({ path: target, opts: { recursive: true } })
  })

  it('copies main skill to target with recursive option', () => {
    const { fs, calls } = makeFs([packageRoot])
    copyFiles(target, packageRoot, { fs })
    expect(calls.cpSync).toContainEqual({
      src: join(packageRoot, 'skills', 'coach-buddy'),
      dest: target,
      opts: { recursive: true },
    })
  })

  it('copies each sub-skill alongside the main skill', () => {
    const { fs, calls } = makeFs([packageRoot])
    copyFiles(target, packageRoot, { fs })
    for (const skill of SUB_SKILLS) {
      expect(calls.cpSync).toContainEqual({
        src: join(packageRoot, 'skills', skill),
        dest: join(targetParent, skill),
        opts: { recursive: true },
      })
    }
  })

  it('creates each sub-skill directory recursively', () => {
    const { fs, calls } = makeFs([packageRoot])
    copyFiles(target, packageRoot, { fs })
    for (const skill of SUB_SKILLS) {
      expect(calls.mkdirSync).toContainEqual({
        path: join(targetParent, skill),
        opts: { recursive: true },
      })
    }
  })

  it('copies custom-instructions.md into the main skill target', () => {
    const { fs, calls } = makeFs([packageRoot])
    copyFiles(target, packageRoot, { fs })
    expect(calls.cpSync).toContainEqual({
      src: join(packageRoot, 'custom-instructions.md'),
      dest: join(target, 'custom-instructions.md'),
      opts: undefined,
    })
  })

  it('skips custom-instructions.md when absent from package', () => {
    const existing = [packageRoot].map((p) => p) // excludes custom-instructions.md via substring match
    const { fs, calls } = makeFs([])
    // override: everything exists except custom-instructions.md
    fs.existsSync = (p) => !p.endsWith('custom-instructions.md')
    copyFiles(target, packageRoot, { fs })
    const srcs = calls.cpSync.map((c) => c.src)
    expect(srcs).not.toContain(join(packageRoot, 'custom-instructions.md'))
  })

  it('skips a sub-skill when its source directory does not exist', () => {
    const missingSkill = 'cb-snapshot'
    const { fs, calls } = makeFs([])
    fs.existsSync = (p) => !p.includes(missingSkill)
    copyFiles(target, packageRoot, { fs })
    const srcs = calls.cpSync.map((c) => c.src)
    expect(srcs).not.toContain(join(packageRoot, 'skills', missingSkill))
  })
})

// ---------------------------------------------------------------------------
// copyFiles — integration (real filesystem, temp dir)
// ---------------------------------------------------------------------------

describe('copyFiles (real fs)', () => {
  let tmpDir

  beforeEach(() => { tmpDir = makeTempDir() })
  afterEach(() => { rmSync(tmpDir, { recursive: true, force: true }) })

  it('installs SKILL.md for main skill', () => {
    const target = join(tmpDir, '.claude', 'skills', 'coach-buddy')
    copyFiles(target, packageRoot)
    expect(existsSync(join(target, 'SKILL.md'))).toBe(true)
  })

  it('installs each sub-skill SKILL.md alongside the main skill', () => {
    const target = join(tmpDir, '.claude', 'skills', 'coach-buddy')
    copyFiles(target, packageRoot)
    for (const skill of SUB_SKILLS) {
      expect(existsSync(join(tmpDir, '.claude', 'skills', skill, 'SKILL.md'))).toBe(true)
    }
  })

  it('installs cb-log reference file into cb-log/', () => {
    const target = join(tmpDir, '.claude', 'skills', 'coach-buddy')
    copyFiles(target, packageRoot)
    expect(existsSync(join(tmpDir, '.claude', 'skills', 'cb-log', 'references', 'coaching-log-format.md'))).toBe(true)
  })

  it('installs cb-snapshot reference file into cb-snapshot/', () => {
    const target = join(tmpDir, '.claude', 'skills', 'coach-buddy')
    copyFiles(target, packageRoot)
    expect(existsSync(join(tmpDir, '.claude', 'skills', 'cb-snapshot', 'references', 'board-snapshot-guide.md'))).toBe(true)
  })

  it('installs custom-instructions.md into the main skill directory', () => {
    const target = join(tmpDir, '.claude', 'skills', 'coach-buddy')
    copyFiles(target, packageRoot)
    expect(existsSync(join(target, 'custom-instructions.md'))).toBe(true)
  })

  it('installs framework references into the main skill directory', () => {
    const target = join(tmpDir, '.claude', 'skills', 'coach-buddy')
    copyFiles(target, packageRoot)
    expect(existsSync(join(target, 'references', 'frameworks'))).toBe(true)
  })
})

// ---------------------------------------------------------------------------
// CLI entry point — integration (subprocess)
// ---------------------------------------------------------------------------

function runInstaller(args, cwd) {
  const entryPoint = join(packageRoot, 'bin', 'install.js')
  return spawnSync(process.execPath, [entryPoint, ...args], {
    cwd,
    encoding: 'utf8',
    env: { ...process.env, HOME: tmpdir() }, // prevent writes to real ~/.claude
  })
}

describe('install.js CLI', () => {
  let tmpDir

  beforeEach(() => { tmpDir = makeTempDir() })
  afterEach(() => { rmSync(tmpDir, { recursive: true, force: true }) })

  it('exits 0 and prints setup instructions when no tool is detected', () => {
    const result = runInstaller([], tmpDir)
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('No supported tool detected')
    expect(result.stdout).toContain(README_URL)
  })

  it('installs successfully into a project with .claude/ and exits 0', () => {
    mkdirSync(join(tmpDir, '.claude'))
    const result = runInstaller([], tmpDir)
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('coach-buddy installed to')
    expect(existsSync(join(tmpDir, '.claude', 'skills', 'coach-buddy', 'SKILL.md'))).toBe(true)
  })

  it('exits 1 with "already installed" when target exists and --force is absent', () => {
    mkdirSync(join(tmpDir, '.claude'))
    runInstaller([], tmpDir) // first install
    const result = runInstaller([], tmpDir) // second install
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('already installed')
    expect(result.stderr).toContain('--force')
  })

  it('overwrites existing install when --force is passed', () => {
    mkdirSync(join(tmpDir, '.claude'))
    runInstaller([], tmpDir)
    const result = runInstaller(['--force'], tmpDir)
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('coach-buddy installed to')
  })

  it('-f is accepted as shorthand for --force', () => {
    mkdirSync(join(tmpDir, '.claude'))
    runInstaller([], tmpDir)
    const result = runInstaller(['-f'], tmpDir)
    expect(result.status).toBe(0)
  })
})

// ---------------------------------------------------------------------------
// AGENT-SKILLS.io spec compliance
// ---------------------------------------------------------------------------

describe('AGENT-SKILLS.io spec compliance', () => {
  const skillsRoot = join(packageRoot, 'skills')

  const allSkills = ['coach-buddy', ...SUB_SKILLS]

  it('each skill directory name matches the name field in its SKILL.md', () => {
    for (const skillDir of allSkills) {
      const skillMd = readFileSync(join(skillsRoot, skillDir, 'SKILL.md'), 'utf8')
      const match = skillMd.match(/^name:\s+(.+?)\s*$/m)
      expect(match, `SKILL.md in ${skillDir} has no name field`).not.toBeNull()
      expect(match[1]).toBe(skillDir)
    }
  })

  it('each skill SKILL.md has a non-empty description field', () => {
    for (const skillDir of allSkills) {
      const skillMd = readFileSync(join(skillsRoot, skillDir, 'SKILL.md'), 'utf8')
      expect(skillMd).toMatch(/^description:/m)
    }
  })

  it('Claude Code extension fields are nested under metadata:', () => {
    for (const skillDir of allSkills) {
      const skillMd = readFileSync(join(skillsRoot, skillDir, 'SKILL.md'), 'utf8')
      expect(skillMd, `${skillDir}/SKILL.md has bare user-invocable field`).not.toMatch(/^user-invocable:/m)
      expect(skillMd, `${skillDir}/SKILL.md has bare argument-hint field`).not.toMatch(/^argument-hint:/m)
    }
  })
})
