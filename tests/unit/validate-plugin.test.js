import { describe, it, expect } from 'vitest'
import { validatePluginJson, validateSkillFrontmatter, validatePlugin } from '../../scripts/validate-plugin.js'

// ---------------------------------------------------------------------------
// Fixtures — valid state (CoWork-compatible flat frontmatter)
// ---------------------------------------------------------------------------

const VALID_PLUGIN_JSON = JSON.stringify({
  name: 'coach-buddy',
  version: '1.8.0',
  description: 'Agile coaching tools',
  author: { name: 'Dan Fox' },
  repository: 'https://github.com/danjmfox-ovo/coach-buddy',
  license: 'MIT',
  keywords: ['coaching', 'agile'],
  skills: './skills/',
})

const VALID_SKILL_MD = [
  '---',
  'name: cb-init',
  'description: >-',
  '  Scaffolds a new coaching engagement folder.',
  'user-invocable: true',
  "argument-hint: '[--force] — re-run without confirmation'",
  '---',
  '',
  '# cb-init',
].join('\n')

// ---------------------------------------------------------------------------
// validatePluginJson
// ---------------------------------------------------------------------------

describe('validatePluginJson — valid input', () => {
  it('accepts a fully-populated plugin.json', () => {
    const result = validatePluginJson(VALID_PLUGIN_JSON)
    expect(result.ok).toBe(true)
    expect(result.missing).toEqual([])
  })
})

describe('validatePluginJson — regression: working-tree corruption', () => {
  it('rejects plugin.json stripped of skills, version, repository, license, keywords', () => {
    const stripped = JSON.stringify({
      name: 'coach-buddy',
      description: 'Agile coaching tools',
      author: { name: 'Dan Fox' },
    })
    const result = validatePluginJson(stripped)
    expect(result.ok).toBe(false)
    expect(result.missing).toContain('skills')
    expect(result.missing).toContain('version')
    expect(result.missing).toContain('repository')
    expect(result.missing).toContain('license')
    expect(result.missing).toContain('keywords')
  })

  it('reports each missing field individually', () => {
    const noSkills = JSON.stringify({ name: 'x', version: '1.0.0', description: 'y', author: {}, repository: 'r', license: 'MIT', keywords: [] })
    const result = validatePluginJson(noSkills)
    expect(result.ok).toBe(false)
    expect(result.missing).toEqual(['skills'])
  })
})

// ---------------------------------------------------------------------------
// validateSkillFrontmatter — valid (flat frontmatter, CoWork-compatible)
// ---------------------------------------------------------------------------

describe('validateSkillFrontmatter — valid input', () => {
  it('accepts flat frontmatter with top-level user-invocable', () => {
    const result = validateSkillFrontmatter('cb-init/SKILL.md', VALID_SKILL_MD)
    expect(result.ok).toBe(true)
    expect(result.errors).toEqual([])
  })

  it('accepts coach-buddy SKILL.md with version at top level', () => {
    const content = [
      '---',
      'name: coach-buddy',
      'description: >-',
      '  Thinking partner for Agile coaches.',
      'version: "1.8.0"',
      'user-invocable: true',
      "argument-hint: '[situation] — describe what you want to think through'",
      '---',
      '',
      '# Coach Buddy',
    ].join('\n')
    const result = validateSkillFrontmatter('coach-buddy/SKILL.md', content)
    expect(result.ok).toBe(true)
  })
})

// ---------------------------------------------------------------------------
// validateSkillFrontmatter — regression: metadata: nesting (original failure)
// ---------------------------------------------------------------------------

