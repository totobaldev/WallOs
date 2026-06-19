export type WallpaperType = 'image' | 'video'

export interface WallpaperItem {
  src: string
  type: WallpaperType
}

export const WALLPAPERS: WallpaperItem[] = [
  { src: '/fondos/17976723-6E8E-4850-980C-A376B551E07E.mov', type: 'video' },
  { src: '/fondos/2B3F02F9-AC22-4963-8FFB-C2E5B8569334.mp4', type: 'video' },
  { src: '/fondos/2B3F02F9-AC22-4963-8FFB-C2E5B8569334.png', type: 'image' },
  { src: '/fondos/4937653B-5A1F-4BCF-9FAE-CDC62802316C.mp4', type: 'video' },
  { src: '/fondos/4937653B-5A1F-4BCF-9FAE-CDC62802316C.png', type: 'image' },
  { src: '/fondos/596547BA-8132-4F2D-AA8B-2B38A81D1AB8.mp4', type: 'video' },
  { src: '/fondos/596547BA-8132-4F2D-AA8B-2B38A81D1AB8.png', type: 'image' },
  { src: '/fondos/6D5A4706-121B-4BCF-99DA-5D52A3AE439D.mp4', type: 'video' },
  { src: '/fondos/6D5A4706-121B-4BCF-99DA-5D52A3AE439D.png', type: 'image' },
  { src: '/fondos/DF826906-ABDC-4B02-BF2D-BAEB4B784687.m4v', type: 'video' },
  { src: '/fondos/DF826906-ABDC-4B02-BF2D-BAEB4B784687.png', type: 'image' },
  { src: '/fondos/ED5EFA23-0CB1-4579-8CFE-A58E9E420224.mp4', type: 'video' },
]
