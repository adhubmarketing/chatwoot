import { frontendURL } from '../../../helper/URLHelper';

const KanbanIndex = () => import('./Index.vue');
const KanbanBoardView = () => import('./BoardView.vue');

export const routes = [
  {
    path: frontendURL('accounts/:accountId/kanban'),
    name: 'kanban_overview',
    meta: {
      permissions: ['administrator', 'agent'],
    },
    component: KanbanIndex,
  },
  {
    path: frontendURL('accounts/:accountId/kanban/boards/:boardId'),
    name: 'kanban_board_view',
    meta: {
      permissions: ['administrator', 'agent'],
    },
    component: KanbanBoardView,
  },
];