describe('validateSkillFrontmatter — regression: metadata: block present', () => {
  it('rejects SKILL.md with user-invocable nested under metadata:', () => {
    const broken = [
      '---',
      'name: cb-init',
      'description: >-',
      '  Scaffolds a new coaching engagement folder.',
      'metadata:',
      '  user-invocable: true',
      "  argument-hint: '[--force]'",
      '---',
    ].join('\n')
    const result = validateSkillFrontmatter('cb-init/SKILL.md', broken)
    expect(result.ok).toBe(false)
    expect(result.errors.some(e => e.includes('metadata'))).toBe(true)
  })

  it('rejects SKILL.md missing user-invocable: true entirely', () => {
    const broken = [
      '---',
      'name: cb-init',
      'description: >-',
      '  Scaffolds a new coaching engagement folder.',
      "argument-hint: '[--force]'",
      '---',
    ].join('\n')
    const result = validateSkillFrontmatter('cb-init/SKILL.md', broken)
    expect(result.ok).toBe(false)
    expect(result.errors.some(e => e.includes('user-invocable'))).toBe(true)
  })

  it('rejects SKILL.md with no frontmatter at all', () => {
    const result = validateSkillFrontmatter('cb-init/SKILL.md', '# cb-init\n\nNo frontmatter here.')
    expect(result.ok).toBe(false)
    expect(result.errors.some(e => e.includes('frontmatter'))).toBe(true)
  })

  it('includes the filename in error messages', () => {
    const broken = [
      '---',
      'name: cb-log',
      'description: >-',
      '  Captures a coaching observation.',
      '---',
    ].join('\n')
    const result = validateSkillFrontmatter('cb-log/SKILL.md', broken)
    expect(result.ok).toBe(false)
    expect(result.errors.some(e => e.includes('cb-log/SKILL.md'))).toBe(true)
  })
})

// ---------------------------------------------------------------------------
// validateSkillFrontmatter — regression: angle brackets in frontmatter
// ---------------------------------------------------------------------------

describe('validateSkillFrontmatter — regression: angle brackets in frontmatter', () => {
  it('rejects SKILL.md with angle brackets in description', () => {
    const broken = [
      '---',
      'name: cb-init',
      'description: >-',
      '  Scaffolds engagements/<team-slug>/.',
      'user-invocable: true',
      "argument-hint: '[--force]'",
      '---',
    ].join('\n')
    const result = validateSkillFrontmatter('cb-init/SKILL.md', broken)
    expect(result.ok).toBe(false)
    expect(result.errors.some(e => e.includes('angle brackets'))).toBe(true)
  })

  it('accepts SKILL.md with angle brackets only in body (not frontmatter)', () => {
    const content = [
      '---',
      'name: cb-init',
      'description: >-',
      '  Scaffolds a new coaching engagement folder.',
      'user-invocable: true',
      "argument-hint: '[--force]'",
      '---',
      '',
      '# cb-init',
      'Creates `engagements/<team-slug>/` directory.',
    ].join('\n')
    const result = validateSkillFrontmatter('cb-init/SKILL.md', content)
    expect(result.ok).toBe(true)
  })
})

// ---------------------------------------------------------------------------
// validatePlugin — aggregate
// ---------------------------------------------------------------------------

describe('validatePlugin — valid state', () => {
  it('passes when plugin.json and all SKILL.mds are valid', () => {
    const result = validatePlugin({
      pluginJson: VALID_PLUGIN_JSON,
      skillMds: {
        'cb-init/SKILL.md': VALID_SKILL_MD,
        'coach-buddy/SKILL.md': VALID_SKILL_MD,
      },
    })
    expect(result.ok).toBe(true)
    expect(result.errors).toEqual([])
  })
})

describe('validatePlugin — regression: CoWork upload failures', () => {
  it('catches metadata: nesting and missing plugin.json fields together', () => {
    const brokenPluginJson = JSON.stringify({ name: 'coach-buddy', description: 'x', author: {} })
    const brokenSkillMd = [
      '---',
      'name: cb-init',
      'description: >-',
      '  Scaffolds a folder.',
      'metadata:',
      '  user-invocable: true',
      '---',
    ].join('\n')
    const result = validatePlugin({
      pluginJson: brokenPluginJson,
      skillMds: { 'cb-init/SKILL.md': brokenSkillMd },
    })
    expect(result.ok).toBe(false)
    expect(result.errors.some(e => e.includes('skills'))).toBe(true)
    expect(result.errors.some(e => e.includes('metadata'))).toBe(true)
  })
})
