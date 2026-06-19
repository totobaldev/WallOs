import { promises as fs } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const rootDir = path.resolve(__dirname, '..')

const sourceDir = path.join(rootDir, 'fondos')
const targetDir = path.join(rootDir, 'apps', 'desktop_flutter', 'assets', 'wallpapers')
const catalogDir = path.join(rootDir, 'apps', 'desktop_flutter', 'assets', 'catalog')
const catalogFile = path.join(catalogDir, 'wallpapers.json')
const creatorsConfigFile = path.join(sourceDir, 'creators.json')
const execFileAsync = promisify(execFile)

const DEFAULT_CREATOR_PROFILES = [
  {
    name: 'Alicia Vega',
    supportUrl: 'https://ko-fi.com/aliciavega',
  },
  {
    name: 'Bruno Rojas',
    supportUrl: 'https://ko-fi.com/brunorojas',
  },
  {
    name: 'Carla Montes',
    supportUrl: 'https://ko-fi.com/carlamontes',
  },
  {
    name: 'Diego Flores',
    supportUrl: 'https://ko-fi.com/diegoflores',
  },
]

const TITLE_ADJECTIVES = [
  'Aurora',
  'Celestial',
  'Velvet',
  'Silent',
  'Crystal',
  'Golden',
  'Oceanic',
  'Emerald',
  'Lunar',
  'Radiant',
]

const TITLE_SUBJECTS = [
  'Dawn',
  'Horizon',
  'Breeze',
  'Summit',
  'Valley',
  'Tide',
  'Nebula',
  'Echo',
  'Lagoon',
  'Trail',
]

const TITLE_SUFFIXES = [
  'Vista',
  'Scene',
  'Edition',
  'Panorama',
  'Light',
  'Moment',
]

const IMAGE_EXTENSIONS = new Set(['.png', '.jpg', '.jpeg', '.webp', '.avif'])

function isSupportedImage(fileName) {
  return IMAGE_EXTENSIONS.has(path.extname(fileName).toLowerCase())
}

async function listSourceImages() {
  try {
    const entries = await fs.readdir(sourceDir, { withFileTypes: true })
    return entries
      .filter((entry) => entry.isFile() && isSupportedImage(entry.name))
      .map((entry) => entry.name)
      .sort((a, b) => a.localeCompare(b))
  } catch {
    return []
  }
}

function normalizeVariantKey(fileName) {
  const { name, ext } = path.parse(fileName)
  const normalizedName = name
    .replace(/\s*(?:\(|\[)?copy(?:\s*\d+)?(?:\)|\])?$/i, '')
    .trim()
    .toLowerCase()

  return `${normalizedName || name.toLowerCase()}${ext.toLowerCase()}`
}

function duplicatePenalty(fileName) {
  return /\bcopy\b/i.test(path.parse(fileName).name) ? 1 : 0
}

function choosePreferredFileName(currentFileName, candidateFileName) {
  const currentPenalty = duplicatePenalty(currentFileName)
  const candidatePenalty = duplicatePenalty(candidateFileName)

  if (candidatePenalty !== currentPenalty) {
    return candidatePenalty < currentPenalty ? candidateFileName : currentFileName
  }

  return candidateFileName.localeCompare(currentFileName) < 0
    ? candidateFileName
    : currentFileName
}

function deduplicateSourceImages(fileNames) {
  const selectedByKey = new Map()

  for (const fileName of fileNames) {
    const key = normalizeVariantKey(fileName)
    const existing = selectedByKey.get(key)

    if (!existing) {
      selectedByKey.set(key, fileName)
      continue
    }

    selectedByKey.set(key, choosePreferredFileName(existing, fileName))
  }

  const uniqueFileNames = Array.from(selectedByKey.values()).sort((a, b) => a.localeCompare(b))
  const uniqueSet = new Set(uniqueFileNames)
  const removedFileNames = fileNames.filter((fileName) => !uniqueSet.has(fileName))

  return {
    uniqueFileNames,
    removedFileNames,
  }
}

