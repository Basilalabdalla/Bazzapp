// ============================================
// BazZ Platform — CommitLint Configuration
// ============================================
// Enforces conventional commits format:
// type(scope): description
//
// Types: feat, fix, docs, style, refactor, 
//        test, chore, perf, ci, build, revert

module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Formatting (no logic change)
        'refactor', // Code refactoring
        'test',     // Tests
        'chore',    // Build process, tooling
        'perf',     // Performance improvement
        'ci',       // CI/CD changes
        'build',    // Build system changes
        'revert',   // Revert commit
        'wip',      // Work in progress (avoid in main)
      ],
    ],
    'scope-enum': [
      2,
      'always',
      [
        'mobile',
        'server',
        'shared-types',
        'shared-utils',
        'docker',
        'ci',
        'docs',
        'deps',
        'config',
        'auth',
        'orders',
        'delivery',
        'payments',
        'notifications',
        'users',
        'stores',
        'products',
      ],
    ],
    'subject-max-length': [2, 'always', 100],
    'body-max-line-length': [1, 'always', 200],
  },
};
