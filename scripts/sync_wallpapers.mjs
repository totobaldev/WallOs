import { promises as fs } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const rootDir = path.resolve(__dirname, '..')

const sourceDir = path.join(rootDir, 'fondos')
const targetDir = path.join(rootDir, 'apps', 'web', 'public', 'fondos')
const generatedFile = path.join(rootDir, 'apps', 'web', 'src', 'wallpapers.generated.ts')

const IMAGE_EXTENSIONS = new Set(['.png', '.jpg', '.jpeg', '.webp', '.avif', '.gif'])
const VIDEO_EXTENSIONS = new Set(['.mp4', '.mov', '.m4v', '.webm'])
const SUPPORTED_EXTENSIONS = new Set([...IMAGE_EXTENSIONS, ...VIDEO_EXTENSIONS])

function isSupportedFile(fileName) {
  return SUPPORTED_EXTENSIONS.has(path.extname(fileName).toLowerCase())
}

function wallpaperType(fileName) {
  const extension = path.extname(fileName).toLowerCase()
  return VIDEO_EXTENSIONS.has(extension) ? 'video' : 'image'
}

function encodeFileName(fileName) {
  return fileName
    .split('/')
    .map((segment) => encodeURIComponent(segment))
    .join('/')
}

async function listSourceFiles() {
  try {
    const entries = await fs.readdir(sourceDir, { withFileTypes: true })
    return entries
      .filter((entry) => entry.isFile() && isSupportedFile(entry.name))
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

function deduplicateSourceFiles(fileNames) {
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

async function clearTargetFolder() {
  await fs.mkdir(targetDir, { recursive: true })
  const entries = await fs.readdir(targetDir, { withFileTypes: true })

  await Promise.all(
    entries
      .filter((entry) => entry.isFile())
      .map((entry) => fs.unlink(path.join(targetDir, entry.name))),
  )
}

async function copyWallpapers(fileNames) {
  await Promise.all(
    fileNames.map((fileName) =>
      fs.copyFile(path.join(sourceDir, fileName), path.join(targetDir, fileName)),
    ),
  )
}

function buildGeneratedModule(fileNames) {
  const rows = fileNames.map((fileName) => {
    const entryType = wallpaperType(fileName)
    const encoded = encodeFileName(fileName)
    return `  { src: '/fondos/${encoded}', type: '${entryType}' },`
  })

  return [
    "export type WallpaperType = 'image' | 'video'",
    '',
    'export interface WallpaperItem {',
    '  src: string',
    '  type: WallpaperType',
    '}',
    '',
    'export const WALLPAPERS: WallpaperItem[] = [',
    ...rows,
    ']',
    '',
  ].join('\n')
}

async function writeGeneratedModule(fileNames) {
  const output = buildGeneratedModule(fileNames)
  await fs.writeFile(generatedFile, output, 'utf8')
}

async function main() {
  const wallpapers = await listSourceFiles()
  const { uniqueFileNames, removedFileNames } = deduplicateSourceFiles(wallpapers)
  await clearTargetFolder()

  if (uniqueFileNames.length > 0) {
    await copyWallpapers(uniqueFileNames)
  }

  await writeGeneratedModule(uniqueFileNames)

  console.log(
    `Wallpapers synced: ${uniqueFileNames.length}${removedFileNames.length > 0 ? ` (duplicados omitidos: ${removedFileNames.length})` : ''}`,
  )
}

main().catch((error) => {
  console.error('Failed to sync wallpapers')
  console.error(error)
  process.exitCode = 1
})
