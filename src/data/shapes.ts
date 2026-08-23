import { ShapeSkin, ShapeCategory } from '../types';
import shapesJson from './shapes.json';

export const SHAPE_SKINS: ShapeSkin[] = shapesJson as ShapeSkin[];

export function getSkinById(id: string): ShapeSkin {
  return SHAPE_SKINS.find(s => s.id === id) || SHAPE_SKINS[0];
}

export function getSkinsByCategory(category: ShapeCategory): ShapeSkin[] {
  if (category === 'all') return SHAPE_SKINS;
  return SHAPE_SKINS.filter(s => s.category === category);
}
