import { describe, it, expect } from 'vitest'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { checkVersions } from '../../scripts/check-version.js'

const packageRoot = join(dirname(fileURLToPath(import.meta.url)), '..', '..')

// ---------------------------------------------------------------------------
// Helpers — build a minimal rootDir fixture by overriding individual files
// ---------------------------------------------------------------------------

function makeRootDir(overrides = {}) {
  return {
    packageJson: JSON.stringify({ version: '1.7.0' }),
    pluginJson: JSON.stringify({ version: '1.7.0' }),
    skillMd: [
      '---',
      'name: coach-buddy',
      'metadata:',
      '  version: "1.7.0"',
      '---',
    ].join('\n'),
    changelogMd: '# Changelog\n\n## v1.7.0 (2026-05-01)\n\n- Initial release\n',
    ...overrides,
  }
}

// ---------------------------------------------------------------------------
// all sources aligned → exits 0
// ---------------------------------------------------------------------------

describe('checkVersions — all sources aligned', () => {
  it('returns exit code 0 when all sources match package.json version', () => {
    const result = checkVersions(makeRootDir())
    expect(result.exitCode).toBe(0)
  })

  it('includes OK status for plugin.json in output', () => {
    const result = checkVersions(makeRootDir())
    expect(result.output).toContain('plugin.json')
    expect(result.output).toContain('OK')
  })

  it('includes OK status for CHANGELOG.md in output', () => {
    const result = checkVersions(makeRootDir())
    expect(result.output).toContain('CHANGELOG.md')
    expect(result.output).toContain('OK')
  })

  it('includes OK status for SKILL.md in output', () => {
    const result = checkVersions(makeRootDir())
    expect(result.output).toContain('SKILL.md')
    expect(result.output).toContain('OK')
  })
})

// ---------------------------------------------------------------------------
// plugin.json version mismatch → exits 1, output names the file
// ---------------------------------------------------------------------------

describe('checkVersions — plugin.json mismatch', () => {
  it('returns exit code 1 when plugin.json version does not match', () => {
    const fixture = makeRootDir({
      pluginJson: JSON.stringify({ version: '1.6.0' }),
    })
    const result = checkVersions(fixture)
    expect(result.exitCode).toBe(1)
  })

  it('names plugin.json in the output on mismatch', () => {
    const fixture = makeRootDir({
      pluginJson: JSON.stringify({ version: '1.6.0' }),
    })
    const result = checkVersions(fixture)
    expect(result.output).toContain('plugin.json')
  })
})

// ---------------------------------------------------------------------------
// CHANGELOG.md heading missing → exits 1, output names the file
// ---------------------------------------------------------------------------

describe('checkVersions — CHANGELOG.md heading absent', () => {
  it('returns exit code 1 when no matching heading exists', () => {
    const fixture = makeRootDir({
      changelogMd: '# Changelog\n\n## v1.6.0\n\n- Old release\n',
    })
    const result = checkVersions(fixture)
    expect(result.exitCode).toBe(1)
  })

  it('names CHANGELOG.md in the output when heading is absent', () => {
    const fixture = makeRootDir({
      changelogMd: '# Changelog\n\n## v1.6.0\n\n- Old release\n',
    })
    const result = checkVersions(fixture)
    expect(result.output).toContain('CHANGELOG.md')
  })
})

// ---------------------------------------------------------------------------
// SKILL.md missing metadata.version → exits 0 (warning only)
// ---------------------------------------------------------------------------

describe('checkVersions — SKILL.md missing metadata.version', () => {
  it('returns exit code 0 when SKILL.md has no metadata.version field', () => {
    const fixture = makeRootDir({
      skillMd: '---\nname: coach-buddy\n---\n\n# Coach Buddy\n',
    })
    const result = checkVersions(fixture)
    expect(result.exitCode).toBe(0)
  })

  it('includes a warning mentioning SKILL.md in the output', () => {
    const fixture = makeRootDir({
      skillMd: '---\nname: coach-buddy\n---\n\n# Coach Buddy\n',
    })
    const result = checkVersions(fixture)
    expect(result.output).toContain('SKILL.md')
  })
})

// ---------------------------------------------------------------------------
// CHANGELOG.md heading pattern flexibility
// ---------------------------------------------------------------------------

describe('checkVersions — CHANGELOG.md heading variants', () => {
  it('matches a heading without patch version (## v1.7)', () => {
    const fixture = makeRootDir({
      packageJson: JSON.stringify({ version: '1.7.0' }),
      changelogMd: '# Changelog\n\n## v1.7 (2026-05-01)\n\n- Release\n',
    })
    const result = checkVersions(fixture)
    expect(result.exitCode).toBe(0)
  })

  it('matches a heading with patch version (## v1.7.0)', () => {
    const fixture = makeRootDir({
      packageJson: JSON.stringify({ version: '1.7.0' }),
      changelogMd: '# Changelog\n\n## v1.7.0 (2026-05-01)\n\n- Release\n',
    })
    const result = checkVersions(fixture)
    expect(result.exitCode).toBe(0)
  })
})
