import { existsSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

let memo: string | null = null;

function tryEnsureDir(dir: string): string | null {
  try {
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
    return dir;
  } catch {
    return null;
  }
}

/**
 * Directorio raíz escribible para multer y archivos estáticos /uploads.
 * Orden: UPLOADS_DIR → ./uploads → tmp del SO (p. ej. Render/contenedores con cwd de solo lectura).
 */
export function getWritableUploadsRoot(): string {
  if (memo) {
    return memo;
  }

  const fromEnv = process.env.UPLOADS_DIR?.trim();
  const candidates = fromEnv
    ? [fromEnv]
    : [join(process.cwd(), 'uploads'), join(tmpdir(), 'urkufood-uploads')];

  for (const dir of candidates) {
    const ok = tryEnsureDir(dir);
    if (ok) {
      memo = ok;
      return ok;
    }
  }

  throw new Error(
    'No se pudo crear un directorio de uploads escribible. Define UPLOADS_DIR (por ejemplo /tmp/urkufood-uploads en Render).',
  );
}
