import { frontendURL } from '../../../helper/URLHelper';

const KanbanIndex = () => import('./Index.vue');
const KanbanBoardView = () => import('./BoardView.vue');
const KanbanBoardSettings = () => import('./BoardSettings.vue');

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
  {
    path: frontendURL('accounts/:accountId/kanban/boards/:boardId/settings'),
    name: 'kanban_board_settings',
    meta: {
      permissions: ['administrator', 'agent'],
    },
    component: KanbanBoardSettings,
  },
];
