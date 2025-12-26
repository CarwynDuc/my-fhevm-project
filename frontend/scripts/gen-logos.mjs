import fs from 'node:fs/promises'
import path from 'node:path'
import sharp from 'sharp'

const root = path.resolve(process.cwd(), 'public', 'branding')
const outDir = path.join(root, 'png')
const inputs = [
  { in: 'veilmint-icon-light.svg', base: 'veilmint-icon-light' },
  { in: 'veilmint-icon-dark.svg', base: 'veilmint-icon-dark' },
]
const sizes = [16, 32, 64, 128, 256, 512, 1024]

await fs.mkdir(outDir, { recursive: true })

for (const i of inputs) {
  const src = path.join(root, i.in)
  for (const size of sizes) {
    const out = path.join(outDir, `${i.base}-${size}.png`)
    const buf = await sharp(src).resize(size, size, { fit: 'contain' }).png({ compressionLevel: 9 }).toBuffer()
    await fs.writeFile(out, buf)
    console.log('wrote', path.relative(process.cwd(), out))
  }
}
