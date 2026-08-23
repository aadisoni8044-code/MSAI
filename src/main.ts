import './index.css';
import { AppController } from './app';

document.addEventListener('DOMContentLoaded', () => {
  const root = document.getElementById('root');
  if (root) {
    new AppController(root);
  }
});
