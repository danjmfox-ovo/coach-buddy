import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mkdirSync, writeFileSync, readFileSync, rmSync, existsSync } from 'fs'
import { join } from 'path'
import { tmpdir } from 'os'
import { transformFrontmatter, syncSkillDir, resolvePluginBuildDir } from '../../scripts/sync-skills.js'

describe('resolvePluginBuildDir', () => {
  it('returns PLUGIN_BUILD_DIR env var when set', () => {
    expect(resolvePluginBuildDir({ PLUGIN_BUILD_DIR: '/custom/path' })).toBe('/custom/path')
  })

  it('falls back to os.tmpdir()/coach-buddy-plugin-build when env var absent', () => {
    const result = resolvePluginBuildDir({})
    expect(result).toBe(join(tmpdir(), 'coach-buddy-plugin-build'))
  })
})

describe('transformFrontmatter', () => {
  it('promotes user-invocable from metadata to top-level', () => {
    const input = `---
name: my-skill
metadata:
  user-invocable: true
---
body`
    const result = transformFrontmatter(input)
    expect(result).toMatch(/^user-invocable: true$/m)
    expect(result).not.toMatch(/metadata:/)
  })

  it('promotes argument-hint from metadata to top-level', () => {
    const input = `---
name: my-skill
metadata:
  user-invocable: true
  argument-hint: '[foo] [--bar]'
---
body`
    const result = transformFrontmatter(input)
    expect(result).toMatch(/^argument-hint: '\[foo\] \[--bar\]'$/m)
    expect(result).not.toMatch(/metadata:/)
  })

  it('promotes version from metadata to top-level', () => {
    const input = `---
name: my-skill
metadata:
  version: "1.9.0"
  user-invocable: true
---
body`
    const result = transformFrontmatter(input)
    expect(result).toMatch(/^version: "1\.9\.0"$/m)
    expect(result).not.toMatch(/metadata:/)
  })

  it('promotes all metadata keys and removes the metadata block', () => {
    const input = `---
name: my-skill
description: A skill.
metadata:
  allowed-tools: Read, Write
  user-invocable: true
  argument-hint: '[x]'
---
# Body content`
    const result = transformFrontmatter(input)
    expect(result).toMatch(/^allowed-tools: Read, Write$/m)
    expect(result).toMatch(/^user-invocable: true$/m)
    expect(result).toMatch(/^argument-hint: '\[x\]'$/m)
    expect(result).not.toMatch(/metadata:/)
    expect(result).toContain('# Body content')
  })

  it('passes through top-level fields unchanged when no metadata block present', () => {
    const input = `---
name: my-skill
user-invocable: true
argument-hint: '[x]'
---
body`
    const result = transformFrontmatter(input)
    expect(result).toBe(input)
  })

  it('preserves body content unchanged', () => {
    const input = `---
name: my-skill
metadata:
  user-invocable: true
---
# Section

Some content with \`code\` and **bold**.`
    const result = transformFrontmatter(input)
    expect(result).toContain('# Section\n\nSome content with `code` and **bold**.')
  })

  it('preserves non-metadata top-level frontmatter fields', () => {
    const input = `---
name: my-skill
description: >-
  A description.
metadata:
  user-invocable: true
---
body`
    const result = transformFrontmatter(input)
    expect(result).toMatch(/^name: my-skill$/m)
    expect(result).toMatch(/^description: >-$/m)
  })
})

describe('syncSkillDir', () => {
  let srcDir, destDir

  beforeEach(() => {
    const base = join(tmpdir(), `sync-test-${Date.now()}`)
    srcDir = join(base, 'src')
    destDir = join(base, 'dest')
    mkdirSync(srcDir, { recursive: true })
  })

  afterEach(() => {
    rmSync(join(srcDir, '..'), { recursive: true, force: true })
  })

  it('transforms SKILL.md frontmatter at destination', () => {
    writeFileSync(join(srcDir, 'SKILL.md'), `---\nname: x\nmetadata:\n  user-invocable: true\n---\nbody`)
    syncSkillDir(srcDir, destDir)
    const out = readFileSync(join(destDir, 'SKILL.md'), 'utf8')
    expect(out).toMatch(/^user-invocable: true$/m)
    expect(out).not.toMatch(/metadata:/)
  })

  it('copies non-SKILL.md files verbatim', () => {
    writeFileSync(join(srcDir, 'SKILL.md'), `---\nname: x\nmetadata:\n  user-invocable: true\n---\nbody`)
    mkdirSync(join(srcDir, 'references'), { recursive: true })
    writeFileSync(join(srcDir, 'references', 'guide.md'), '# Guide content')
    syncSkillDir(srcDir, destDir)
    const out = readFileSync(join(destDir, 'references', 'guide.md'), 'utf8')
    expect(out).toBe('# Guide content')
  })

  it('recursively copies nested subdirectories', () => {
    writeFileSync(join(srcDir, 'SKILL.md'), `---\nname: x\nuser-invocable: true\n---\nbody`)
    mkdirSync(join(srcDir, 'references', 'frameworks'), { recursive: true })
    writeFileSync(join(srcDir, 'references', 'frameworks', 'cynefin.md'), '# Cynefin')
    syncSkillDir(srcDir, destDir)
    expect(existsSync(join(destDir, 'references', 'frameworks', 'cynefin.md'))).toBe(true)
  })

  it('skips .DS_Store files', () => {
    writeFileSync(join(srcDir, 'SKILL.md'), `---\nname: x\nuser-invocable: true\n---\nbody`)
    writeFileSync(join(srcDir, '.DS_Store'), 'junk')
    syncSkillDir(srcDir, destDir)
    expect(existsSync(join(destDir, '.DS_Store'))).toBe(false)
  })
})
