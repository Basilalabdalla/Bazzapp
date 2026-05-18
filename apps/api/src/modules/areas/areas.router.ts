import { Router, Request, Response, IRouter } from 'express';
import jordanAreas from './jordan-areas.json';

export const areasRouter: IRouter = Router();

// GET /areas — public, returns all Jordan governorates with their areas
areasRouter.get('/', (_req: Request, res: Response) => {
  res.json(jordanAreas);
});

// GET /areas/:governorate — get areas for a specific governorate
areasRouter.get('/:governorate', (req: Request, res: Response) => {
  const match = jordanAreas.find(
    (g) => g.governorate.toLowerCase() === req.params.governorate.toLowerCase(),
  );
  if (!match) {
    res.status(404).json({ error: 'Governorate not found' });
    return;
  }
  res.json(match);
});