async function clearFolder(folder) {
  await fs.mkdir(folder, { recursive: true })
  const entries = await fs.readdir(folder, { withFileTypes: true })
  await Promise.all(
    entries
      .filter((entry) => entry.isFile())
      .map((entry) => fs.unlink(path.join(folder, entry.name))),
  )
}

function normalizeCreatorProfiles(rawCreators) {
  if (!Array.isArray(rawCreators)) {
    return []
  }

  return rawCreators
    .map((creator) => {
      if (!creator || typeof creator !== 'object') {
        return null
      }

      const name = typeof creator.name === 'string' ? creator.name.trim() : ''
      if (!name) {
        return null
      }

      const supportUrl =
        typeof creator.supportUrl === 'string' && creator.supportUrl.trim().length > 0
          ? creator.supportUrl.trim()
          : 'https://buymeacoffee.com/wallos'

      return {
        name,
        supportUrl,
      }
    })
    .filter(Boolean)
}

function normalizeAssignments(rawAssignments) {
  if (!rawAssignments || typeof rawAssignments !== 'object') {
    return {}
  }

  return Object.entries(rawAssignments).reduce((acc, [fileName, creatorName]) => {
    if (typeof fileName !== 'string' || typeof creatorName !== 'string') {
      return acc
    }

    const normalizedFileName = fileName.trim()
    const normalizedCreatorName = creatorName.trim()
    if (!normalizedFileName || !normalizedCreatorName) {
      return acc
    }

    acc[normalizedFileName] = normalizedCreatorName
    return acc
  }, {})
}

function normalizeTitleAssignments(rawTitles) {
  if (!rawTitles || typeof rawTitles !== 'object') {
    return {}
  }

  return Object.entries(rawTitles).reduce((acc, [fileName, title]) => {
    if (typeof fileName !== 'string' || typeof title !== 'string') {
      return acc
    }

    const normalizedFileName = fileName.trim()
    const normalizedTitle = title.trim()
    if (!normalizedFileName || !normalizedTitle) {
      return acc
    }

    acc[normalizedFileName] = normalizedTitle
    return acc
  }, {})
}

function normalizeLookupKey(value) {
  return value
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[^a-z0-9]/g, '')
}

function findAssignedCreatorName(fileName, stem, assignments) {
  const exactMatch = assignments[fileName] ?? assignments[stem]
  if (exactMatch) {
    return exactMatch
  }

  const targetKeys = new Set([normalizeLookupKey(fileName), normalizeLookupKey(stem)])

  for (const [assignmentKey, creatorName] of Object.entries(assignments)) {
    if (targetKeys.has(normalizeLookupKey(assignmentKey))) {
      return creatorName
    }
  }

  return null
}

async function loadCreatorsConfig() {
  try {
    const content = await fs.readFile(creatorsConfigFile, 'utf8')
    const parsed = JSON.parse(content)

    const creators = normalizeCreatorProfiles(parsed.creators)
    const assignments = normalizeAssignments(parsed.assignments)
    const titles = normalizeTitleAssignments(parsed.titles)

    if (creators.length > 0) {
      return { creators, assignments, titles }
    }
  } catch {
    // Fallback to defaults when config does not exist or is invalid.
  }

  return {
    creators: DEFAULT_CREATOR_PROFILES,
    assignments: {},
    titles: {},
  }
}

function createGeneratedTitle(index, dimensions) {
  const adjective = TITLE_ADJECTIVES[index % TITLE_ADJECTIVES.length]
  const subject = TITLE_SUBJECTS[(index * 3) % TITLE_SUBJECTS.length]
  const suffix = TITLE_SUFFIXES[(index * 5) % TITLE_SUFFIXES.length]
  const ratioHint = dimensions.width >= dimensions.height ? 'Wide' : 'Portrait'

  return `${adjective} ${subject} ${suffix} ${ratioHint}`
}

async function copyImages(fileNames) {
  await Promise.all(
    fileNames.map((fileName) =>
      fs.copyFile(path.join(sourceDir, fileName), path.join(targetDir, fileName)),
    ),
  )
}

