import { createHash } from 'crypto';

export function hashString(input: string): string {
  return createHash('sha256').update(input).digest('hex');
} 