async function readImageDimensions(filePath) {
  try {
    const { stdout } = await execFileAsync('sips', ['-g', 'pixelWidth', '-g', 'pixelHeight', filePath], {
      encoding: 'utf8',
    })

    const widthMatch = stdout.match(/pixelWidth:\s*(\d+)/)
    const heightMatch = stdout.match(/pixelHeight:\s*(\d+)/)

    return {
      width: widthMatch ? Number.parseInt(widthMatch[1], 10) : 0,
      height: heightMatch ? Number.parseInt(heightMatch[1], 10) : 0,
    }
  } catch {
    return { width: 0, height: 0 }
  }
}

function resolveCreatorForFile(fileName, index, creators, assignments) {
  const stem = path.parse(fileName).name
  const assignedName = findAssignedCreatorName(fileName, stem, assignments)

  if (assignedName) {
    const assignedCreator = creators.find(
      (creator) => creator.name.toLowerCase() === assignedName.toLowerCase(),
    )

    if (assignedCreator) {
      return assignedCreator
    }
  }

  return creators[index % creators.length]
}

function resolveTitleForFile(fileName, index, dimensions, titles, baseTitleCache) {
  const stem = path.parse(fileName).name.trim()
  const baseStem = stem.replace(/\s+copy$/i, '').trim()

  const assignedTitle = findAssignedCreatorName(fileName, stem, titles)
  if (assignedTitle) {
    return assignedTitle
  }

  const assignedBaseTitle = findAssignedCreatorName(baseStem, baseStem, titles)
  if (assignedBaseTitle) {
    return stem.toLowerCase().endsWith(' copy') ? `${assignedBaseTitle} Alt` : assignedBaseTitle
  }

  let baseTitle = baseTitleCache.get(baseStem)
  if (!baseTitle) {
    baseTitle = createGeneratedTitle(index, dimensions)
    baseTitleCache.set(baseStem, baseTitle)
  }

  return stem.toLowerCase().endsWith(' copy') ? `${baseTitle} Alt` : baseTitle
}

async function buildCatalogItems(fileNames, creators, assignments, titles) {
  const items = []
  const baseTitleCache = new Map()

  for (let index = 0; index < fileNames.length; index += 1) {
    const fileName = fileNames[index]
    const sourceFilePath = path.join(sourceDir, fileName)
    const dimensions = await readImageDimensions(sourceFilePath)
    const creator = resolveCreatorForFile(fileName, index, creators, assignments)
    const title = resolveTitleForFile(fileName, index, dimensions, titles, baseTitleCache)

    items.push({
      id: path.parse(fileName).name,
      title,
      previewAssetPath: `assets/wallpapers/${fileName}`,
      width: dimensions.width,
      height: dimensions.height,
      uploadedBy: creator.name,
      supportUrl: creator.supportUrl,
      tags: ['4k', 'macos', 'wallpaper'],
    })
  }

  return items
}

async function writeCatalog(fileNames, creators, assignments, titles) {
  await fs.mkdir(catalogDir, { recursive: true })

  const items = await buildCatalogItems(fileNames, creators, assignments, titles)

  const output = JSON.stringify({ generatedAt: new Date().toISOString(), items }, null, 2)
  await fs.writeFile(catalogFile, output, 'utf8')
}

async function main() {
  const { creators, assignments, titles } = await loadCreatorsConfig()
  const images = await listSourceImages()
  const { uniqueFileNames, removedFileNames } = deduplicateSourceImages(images)
  await clearFolder(targetDir)
  if (uniqueFileNames.length > 0) {
    await copyImages(uniqueFileNames)
  }
  await writeCatalog(uniqueFileNames, creators, assignments, titles)

  console.log(
    `Flutter wallpapers synced: ${uniqueFileNames.length}${removedFileNames.length > 0 ? ` (duplicados omitidos: ${removedFileNames.length})` : ''}`,
  )
}

main().catch((error) => {
  console.error('Failed to sync Flutter wallpapers')
  console.error(error)
  process.exitCode = 1
})
